set -e
sudo ./01-vm-setup.sh
./02-configure-minikube.sh
sudo ./03-images-and-run-local-services.sh
./04-start-minikube.sh
./05-apply-manifests.sh
