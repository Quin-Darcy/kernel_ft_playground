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

### Download the Alpine Linux minimal root filesystem (Only once)
This downloads a tiny, but complete userspace environment. It's what gives us a shell ontop of the kernel we are testing. This only needs to be downloaded once as it simply provides the shell. However, if you prefer another userspace provider, it should go in the same folder `sources/initramfs/`.
```bash
wget -P sources/initramfs/ https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-minirootfs-3.19.7-x86_64.tar.gz
```

### Getting Patches 
If you have any patches of your own, copy them into the `patches/` folder. It is recommended, to create a subfolder to store these patches for better organization. For example, you can create a subfolder indicating the kerne version these patches apply to.
```bash
# Create the folder to hold your pathces
mkdir -p /path/to/this/project/patches/linux-a.b.c/

# Copy your patches
cp /path/to/your/patches/* /path/to/this/project/patches/linux-a.b.c/
```

### Starting the Container
The first time you start the container, it will take a while for it to be ready. Because of caching, subsequent starts will be almost instant.
- Navigate into the `docker/` folder and run the initialization script.
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
cp sources/kernels/linux-a.b.c workspace/current/
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

## Building the Kernel
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
