# simple makefile to make life easy

.PHONY: e2e run docker kind verify clean realclean
.PHONY: compose

e2e: run verify
	"e2e done!"

run: docker kind
	echo "Done!"

docker:
	cd k8s; ./run_docker.sh

kind:
	cd k8s; ./run_kind.sh

verify:
	#cd k8s; ./verify.sh

clean:
	cd k8s; ./clean.sh

realclean:
	cd k8s; ./clean.sh realclean

compose:
	sudo apt install -y docker-compose-plugin
