#!/usr/bin/env bash
# shellcheck disable=SC1091

# a clean up script for everything we've done

set -eu

# shall we do deep clean or not
REALCLEAN="${1:-}"

. config.sh

remove_docker_instances()
{
    docker rm -f "${KEYLIME_VERIFIER_NAME}" || true
    docker rm -f "${KEYLIME_REGISTRAR_NAME}" || true
}

remove_kind_cluster()
{
    kind delete cluster --name="${KIND_NAME}" || true
}

remove_temporary_files()
{
    sudo rm -rf "${KEYLIME_TMP_DIR:?}"
}

remove_docker_images()
{
    for image in "${KEYLIME_IMAGES[@]}"; do
        docker image rm -f "${image}"
    done
}

# main
remove_docker_instances
remove_kind_cluster
remove_temporary_files

if [[ -n "${REALCLEAN}" ]]; then
    remove_docker_images
fi
