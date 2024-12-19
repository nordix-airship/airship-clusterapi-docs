#!/bin/bash

SUSHYTOOLS_DIR="$HOME/sushy-tools" || true
rm -rf "$SUSHYTOOLS_DIR"
git clone https://opendev.org/openstack/sushy-tools.git "$SUSHYTOOLS_DIR"
cd "$SUSHYTOOLS_DIR" || exit
git fetch https://review.opendev.org/openstack/sushy-tools refs/changes/66/875366/38 && git cherry-pick FETCH_HEAD

cd ..

cat <<EOF >"$HOME/Dockerfile"
FROM docker.io/library/python:3.9
RUN mkdir -p /root/sushy
COPY sushy-tools /root/sushy/sushy_tools
RUN apt update -y && \
    apt install -y python3 python3-pip python3-venv && \
    apt clean all
WORKDIR /root/sushy/sushy_tools
RUN python3 -m pip install .
RUN python3 setup.py install

ENV FLASK_DEBUG=1


CMD ["sushy-emulator", "-i", "::", "--config", "/root/sushy/conf.py"]
EOF

sudo podman build -t 127.0.0.1:5000/localimages/sushy-tools .
