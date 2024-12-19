set -e
virsh attach-interface --domain minikube --model virtio --source provisioning --type network --config
virsh attach-interface --domain minikube --model virtio --source provisioning --type network --config
virsh attach-interface --domain minikube --model virtio --source baremetal --type network --config
# Download images
podman run -d -p 5000:5000 --name registry docker.io/library/registry:2.7.1
# Create pods 
podman pod create -n infra-pod || true
podman pod create -n ironic-pod || true
# Pull images
mkdir -p /opt/metal3-dev-env/ironic/html/images
podman pull quay.io/metal3-io/vbmc
podman pull quay.io/metal3-io/sushy-tools
podman pull quay.io/metal3-io/ironic-ipa-downloader
podman pull quay.io/metal3-io/ironic:latest
podman pull quay.io/metal3-io/ironic-client
podman pull quay.io/metal3-io/keepalived
podman tag quay.io/metal3-io/vbmc 127.0.0.1:5000/localimages/vbmc
podman tag quay.io/metal3-io/sushy-tools 127.0.0.1:5000/localimages/sushy-tools
podman tag quay.io/metal3-io/ironic-ipa-downloader 127.0.0.1:5000/localimages/ironic-ipa-downloader
podman tag quay.io/metal3-io/ironic-client 127.0.0.1:5000/localimages/ironic-client
podman tag quay.io/metal3-io/keepalived 127.0.0.1:5000/localimages/keepalived
podman tag quay.io/metal3-io/ironic:latest 127.0.0.1:5000/localimages/ironic:latest
podman push --tls-verify=false 127.0.0.1:5000/localimages/keepalived
podman push --tls-verify=false 127.0.0.1:5000/localimages/ironic-client
podman push --tls-verify=false 127.0.0.1:5000/localimages/ironic:latest
podman push --tls-verify=false 127.0.0.1:5000/localimages/ironic-ipa-downloader
podman push --tls-verify=false 127.0.0.1:5000/localimages/sushy-tools
podman push --tls-verify=false 127.0.0.1:5000/localimages/vbmc
# Run host services
# Run httpd
podman run -d --net host --name httpd-infra --pod infra-pod -v /opt/metal3-dev-env/ironic:/shared -e PROVISIONING_INTERFACE=provisioning -e LISTEN_ALL_INTERFACES=false --entrypoint /bin/runhttpd 127.0.0.1:5000/localimages/ironic:latest
podman run -d --net host --name httpd-infra2 --pod infra-pod -v /opt/metal3-dev-env/ironic:/shared -e PROVISIONING_INTERFACE=provisioning -e LISTEN_ALL_INTERFACES=false --entrypoint /bin/runhttpd 127.0.0.1:5000/localimages/ironic:latest
# Run vbmc and sushy-tools 
mkdir /opt/metal3-dev-env/ironic/virtualbmc
mkdir /opt/metal3-dev-env/ironic/virtualbmc/vbmc
mkdir /opt/metal3-dev-env/ironic/virtualbmc/vbmc/conf
mkdir /opt/metal3-dev-env/ironic/virtualbmc/vbmc/log
mkdir /opt/metal3-dev-env/ironic/virtualbmc/sushy-tools
chmod -R 755 /opt/metal3-dev-env/ironic/virtualbmc
cat <<EOF > /opt/metal3-dev-env/ironic/virtualbmc/vbmc/virtualbmc.conf
[default]
config_dir=/root/.vbmc/conf/
[log]
logfile=/root/.vbmc/log/virtualbmc.log
debug=True
[ipmi]
session_timout=20
EOF
mkdir -p /opt/metal3-dev-env/ironic/virtualbmc/vbmc/conf/node-1
mkdir -p /opt/metal3-dev-env/ironic/virtualbmc/vbmc/conf/node-2
cat <<EOF > /opt/metal3-dev-env/ironic/virtualbmc/vbmc/conf/node-1/config
[VirtualBMC]
username = admin
password = password
domain_name = node-1
libvirt_uri = qemu+ssh://root@192.168.111.1/system?&keyfile=/root/ssh/id_rsa_virt_power&no_verify=1&no_tty=1
address = 192.168.111.1
active = True
port =  6230
EOF

cat <<EOF > /opt/metal3-dev-env/ironic/virtualbmc/vbmc/conf/node-2/config
[VirtualBMC]
username = admin
password = password
domain_name = node-2
libvirt_uri = qemu+ssh://root@192.168.111.1/system?&keyfile=/root/ssh/id_rsa_virt_power&no_verify=1&no_tty=1
address = 192.168.111.1
active = True
port =  6231
EOF
cat <<EOF > /opt/metal3-dev-env/ironic/virtualbmc/sushy-tools/conf.py
SUSHY_EMULATOR_LIBVIRT_URI = "qemu+ssh://root@192.168.111.1/system?&keyfile=/root/ssh/id_rsa_virt_power&no_verify=1&no_tty=1"
SUSHY_EMULATOR_IGNORE_BOOT_DEVICE = False
SUSHY_EMULATOR_VMEDIA_VERIFY_SSL = False
SUSHY_EMULATOR_AUTH_FILE = "/root/sushy/htpasswd"
EOF
cat <<'EOF' > /opt/metal3-dev-env/ironic/virtualbmc/sushy-tools/htpasswd
admin:$2b$12$/dVOBNatORwKpF.ss99KB.vESjfyONOxyH.UgRwNyZi1Xs/W2pGVS
EOF
ssh-keygen -f /root/.ssh/id_rsa_virt_power -P ""
cat /root/.ssh/id_rsa_virt_power.pub | tee -a /root/.ssh/authorized_keys
podman run -d --net host --name vbmc --pod infra-pod      -v /opt/metal3-dev-env/ironic/virtualbmc/vbmc:/root/.vbmc -v "/root/.ssh":/root/ssh      127.0.0.1:5000/localimages/vbmc
podman run -d --net host --name sushy-tools --pod infra-pod      -v /opt/metal3-dev-env/ironic/virtualbmc/sushy-tools:/root/sushy -v "/root/.ssh":/root/ssh      127.0.0.1:5000/localimages/sushy-tools
# Add vbmc client
cat <<'EOF' > vbmc.sh
#!/bin/bash
sudo podman exec -ti vbmc vbmc "$@"
EOF
chmod a+x vbmc.sh
ln -sf $PWD/vbmc.sh /usr/local/bin/vbmc
yum install -y OpenIPMI ipmitool
ipmitool -I lanplus -U admin -P password -H 192.168.111.1 -p 6230 power on
virsh list --all
