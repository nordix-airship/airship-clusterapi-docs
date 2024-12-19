set -e

# Start Minikube with insecure registry flag
minikube start --insecure-registry 172.22.0.1:5000

# SSH into the Minikube VM and execute the following commands
sudo su -l -c "minikube ssh sudo brctl addbr ironicendpoint" "${USER}"
sudo su -l -c "minikube ssh sudo  ip link set ironicendpoint up" "${USER}"
sudo su -l -c "minikube ssh sudo  brctl addif  ironicendpoint eth2" "${USER}"
sudo su -l -c "minikube ssh sudo  ip addr add 172.22.0.2/24 dev ironicendpoint" "${USER}"

# Firewall rules
for i in 8000 80 9999 6385 5050 6180 53 5000; do sudo firewall-cmd --zone=public --add-port=${i}/tcp; done
for i in 8000 80 9999 6385 5050 6180 53 5000; do sudo firewall-cmd --zone=libvirt --add-port=${i}/tcp; done
for i in 69 547 546 68 67 5353 6230 6231 6232 6233 6234 6235; do sudo firewall-cmd --zone=libvirt --add-port=${i}/udp; done
sudo firewall-cmd --zone=libvirt --add-port=8000/tcp
