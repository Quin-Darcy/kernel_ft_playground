# Example Workflow
Below is a demonstation of a full functional testing session using this project and its recommended workflow. 

> **NOTE:** *These instructions assume you are starting in the project's root folder.*

## Initial Setup - Getting Everything in Place
### Obtaining the Kernel Source
In practice, there are two main ways to get your hands on Linux kernel source code:
1. Tarball: You either download a `.tar.gz` file or are given one by a vendor.
2. Cloned from repo: Just as you cloned this repository, you clone the repository containing the kernel source you want to test.
   
### Storing the Source 
- If you were given a tarball, create a new folder in the `sources/kernels/` directory to hold the tarball. For example, if the tarball contains `linux-a.b.c`, then
```bash
# Create the new folder
mkdir -p sources/kernels/linux-a.b.c/

# Copy the tarball into the new folder
cp /path/to/linux-a.b.c.tar.gz sources/linux-a.b.c/
```
- If you are cloning from a repository, simply navigate into the `sources/kernels/` directory, then run the clone command.
```bash
# Navigate to sources
cd /path/to/this/project/sources/kernels/

# Clone the repo holding the kernel you're testing
git clone https://github.com/somebody/linux.git
```

### Getting Patches 
If you have any patches of your own, copy them into the `patches/` folder. It is recommended, to create a subfolder to store these patches for better organization. For example, you can create a subfolder indicating the kerne version these patches apply to.
```bash
# Create the folder to hold your pathces
mkdir -p /path/to/this/project/patches/linux-a.b.c/

# Copy your patches
cp /path/to/your/patches/* /path/to/this/project/patches/linux-a.b.c/
```

### Download the Alpine Linux minimal root filesystem (Only once)
This downloads a tiny, but complete userspace environment. It's what gives us a shell ontop of the kernel we are testing. This only needs to be downloaded once as it simply provides the shell. However, if you prefer another userspace provider, it should go in the same folder `sources/initramfs/`.
```bash
wget -P sources/initramfs/ https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-minirootfs-3.19.7-x86_64.tar.gz
```
## Prepping our Containerized Workspace
### Starting the Container
The first time you start the container, it will take a while for it to be ready. Because of caching, subsequent starts will be almost instant.
- Navigate into the `docker/` folder and run the initialization script.
```bash
chmod +x init.sh
```
```bash
cd docker && ./init.sh
```
If you want to know more about the docker container that is created, check out the following [documentation](../docker/README.md).

