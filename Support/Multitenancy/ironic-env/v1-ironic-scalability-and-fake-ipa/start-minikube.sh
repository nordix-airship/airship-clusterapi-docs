#!/bin/bash
set -e

# Start Minikube with insecure registry flag
minikube start --insecure-registry 172.22.0.1:5000

# SSH into the Minikube VM and execute the following commands
sudo su -l -c "minikube ssh sudo brctl addbr ironicendpoint" "${USER}"
sudo su -l -c "minikube ssh sudo  ip link set ironicendpoint up" "${USER}"
sudo su -l -c "minikube ssh sudo  brctl addif  ironicendpoint eth2" "${USER}"

read -ra PROVISIONING_IPS <<< "${IRONIC_ENDPOINTS}"
for PROVISIONING_IP in "${PROVISIONING_IPS[@]}"; do
  sudo su -l -c "minikube ssh sudo  ip addr add ${PROVISIONING_IP}/24 dev ironicendpoint" "${USER}"
done

# Firewall rules
for i in 8000 80 9999 6385 5050 6180 53 5000; do sudo firewall-cmd --zone=public --add-port=${i}/tcp; done
for i in 69 547 546 68 67 5353 6230 6231 6232 6233 6234 6235; do sudo firewall-cmd --zone=libvirt --add-port=${i}/udp; done

for i in $(seq 1 "${N_SUSHY:-1}"); do
  port=$(( 8000 + i ))
  sudo firewall-cmd --zone=public --add-port=$port/tcp
  sudo firewall-cmd --zone=libvirt --add-port=$port/tcp
done