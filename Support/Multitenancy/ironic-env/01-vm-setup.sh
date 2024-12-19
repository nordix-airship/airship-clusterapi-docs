set -e
#install kvm for minikube
dnf -y install qemu-kvm libvirt virt-install net-tools podman firewalld
systemctl enable --now libvirtd
systemctl start firewalld
systemctl enable firewalld
# create provisioning network
cat <<EOF >provisioning.xml
<network
	xmlns:dnsmasq='http://libvirt.org/schemas/network/dnsmasq/1.0'>
	<dnsmasq:options>
		<!-- Risk reduction for CVE-2020-25684, CVE-2020-25685, and CVE-2020-25686. See: https://access.redhat.com/security/vulnerabilities/RHSB-2021-001 -->
		<dnsmasq:option value="cache-size=0"/>
	</dnsmasq:options>
	<name>provisioning</name>
	<bridge name='provisioning'/>
	<forward mode='bridge'></forward>
</network>
EOF

cat <<EOF >baremetal.xml
<network xmlns:dnsmasq='http://libvirt.org/schemas/network/dnsmasq/1.0'>
  <name>baremetal</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='baremetal' stp='on' delay='0'/>
  <domain name='ostest.test.metalkube.org' localOnly='yes'/>
  <dns>
    <forwarder domain='apps.ostest.test.metalkube.org' addr='127.0.0.1'/>
  </dns>
  <ip address='192.168.111.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.111.20' end='192.168.111.60'/>
      <host mac='00:5c:52:31:3b:9c' name='node-0' ip='192.168.111.20'>
        <lease expiry='60' unit='minutes'/>
      </host>
      <host mac='00:5c:52:31:3b:ad' name='node-1' ip='192.168.111.21'>
        <lease expiry='60' unit='minutes'/>
      </host>
    </dhcp>
  </ip>
  <dnsmasq:options>
    <dnsmasq:option value='cache-size=0'/>
  </dnsmasq:options>
</network>
EOF
# define networks
virsh net-define baremetal.xml
virsh net-start baremetal
virsh net-autostart baremetal

virsh net-define provisioning.xml
virsh net-start provisioning
virsh net-autostart provisioning
tee -a /etc/NetworkManager/system-connections/provisioning.nmconnection <<EOF
[connection]
id=provisioning
type=bridge
interface-name=provisioning
[bridge]
stp=false
[ipv4]
address1=172.22.0.1/24
method=manual
[ipv6]
addr-gen-mode=eui64
method=disabled
EOF

chmod 600 /etc/NetworkManager/system-connections/provisioning.nmconnection
nmcli con load /etc/NetworkManager/system-connections/provisioning.nmconnection
nmcli con up provisioning

tee /etc/NetworkManager/system-connections/baremetal.nmconnection <<EOF
[connection]
id=baremetal
type=bridge
interface-name=baremetal
autoconnect=true
[bridge]
stp=false
[ipv6]
addr-gen-mode=stable-privacy
method=ignore
EOF

chmod 600 /etc/NetworkManager/system-connections/baremetal.nmconnection
nmcli con load /etc/NetworkManager/system-connections/baremetal.nmconnection
nmcli con up baremetal

# install minikube
curl -LO https://storage.googleapis.com/minikube/releases/v1.25.2/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
