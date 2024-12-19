#!/bin/bash

# Delete network connections
sudo nmcli con delete baremetal provisioning

# Disable and delete bridge interfaces
for iface in baremetal provisioning; do
    if ip link show $iface &>/dev/null; then
        sudo ip link set $iface down
        sudo brctl delbr $iface
    fi
done

# Delete libvirt networks
for net in provisioning baremetal; do
    if sudo virsh net-info $net &>/dev/null; then
        sudo virsh net-destroy $net
        sudo virsh net-undefine $net
    fi
done

# Delete directories
sudo rm -rf /opt/metal3-dev-env
sudo rm -rf "$(dirname "$0")/_clouds_yaml"

# Stop and delete minikube cluster
minikube stop
minikube delete --all --purge

# Stop and delete containers
containers=("sushy-tools" "ironic-ipa-downloader" "ironic" "keepalived" "registry" "ironic-client" "httpd-infra" "fake-ipa")
for container in "${containers[@]}"; do
    echo "Deleting the container: $container"
    sudo podman stop "$container" &>/dev/null
    sudo podman rm "$container" &>/dev/null
done
