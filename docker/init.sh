#!/bin/bash

# SEtup environment variables
export USER_UID=$(id -u)
export USER_GID=$(id -g)

echo "=== Linux Kernel Testing Environment ==="
echo "Setting up Docker environement ..."

echo "Building container ..."
docker compose build

echo "Setting up workspace structure ..."
mkdir -p ../workspace/{current,builds,initramfs,configs}
mkdir -p ../sources/{kernels,initramfs}
mkdir -p ../patches/{examples}
mkdir -p ../tools/{scripts}
mkdir -p ../logs

echo "Starting container..."
docker compose run --rm kernel-build
