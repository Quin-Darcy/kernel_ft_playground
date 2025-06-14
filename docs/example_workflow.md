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
tar -xf sources/kernels/your_kernel_source/linux-a.b.c.tar.gz workspace/current/
```
- If you are working with a cloned repo, just copy the source into the current workspace (I know this isn't very space efficient)
```bash
cp sources/kernels/linux-a.b.c workspace/current/
```

### Copying Patches into the Current Workspace
This repository comes with a few example patches which you can copy into the current workspace as well as any patches of your own.
```bash
# Create a folder to hold the patches
mkdir -p /workspace/current/linux-a.b.c/patches

# Copy the pathces into the root of your kernel
cp /workspace/patches/* /workspace/workspace/current/linux-a.b.c/patches/
```

### (Optional) Copying `.config` into the Current Workspace
This repository comes with a few example kernel configuration files you can use depending on the goal. These are located in `/workspace/workspace/configs`. If you don't want to create your own, you can copy one from here into the current workspace.
```bash
cp /workspace/workspace/configs/fips-minimal.config /workspace/workspace/current/linux-a.b.c/.config
```
