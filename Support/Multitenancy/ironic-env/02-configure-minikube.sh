set -e
minikube config set driver kvm2
minikube config set memory 4096
sudo usermod --append --groups libvirt "$(whoami)"
while /bin/true; do
  minikube_error=0
  minikube start --insecure-registry 172.22.0.1:5000 || minikube_error=1
  if [[ $minikube_error -eq 0 ]]; then
    break
  fi
  sudo su -l -c 'minikube delete --all --purge' "${USER}"
  sudo ip link delete virbr0
done
minikube stop
