#!/bin/bash

if [ -d "${PWD}/_clouds_yaml" ]; then
  MOUNTDIR="${PWD}/_clouds_yaml"
else
  echo "cannot find _clouds_yaml"
  exit 1
fi

if [ "$1" == "baremetal" ] ; then
  shift 1
fi

# shellcheck disable=SC2086
sudo podman run --net=host --tls-verify=false \
  -v "${MOUNTDIR}:/etc/openstack" --rm \
  -e OS_CLOUD="${OS_CLOUD:-metal3}" 127.0.0.1:5000/localimages/ironic-client "$@"
