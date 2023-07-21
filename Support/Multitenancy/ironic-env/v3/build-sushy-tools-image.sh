#!/bin/bash
#
# SUSHYTOOLS_DIR="$HOME/sushy-tools-19"
SUSHYTOOLS_DIR="$HOME/sushy-tools"
rm -rf "$SUSHYTOOLS_DIR"
git clone https://opendev.org/openstack/sushy-tools.git "$SUSHYTOOLS_DIR"
cd "$SUSHYTOOLS_DIR" || exit
git fetch https://review.opendev.org/openstack/sushy-tools refs/changes/66/875366/25 && git cherry-pick FETCH_HEAD

pip3 install build
python3 -m build

cd dist || exit
WHEEL_FILENAME=$(ls ./*.whl)
echo "$WHEEL_FILENAME"

cd ..

cat <<EOF > "${SUSHYTOOLS_DIR}/Dockerfile"
# Use the official Centos image as the base image
FROM ubuntu:22.04

# Install necessary packages
RUN apt update -y && \
    apt install -y python3 python3-pip python3-venv && \
    apt clean all

WORKDIR /opt

# RUN python3 setup.py install

# Copy the application code to the container
COPY dist/${WHEEL_FILENAME} .

RUN pip3 install ${WHEEL_FILENAME}

ENV FLASK_DEBUG=1

RUN mkdir -p /root/sushy

# Set the default command to run when starting the container
# CMD ["python3", "app.py"]
# CMD ["sleep", "infinity"]
CMD ["sushy-emulator", "-i", "::", "--config", "/root/sushy/conf.py"]
EOF

sudo podman build -t 127.0.0.1:5000/localimages/sushy-tools .
# rm -rf "$SUSHYTOOLS_DIR"
