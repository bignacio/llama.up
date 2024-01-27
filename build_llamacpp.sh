#!/bin/bash
set -e -x

llamacpp_tag=$1
hw_platform=$2
model_url=$3

build_cuda() {
    export PATH=/usr/local/cuda-12.3/bin${PATH:+:${PATH}}
    export LD_LIBRARY_PATH=/usr/local/cuda-12.3/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

    cmake -B build -DLLAMA_CUBLAS=ON
    cmake --build build --config Release -- -j8
}

build_intel() {
    source /opt/intel/oneapi/mkl/latest/env/vars.sh
    source /opt/intel/oneapi/setvars.sh

    cmake -B build -DLLAMA_BLAS=ON -DLLAMA_BLAS_VENDOR=Intel10_64lp -DCMAKE_C_COMPILER=icx -DCMAKE_CXX_COMPILER=icpx -DLLAMA_NATIVE=ON
    cmake --build build --config Release -- -j8
}

build_openblas() {
    cmake -B build -DLLAMA_BLAS=ON -DLLAMA_BLAS_VENDOR=OpenBLAS
    cmake --build build --config Release -- -j8
}


# stop the service if running
if systemctl list-units --type=service --all | grep -q "llamacpp"; then
    systemctl stop "llamacpp"
fi

cd /opt/llamaup/app

if [ -d "llama.cpp" ]; then
    cd llama.cpp
    git reset --hard
    git pull origin $llamacpp_tag
else
    git clone --depth=1  --branch $llamacpp_tag https://github.com/ggerganov/llama.cpp
    git config --global --add safe.directory /opt/llamaup/app/llama.cpp
    cd llama.cpp
fi


rm -rf build

echo "building for hardware platform $hw_platform"

if [ "$hw_platform" == "cuda" ]; then
    build_cuda
elif [ "$hw_platform" == "intel" ]; then
    build_intel
elif [ "$hw_platform" == "openblas" ]; then
    build_openblas
else
    # build openblas by default if no platform specified or is unknown
    build_openblas
fi

wget $model_url -O /opt/llamaup/data/model.gguf

chown -R llamaup:llamaup /opt/llamaup
systemctl restart llamacpp