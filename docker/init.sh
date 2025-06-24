#!/bin/bash

# SEtup environment variables
export USER_UID=$(id -u)
export USER_GID=$(id -g)

docker compose build

mkdir -p ../workspace/{current,builds,initramfs,configs}
mkdir -p ../workspace/initramfs/{init_templates,builds,base}
mkdir -p ../sources/{kernels,initramfs}
mkdir -p ../patches/{examples}
mkdir -p ../tools/{scripts}
mkdir -p ../logs

docker compose run --rm kernel-build
