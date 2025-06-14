FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    gcc-11 g++-11 \
    software-properties-common \
    gcc-multilib \
    build-essential \
    bison flex \
    libncurses5-dev \
    libelf-dev \
    libssl-dev \
    bc \
    qemu-system-x86 \
    qemu-system-arm \
    python3 \
    minicom \
    git \
    libkcapi1 libkcapi-dev \
    wget curl \
    sudo \
    file \
    cpio gzip \
    make \
    binutils \
    openssl \
    kmod \
    util-linux \
    iproute2 \
    netcat-openbsd \
    vim \
    dnsmasq \
    iputils-ping \
    bash-completion \
    gdb \
    asciinema \
    cscope \
    ninja-build \
    pkg-config \
    libglib2.0-dev \
    libpixman-1-dev \
    lzop \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Use GCC 11 (2021) since we are using kernel version 5.14.0 (2021)
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 100

RUN echo 'export EDITOR=vim' >> /etc/bash.bashrc && \
    echo 'export KERNEL_TESTING_HOME=/workspace' >> /etc/bash.bashrc

ARG USER_UID
ARG USER_GID
RUN groupadd -g $USER_GID ubuntu || groupmod -g $USER_GID ubuntu || true
RUN useradd -u $USER_UID -g $USER_GID -ms /bin/bash ubuntu 2>/dev/null || \
    usermod -u $USER_UID -g $USER_GID ubuntu && \
    adduser ubuntu sudo && \
    echo -n 'ubuntu:ubuntu' | chpasswd

RUN sed -i.bkp -e \
      's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' \
      /etc/sudoers

USER ubuntu
WORKDIR /workspace

RUN echo 'echo ""' >> ~/.bashrc && \
    echo 'echo "=== Kernel Testing Environment ==="' >> ~/.bashrc && \
    echo 'echo "Working directory: $(pwd)"' >> ~/.bashrc && \
    echo 'echo "Kernel sources go in: sources/kernels/"' >> ~/.bashrc && \
    echo 'echo "Working area: workspace/current/"' >> ~/.bashrc && \
    echo 'echo ""' >> ~/.bashrc
