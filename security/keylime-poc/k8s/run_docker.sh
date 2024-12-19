#!/usr/bin/env bash
# shellcheck disable=SC1091

# This script runs Keylime Verifier and Registrar as Docker containers.
# It is complimented by the "run_tenant.sh" that runs Keylime Tenant in
# container, sharing the config witht this script.

set -eux

. config.sh

run_verifier()
{
    # we need to supply cv_ca directory for sharing mtls certs
    docker run \
        -d \
        -v "${KEYLIME_EXTERNAL_TLS_DIR}":"${KEYLIME_INTERNAL_TLS_DIR}":rw \
        --name "${KEYLIME_VERIFIER_NAME}" \
        "${KEYLIME_VERIFIER_IMAGE}"
}

run_registrar()
{
    # we need to supply cv_ca directory for sharing mtls certs
    docker run \
        -d \
        -v "${KEYLIME_EXTERNAL_TLS_DIR}":"${KEYLIME_INTERNAL_TLS_DIR}":rw \
        --name "${KEYLIME_REGISTRAR_NAME}" \
        "${KEYLIME_REGISTRAR_IMAGE}"
}


# main
run_verifier
run_registrar
