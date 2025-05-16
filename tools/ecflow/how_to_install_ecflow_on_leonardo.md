# ecFlow Installation Guide for Leonardo HPC (CINECA)

This document provides step-by-step instructions for installing ecFlow and its dependencies on Leonardo HPC at CINECA. The installation includes Boost, ecBuild, and ecFlow with Python bindings.

## Prerequisites

Before beginning:
1. Request appropriate compute/scratch space on Leonardo
2. Ensure you have module loading privileges
3. Prepare your work directory: `/leonardo_work/DE360_GLORI/smr_prod/scenarios/tools/`

## 1. Required Downloads

Download these packages to your work directory:

| Package | Version | Download URL |
|---------|---------|--------------|
| Boost   | 1.86.0  | [Boost Download](https://www.boost.org/users/history/version_1_86_0.html) |
| ecFlow  | Latest  | [GitHub](https://github.com/ecmwf/ecflow) |
| ecBuild | Latest  | [GitHub](https://github.com/ecmwf/ecbuild) |

```bash
# Example download commands:
wget https://boostorg.jfrog.io/artifactory/main/release/1.86.0/source/boost_1_86_0.tar.bz2
git clone https://github.com/ecmwf/ecflow.git
git clone https://github.com/ecmwf/ecbuild.git
```

## 2. Environment Setup

Load required modules:
```bash
module load profile/meteo
module load python/3.11.6--gcc--8.5.0
module load cmake/3.27.7
```

Set environment variables:
```bash
export BOOST_ROOT=/leonardo_work/DE360_GLORI/smr_prod/scenarios/tools/installed_boost
export CMAKE_PREFIX_PATH=$BOOST_ROOT/include/boost/python:$CMAKE_PREFIX_PATH
export PREFIX=/leonardo_work/DE360_GLORI/smr_prod/scenarios/tools/ecflow
export WK=/leonardo_work/DE360_GLORI/smr_prod/scenarios/tools/ecflow
export PATH=/leonardo_work/DE360_GLORI/smr_prod/scenarios/tools/ecbuild/bin:$PATH
```

## 3. Boost Installation

### 3.1 Python Configuration

Create `~/user-config.jam` with:
```bash
    using python
    : 3.11
    : /leonardo/prod/spack/5.2/install/0.21/linux-rhel8-icelake/gcc-8.5.0/python-3.11.6-i5k3c6ggftqkzgqyymfbkynpgm2lgjtd/bin/python
    : /leonardo/prod/spack/5.2/install/0.21/linux-rhel8-icelake/gcc-8.5.0/python-3.11.6-i5k3c6ggftqkzgqyymfbkynpgm2lgjtd/include/python3.11
    : /leonardo/prod/spack/5.2/install/0.21/linux-rhel8-icelake/gcc-8.5.0/python-3.11.6-i5k3c6ggftqkzgqyymfbkynpgm2lgjtd/lib
    ;
```

### 3.2 Build and Install

```bash
cd /leonardo_work/DE360_GLORI/smr_prod/scenarios/tools/
tar --bzip2 -xf boost_1_86_0.tar.bz2
cd boost_1_86_0

./bootstrap.sh --prefix=$BOOST_ROOT \
    --with-libraries=system,timer,filesystem,program_options,chrono,date_time,python

./b2 cxxflags="-fPIC" cflags="-fPIC" install -j4 2>&1 | tee install_boost_output.txt
```

## 4. Python Virtual Environment

```bash
cd /leonardo_work/DE360_GLORI/smr_prod/scenarios/tools/
python3 -m venv --system-site-packages venv_ecflow
source venv_ecflow/bin/activate
pip3 install boto3
```


## 5. ecBuild Setup

```bash
cd /leonardo_work/DE360_GLORI/smr_prod/scenarios/tools/
unzip ecbuild-develop.zip  # or use git clone if downloaded via git
mv ecbuild-develop ecbuild
```


## 6. ecFlow Installation

```bash
cd /leonardo_work/DE360_GLORI/smr_prod/scenarios/tools/
unzip ecflow-develop.zip  # or use git clone if downloaded via git
mv ecflow-develop ecflow
cd ecflow

cmake -B build -S . \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DENABLE_UI=ON \
    -DPython3_EXECUTABLE=$WK/venv_ecflow/bin/python \
    -DENABLE_TESTS=OFF \
    -DBOOST_ROOT=$BOOST_ROOT

cmake --build build -j4
cmake --build build --target install

# Add to PYTHONPATH
export PYTHONPATH=$PYTHONPATH:$PREFIX/lib/python3.11/site-packages/ecflow
```


## Verification

Test your installation:

```bash
ecflow_client --version
python3 -c "import ecflow; print(ecflow.__file__)"
```