sudo virsh undefine node-1
sudo virsh undefine node-2

sudo nmcli con delete baremetal
sudo nmcli con delete provisioning
sudo nmcli con delete provisioning

sudo virsh net-undefine provisioning
sudo virsh net-undefine baremetal

sudo virsh net-destroy baremetal
sudo virsh net-destroy  provisioning

sudo ip link set provisioning down
sudo ip link set provisioning down
sudo ip link set baremetal down
sudo brctl delbr baremetal
sudo brctl delbr provisioning
sudo brctl delbr provisioning
sudo virsh vol-delete --pool  mypool node-1.qcow2
sudo virsh vol-delete --pool  mypool node-2.qcow2
sudo virsh pool-destroy mypool
sudo virsh pool-undefine mypool
sudo rm -rf  /opt/mypool
#sudo rm -rf /opt/metal3-dev-env
sudo rm -rf /opt/metal3-dev-env/ironic/virtualbmc/
sudo podman stop -a
sudo podman rmi $(sudo podman images -qa) -f

minikube stop
minikube delete --all --purge
