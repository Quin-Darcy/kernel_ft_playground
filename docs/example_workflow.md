# Example Workflow
Below is a demonstation of a full functional testing session using this project and its recommended workflow.

### Obtaining the Kernel Source
In practice, there are two main ways to get your hands on Linux kernel source code:
1. Tarball: You either download a `.tar.gz` file or are given one by a vendor.
2. Cloned from repo: Just as you cloned this repository, you clone the repository containing the kernel source you want to test.
   
### Storing the Source 
- If you were given a tarball, create a new folder in the `sources/` directory to hold the tarball. For example, if the tarball contains `linux-a.b.c`, then
```bash
# Create the new folder
mkdir -p sources/linux-a.b.c/

# Copy the tarball into the new folder
cp /path/to/linux-a.b.c.tar.gz sources/linux-a.b.c/
```
- If you are cloning from a repository, simply navigate into the `sources/` directory, then run the clone command.
```bash
# Navigate to sources
cd /path/to/this_project/sources/

# Clone the repo holding the kernel you're testing
git clone https://github.com/somebody/linux.git
```
