#!/bin/bash

PROVISIONED_FILE="/setup.complete"

set -e -x

provision() {

    sudo useradd llamaup -M -U
    sudo mkdir /home/llamaup
    sudo chown llamaup:llamaup /home/llamaup

    sudo apt remove needrestart -y
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install git -y
    sudo snap install cmake --classic
    sudo apt install clang make gcc g++ util-linux libstdc++-12-dev libopenblas-dev pkg-config docker.io -y

    wget https://github.com/etcd-io/etcd/releases/download/v3.5.4/etcd-v3.5.4-linux-amd64.tar.gz
    tar -xvf etcd-v3.5.4-linux-amd64.tar.gz
    sudo cp -a etcd-v3.5.4-linux-amd64/etcd etcd-v3.5.4-linux-amd64/etcdctl /usr/bin/

    sudo mkdir -p /var/lib/etcd/default
    sudo mkdir -p /etc/etcd/
    sudo chown -R ubuntu:ubuntu /var/lib/etcd
    sudo cp etcd.service /lib/systemd/system
    sudo systemctl daemon-reload
    sudo systemctl enable etcd.service


    #intel
    wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list
    sudo apt update -y
    sudo apt install intel-basekit -y


    # cuda
    sudo apt-key del 7fa2af80

    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
    sudo dpkg -i cuda-keyring_1.1-1_all.deb

    sudo apt upgrade -y
    sudo apt update -y
    sudo apt -y install cuda cuda-toolkit
    sudo cp intel_ld.conf /etc/ld.so.conf.d/
    sudo ldconfig

    # api server
    echo "deb http://openresty.org/package/debian bullseye openresty" | sudo tee /etc/apt/sources.list.d/openresty.list
    wget -O - https://openresty.org/package/pubkey.gpg | sudo apt-key add -
    wget -O - http://repos.apiseven.com/pubkey.gpg | sudo apt-key add -
    echo "deb http://repos.apiseven.com/packages/debian bullseye main" | sudo tee /etc/apt/sources.list.d/apisix.list
    sudo apt update -y
    sudo apt install -y apisix
    sudo cp apisix-conf.yaml /usr/local/apisix/conf/config.yaml
    sudo systemctl enable apisix
    sudo systemctl start etcd
    sudo systemctl start apisix

    THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    $THIS_SCRIPT_DIR/generate-certs.sh
    $THIS_SCRIPT_DIR/configure-apisix.sh

    sudo cp llamacpp.service /lib/systemd/system
    sudo systemctl daemon-reload
    sudo systemctl enable llamacpp

    # rocm not yet supported

    sudo mkdir -p /opt/llamaup/app
    sudo mkdir -p /opt/llamaup/data


    sudo touch $PROVISIONED_FILE
}

llamacpp_tag=$1
hw_platform=$2
model_url=$3
if [ ! -e $PROVISIONED_FILE ]; then
    provision
fi

cd /llama.up
sudo ./build_llamacpp.sh $llamacpp_tag $hw_platform $model_url
