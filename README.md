# kernel_ft_playground
An important skill for any cryptographic security tester is knowing how to perform functional testing of Linux kernels. But how does one come to acquire this skill? Among the list of answers to that question, this project hopes to sit comfortably and enticingly! 

### What is this Project?
By nature, working with kernels can be quite tricky and, depending on the environment, even risky! With the help of [Docker](https://www.docker.com/) and [QEMU](https://www.qemu.org/), this project allows you to learn, in a totally isolated and reproducible environment, the following concepts:
- The basics of the Linux kernel
  - Configuration
  - Compilation
  - Kernel modules
- The [Linux kernel cryptograhpic API](https://www.kernel.org/doc/html/v4.14/crypto/index.html)
  - Architecture
  - The Test Manager
  - Service Indicator
- Funcitonal Testing
  - Cryptographic Algorithm Known Answer Tests (KATs)
  - Integrity Verification Tests
  - FIPS Mode
  - Log Analysis
- Other Useful Skills
  - Archiving
  - Patching

Beyond what is listed above, one of the central goals of this project is to demonstrate a specific functional testing workflow that is intuitive, organized, and systematic. The hope being that it is equally educational as it is practical.

### Getting Started
To get started, follow the steps below.
1. Review the [system requirements and prerequisites](docs/sysreqs.md)
2. Clone the repository:
```bash
git clone https://github.com/Quin-Darcy/kernel_ft_playground.git
```
3. Read about the [project structure](workspace/README.md)
4. Follow along an [example workflow](docs/example_workflow.md)
