# HeliosXCore
![](docs/HeliosXCore/figures/HeliosXCore.png)
![](docs/HeliosXCore/figures/HeliosXCorePipeline.png)

**HeliosXCore** is a Superscalar Out-of-order RISC-V Processor Core.

Design Docs | [设计文档](docs/HeliosXCore.md)

Design Docs | [设计文档](docs/HeliosXCore.md)

## Directory Organization
- **3rd-party**: The third-party library code.
- **HeliosXEmulator**: Emulator submodule used for differential testing to verify correctness.
- **HeliosXSimulator**: Simulator submodule used for differential testing to verify correctness.
- **docs**: Project documents.
- **rtl**: CPU Core RTL source code.
- **scripts**: Scripts used for testing.
- **soc**: SoC RTL source code.
- **testbench**: Test and Bench code.


## Contribution
HeliosXCore development is based on the pull request on Github. 
1. Create a new branch:
```
git checkout -b <branch_name>
```
2. Create a Pull Request and receive code review from reviewers.
3. PR title shoule be concise since it is going to be the commit message in the main branch after merging and squashing.

