#!/bin/bash

# Auto-generate build name with timestamp
CUSTOM_STRING=""    # To indicate the type of patch applied
KERNEL_VERSION=$(make kernelversion)
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BUILD_NAME="linux-${KERNEL_VERSION}-${CUSTOM_STRING}-${TIMESTAMP}"

echo "Archiving build as: $BUILD_NAME"

BUILD_DIR="../../builds/$BUILD_NAME"
mkdir -p "$BUILD_DIR"

# Copy files into buildd dir
cp arch/x86/boot/bzImage "$BUILD_DIR/"
cp .config "$BUILD_DIR/"
make INSTALL_MOD_PATH="$BUILD_DIR/modules" modules_install

# Generate HMAC for kerne binary
openssl dgst -sha512 -hmac "FIPS-KEY" "$BUILD_DIR/bzImage" > "$BUILD_DIR/bzImage.hmac"

echo "Build archived to: workspace/builds/$BUILD_NAME/"
