#!/usr/bin/env bash
# shellcheck disable=SC1091

# This script run Keylime Tenant in Docker container, allowing non-intrusive
# way of executing the Tenant CLI commands while sharing the configuration
# with the other Keylime components.

set -eux

. config.sh

run_tenant()
{
    # we need to supply cv_ca directory for sharing mtls certs
    docker run -it --rm \
        -v "${KEYLIME_EXTERNAL_TLS_DIR}":"${KEYLIME_INTERNAL_TLS_DIR}":rw \
        --name "${KEYLIME_TENANT_NAME}" \
        "${KEYLIME_TENANT_IMAGE}" \
        "$@"
}


# main
run_tenant "$@"