### Copying Source into Current Workspace
At this point, we want to copy the extracted (if applicable) source code into our work area. We perform a copy so that the original source is untouched and archived. 
- If you are working with a tarball, extract it into the current workspace.
```bash
tar -xf sources/kernels/linux-a.b.c/linux-a.b.c.tar.gz workspace/current/
```
- If you are working with a cloned repo, just copy the source into the current workspace (I know this isn't very space efficient)
```bash
cp -r sources/kernels/linux-a.b.c workspace/current/
```

### Copying Patches into the Current Workspace
This repository comes with a few example patches which you can copy into the current workspace as well as any patches of your own.
```bash
# Create a folder to hold the patches
mkdir -p workspace/current/linux-a.b.c/patches

# Copy the pathces you need into the root of your kernel
cp patches/examples/some-patch.patch workspace/current/linux-a.b.c/patches/
cp patches/linux-a.b.c/another-patch.patch workspace/current/linux-a.b.c/patches/
...
```

## Configuring the Kernel
### (Optional) Copying `.config` into the Current Workspace
This repository comes with a few example kernel configuration files you can use depending on the goal. These are located in `workspace/configs`. If you don't want to create your own, you can copy one from here into the current workspace.
```bash
cp workspace/configs/fips-minimal.config workspace/current/linux-a.b.c/.config
```
Skip the next step if you decided to copy the kernel config.

### Manual Configuration
There are many ways to configure the kernel but below will be how to create a minimal kernel for FIPS functional testing.
1. Navigate to the root of your kernel source tree.
2. Clean the whole folder
```bash
make mrproper
```
3. Create a minimal config file
```bash
make tinyconfig
```
The resultant `.config` is not ready for funcitonal testing. A number of config options need to be set first.
4. Tweak the configuration file with menuconfig
```bash
make menuconfig
```
5. Set the following config options:
   - Enable `64-bit kernel` option.
   - Enable `General setup` -> `Initial RAM filesystem and RAM disk (initramfs/initrd)`
   - Enable `General setup` -> `Configure standard kernel features` -> `support for printk`
   - Enable `Enable loadable module support` -> `Module signature verification`
   - Enable `Executable file format` -> `Kernel support for ELF binaries`
   - Enable `Device drivers` -> `Character devices` -> `TTY`
   - Enable `Device drivers` -> `Character devices` -> `Serial drivers` ->
      - `8250/16550 and compatible serial support`
      - `Console on 8250/16550 and compatible serial support`
   - Enable `File systems` -> `Pseudo filesystems` ->
      - `/proc file system support`
      - `sys file system support`
   - Enable `Cryptographic API` -> `Crypto core or helper` -> `Enable cryptographic self-tests`
   - Enable `Cryptographic API` -> all the crypto algos you want to test
   - Save and exit
  
6. Open the `.config` file
```bash
vim .config
```
7. Edit the last config item to make the crypto manager a loadable module.
```bash
CONFIG_CRYPTO_MANAGER=m`
```
> The reason for step 7 is because by making the crypto manager a module, we can then pass in module parameters in the boot arguments. If the crypto manager was built-in, the module paramaters which our patches create for testing purposes would be inaccessible.

## Build and Archive the Kernel
At this point, the tedious setup is done and you should close your computer for 6 minutes and focus on your breath before coming back. Pay attention to the sensation of air around your nostrils. If you start to think of something else, without judgement, label it "thinking", then bring your attention back to the sensation. Even if you find yourself having 1000 thoughts, simply label it without judgement and bring your focus back to the sensation.

### Applying the Patches
We will apply all the patches to the kernel. The effect of each patch is activated based on the boot argument we pass in. For those taking the educational route, each patch should be inspected and applied manually in case there is an error or issue. Inspect the patch file to see how it specifies the file it applies to
```bash
# From the root rolder of the kernel source - Scooby doo
cd workspace/current/linux-a.b.c/crypto

# Apply patch to the file located in patch header
patch target_file.c < ../patches/example.patch
```
Repeat the above for each patch.

### Compile the Kernel
We are approaching the last few steps! Compile the kernel and throw all your cores at it!
```bash
make -j$(nproc)
```

### Archiving the Kernel
Assuming the build was nice and successful, we will now 'save our work'. 
1. Copy the `archive-build.sh` script out of the `/workspace/tools/scripts/` folder into the root of the kernel source.
```bash
cp /workspace/tools/scripts/archive-build.sh ./
```
Running this script will copy the compiled kernel binary into the `/workspace/workspace/builds` folder along with the HMAC of the binary and the module files.
> There is a special string option to add if you edit the `archive-build.sh` script. This is recommended to help further contextualize the build.

2. Run the script
```bash
./archive-build.sh
```
3. This script will output a "build name". Store it in environmental variable
```bash
BUILD="/workspace/workspace/builds/linux-a.b.c-20250614-SOMETHING-14053/bzImage"
```

## Creating the initramfs
### Creating the initramfs Image (Only once)
The extracted Alpine filesystem will function as a *base filesystem* for our initramfs, which means we only need one copy of it and can re-use across different functional testing sessions. However, what is changeable is the `init` script in the filesystem. It is the first thing to run when we boot. This can be as simple or complex as we want. There are a few template `init` scripts in `workspace/initramfs/init_templates`. For now, we will explicitly show how to create one.
1. First, extract the filesystem into the base folder
```bash
tar -xzf sources/initramfs/alpine-minirootfs-3.19.7-x86_64.tar.gz workspace/initramfs/base/
```
2. Write a small custom script into the `init` file of the filesystem
```bash
cat > workspace/initramfs/base/init << 'EOF'
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

echo "=== Kernel Infformation ==="
echo "Kernel: $(uname -r)"

echo "=== Basic FIPS Status ==="
if [ -f /proc/sys/crypto/fips_enabled ]; then
    FIPS_STATUS=$(cat /proc/sys/crypto/fips_enabled)
    echo "FIPS enabled: $FIPS_STATUS"

    if [ "$FIPS_STATUS" = "1" ]; then
        echo "FIPS mode is ACTIVE"
        echo
        echo "Available crypto algorithms:"
        grep "^name" /proc/crypto | head -10
        echo
    else
        echo "FIPS mode is INACTIVE"
    fi
else
    echo "FIPS support not available"
fi

echo "=== Done ==="
echo "Type 'exit' to shutdown"
exec /bin/sh
EOF
```
> Alternatively, you can review the pre-existing `init` templates in `workspace/initramfs/init_templates` and simply copy one to overwrite the `init` file in the base filesystem instead of manually writing over it as we did in step 2.

3. Create a compressed `initramfs` image
```bash
find workspace/initramfs/base | cpio -o -H newc | gzip > workspace/initramfs/builds/alpine-basic-fips.cpio.gz
```
4. Store the `initramfs` path in an environment variable
```bash
INITRAMFS=/workspace/workspace/initramfs/builds/alpine-basic-fips.cpio.gz
```
And we have created our `initramfs`! Subsequent `initramfs` images can be created by selecting or creating a new `init` script and overwriting the one in the base folder, then re-running the command in step 3 with the updated name for the actual `initramfs` image.

## Performing the Tests
Now we near the end and present various boot commands for different tests. But first, we need to prep for logging!

### Logging
The boot logs are the most important artifcats from this whole session and are what allows us to actually determine if the functional testing passed or not. 
1. Using the same `$BUILD` environment variable we set earlier, create a directory to store the functional testing logs
```bash
mkdir -p /workspace/logs/$BUILD
```
2. Store the log path in an environment variable
```bash
LOG=/workspace/logs/$BUILD/
```

### Booting and Selecting the Tests
With environment variables set, the following commands are all the same but for the particular module paramter we invoke as means of selecting the test to be performed. Below are some example commands which invoke differet tests.
```bash
# Basic test
qemu-system-x86_64 \
   -kernel $BUILD \
   -initrd $INITRAMFS \
   -nographic \
   -append "console=ttyS0 fips=1" \
   -m 1G | tee "$LOG/basic.log"

# Algorithm failure test
qemu-system-x86_64 \
   -kernel $BUILD \
   -initrd $INITRAMFS \
   -nographic \
   -append "console=ttyS0 fips=1 fips_fail_kats=1" \
   -m 1G | tee "$LOG/kat-fails.log"

# Specific algorithm failure test
qemu-system-x86_64 \
   -kernel $BUILD \
   -initrd $INITRAMFS \
   -nographic \
   -append "console=ttyS0 fips=1 cryptomgr.fips_tinker=aes-generic" \
   -m 1G | tee "$LOG/aes-failure.log"

# Panic prevention test  
qemu-system-x86_64 \
   -kernel $BUILD \
   -initrd $INITRAMFS \
   -nographic \
   -append "console=ttyS0 fips=1 fips_fail_kats=1 cryptomgr.fips_prevent_panic=1" \
   -m 1G | tee "$LOG/panic-prevention.log"
```

### Analyzing the Logs
The logs will be located in the `$LOG` folder. Opening this you can see the logs from the various tests performed. TBD
