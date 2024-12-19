baremetal node delete default-node

./build-sushytools-image-with-fakeipa-changes.sh
SUSHY_TOOLS_IMAGE="127.0.0.1:5000/localimages/sushy-tools"

# Set configuration options
cp conf.py "$HOME/sushy-tools/conf.py"

# Create an htpasswd file
cat <<'EOF' >"$HOME/sushy-tools/htpasswd"
admin:$2b$12$/dVOBNatORwKpF.ss99KB.vESjfyONOxyH.UgRwNyZi1Xs/W2pGVS
EOF

podman stop fake-ipa
podman rm fake-ipa
podman run --entrypoint='["sushy-fake-ipa", "--config", "/root/sushy/conf.py"]' \
    -d --net host --name fake-ipa --pod infra-pod \
    -v "$HOME/sushy-tools:/root/sushy" \
    -v /root/.ssh:/root/ssh \
    "${SUSHY_TOOLS_IMAGE}"

mkdir /opt/metal3-dev-env/ironic/html/images
touch /opt/metal3-dev-env/ironic/html/images/image.qcow2
baremetal node create --driver redfish --driver-info \
redfish_address=http://192.168.111.1:8000 --driver-info \
redfish_system_id=/redfish/v1/Systems/27946b59-9e44-4fa7-8e91-f3527a1ef094 --driver-info \
redfish_username=admin --driver-info redfish_password=password \
--name default-node

baremetal node set default-node     --driver-info deploy_kernel="http://172.22.0.2:6180/images/ironic-python-agent.kernel"     --driver-info deploy_ramdisk="http://172.22.0.2:6180/images/ironic-python-agent.initramfs"
baremetal node set default-node       --instance-info image_source=http://172.22.0.1/images/image.qcow2     --instance-info image_checksum=http://172.22.0.1/images/image.qcow2