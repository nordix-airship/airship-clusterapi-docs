#!/usr/bin/env bash
# shellcheck disable=SC1091

# This script runs Kind cluster and sets up Keylime Agent in the cluster.
# Keylime Agent runs as DaemonSet, and is then fronted by LoadBalancer
# service and Ingress rules.
#
# In first step, we run it without Ingress. It should be noted that this
# cheats in multiple ways:
#
# 1. It uses an IP address (not hostname)
# 2. It avoids Ingress rules for UUID based call routing

set -eux

. config.sh

check_tools()
{
    declare -a tools=(
        kind
        kubectl
    )

    for tool in "${tools[@]}"; do
        command -v "${tool}" &>/dev/null || { echo "error: ${tool} is not in PATH"; exit 1; }
    done
}

launch_kind_cluster()
{
    kind create cluster --name="${KIND_NAME}"
}

run_agent()
{
    echo TBD
}


# main
check_tools
launch_kind_cluster
run_agent
