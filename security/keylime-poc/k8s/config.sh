#!/usr/bin/env bash
# shellcheck disable=SC2034

# This holds the shared configuration options for Keylime scripts

# container runtime
CONTAINER_RUNTIME="${CONTAINER_RUNTIME:-docker}"

# registry and image details
REGISTRY=quay.io/keylime
TAG=latest

KEYLIME_TENANT_IMAGE="${REGISTRY}/keylime_tenant:${TAG}"
KEYLIME_REGISTRAR_IMAGE="${REGISTRY}/keylime_registrar:${TAG}"
KEYLIME_VERIFIER_IMAGE="${REGISTRY}/keylime_verifier:${TAG}"
KEYLIME_AGENT_IMAGE="${REGISTRY}/keylime_agent:${TAG}"

declare -a KEYLIME_IMAGES=(
    "${KEYLIME_TENANT_IMAGE}"
    "${KEYLIME_REGISTRAR_IMAGE}"
    "${KEYLIME_VERIFIER_IMAGE}"
    "${KEYLIME_AGENT_IMAGE}"
)

# docker instance names
KEYLIME_VERIFIER_NAME="keylime-verifier"
KEYLIME_REGISTRAR_NAME="keylime-registrar"
KEYLIME_TENANT_NAME="keylime-tenant"

# shared directory name
KEYLIME_TMP_DIR="/tmp/keylime"
KEYLIME_INTERNAL_TLS_DIR="/var/lib/keylime/cv_ca"
KEYLIME_EXTERNAL_TLS_DIR="${KEYLIME_TMP_DIR}/cv_ca"

# kind setup
KIND_NAME="keylime"
