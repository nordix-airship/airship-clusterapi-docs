cd /opt/metal3-dev-env/ironic/html/images/
wget https://artifactory.nordix.org/artifactory/metal3/images/k8s_v1.24.1/CENTOS_9_NODE_IMAGE_K8S_v1.24.1.qcow2
qemu-img convert -O raw CENTOS_9_NODE_IMAGE_K8S_v1.24.1.qcow2 CENTOS_9_NODE_IMAGE_K8S_v1.24.1-raw.img
md5sum CENTOS_9_NODE_IMAGE_K8S_v1.24.1-raw.img | awk '{print $1}' > CENTOS_9_NODE_IMAGE_K8S_v1.24.1-raw.img.md5sum
cd -
