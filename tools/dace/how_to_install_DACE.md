# DACE Installation Guide for Leonardo HPC

## Prerequisites
- Access to Leonardo HPC at CINECA
- Work directory: `/leonardo_work/DE360_GLORI/smr_prod/dace`
- Basic familiarity with Linux environment and module system

## 1. Environment Setup

### Load Required Modules
```bash
module load profile/meteo
module load intel-oneapi-compilers/2023.2.1
module load intel-oneapi-mpi/2021.10.0
module load netcdf-c/4.9.2--intel-oneapi-mpi--2021.10.0--oneapi--2023.2.0
module load netcdf-fortran/4.6.1--intel-oneapi-mpi--2021.10.0--oneapi--2023.2.0
module load eccodes/2.33.0--intel-oneapi-mpi--2021.10.0--oneapi--2023.2.0
module load intel-oneapi-mkl
```

Verify loaded modules:
```bash
module list
```

It should return:
```bash
 Currently Loaded Modulefiles:
 1) profile/base                      6) bzip2/1.0.8--oneapi--2023.2.0-775effc    11) c-blosc/1.21.5--oneapi--2023.2.0-e7safqx                               16) netcdf-c/4.9.2--intel-oneapi-mpi--2021.10.0--oneapi--2023.2.0        
 2) cintools/1.0                      7) lz4/1.9.4--oneapi--2023.2.0-whwwyrc      12) pkgconf/1.9.5-gr2lx34                                                  17) netcdf-fortran/4.6.1--intel-oneapi-mpi--2021.10.0--oneapi--2023.2.0  
 3) profile/meteo                     8) snappy/1.1.10--oneapi--2023.2.0-ta4wo5m  13) hdf5/1.14.3--intel-oneapi-mpi--2021.10.0--oneapi--2023.2.0             18) openjpeg/2.3.1--oneapi--2023.2.0-63yr4zj                             
 4) intel-oneapi-compilers/2023.2.1   9) zlib-ng/2.1.4--oneapi--2023.2.0          14) libaec/1.0.6--oneapi--2023.2.0-ohnhau5                                 19) eccodes/2.33.0--intel-oneapi-mpi--2021.10.0--oneapi--2023.2.0        
 5) intel-oneapi-mpi/2021.10.0       10) zstd/1.5.5--oneapi--2023.2.0-7fv2v7i     15) parallel-netcdf/1.12.3--intel-oneapi-mpi--2021.10.0--oneapi--2023.2.0  20) intel-oneapi-mkl/2023.2.0           
```

Set Compiler Environment Variables:
```bash
export CC=icc
export FC=ifort
export F90=ifort
export F77=ifort
```

Verify compiler paths:
```bash
which $CC
which $FC
which $F77
which $F90
```

They should return:
```bash
/leonardo/prod/spack/5.2/install/0.21/linux-rhel8-icelake/gcc-8.5.0/intel-oneapi-compilers-2023.2.1-iwg23xx5a2h5fwje4542ggaspe2iartp/compiler/2023.2.1/linux/bin/intel64/icc
/leonardo/prod/spack/5.2/install/0.21/linux-rhel8-icelake/gcc-8.5.0/intel-oneapi-compilers-2023.2.1-iwg23xx5a2h5fwje4542ggaspe2iartp/compiler/2023.2.1/linux/bin/intel64/ifort
/leonardo/prod/spack/5.2/install/0.21/linux-rhel8-icelake/gcc-8.5.0/intel-oneapi-compilers-2023.2.1-iwg23xx5a2h5fwje4542ggaspe2iartp/compiler/2023.2.1/linux/bin/intel64/ifort
/leonardo/prod/spack/5.2/install/0.21/linux-rhel8-icelake/gcc-8.5.0/intel-oneapi-compilers-2023.2.1-iwg23xx5a2h5fwje4542ggaspe2iartp/compiler/2023.2.1/linux/bin/intel64/ifort
```

## 2. Directory Preparation
```bash
cd /leonardo_work/DE360_GLORI/smr_prod/dace
tar -xvzf cgribex-2.0.0.tar.gz
unzip dace_code-dace-dev.zip

mkdir -p install/{lib,include,bin,share}
```

## 3. Library Linking
Link NetCDF and eccodes libraries:
```bash
# NetCDF C
ln -s $NETCDF_C_HOME/include/* include/
ln -s $NETCDF_C_HOME/lib/lib* lib/
ln -s $NETCDF_C_HOME/bin/* bin/

# NetCDF Fortran
ln -s $NETCDF_FORTRAN_HOME/include/* include/
ln -s $NETCDF_FORTRAN_HOME/lib/lib* lib/
ln -s $NETCDF_FORTRAN_HOME/bin/* bin/

# eccodes
ln -s $ECCODES_HOME/include/* include/
ln -s $ECCODES_HOME/lib64/lib* lib/
ln -s $ECCODES_HOME/bin/* bin/
```

### Verify links
```bash
ls include
```
should return:
```bash
eccodes_config.h          eccodes.mod        grib_api.h       netcdf4_nc_interfaces.mod  netcdf_dispatch.h      netcdf_filter.h                 netcdf.h       netcdf_mem.h   netcdf_nc_data.mod        netcdf_nf_interfaces.mod
eccodes_ecbuild_config.h  eccodes_version.h  grib_api.mod     netcdf4_nf_interfaces.mod  netcdf_f03.mod         netcdf_filter_hdf5_build.h      netcdf.inc     netcdf_meta.h  netcdf_nc_interfaces.mod  netcdf_par.h
eccodes.h                 eccodes_windef.h   netcdf4_f03.mod  netcdf_aux.h               netcdf_filter_build.h  netcdf_fortv2_c_interfaces.mod  netcdf_json.h  netcdf.mod     netcdf_nf_data.mod        typesizes.mod
```

```bash
ls bin
```
should return:
```bash
bufr_compare      bufr_dump         bufr_ls            codes_info        grib_compare  grib_filter     grib_index_build  grib_to_netcdf  gts_dump    metar_compare  metar_get  nccopy  nf-config
bufr_compare_dir  bufr_filter       bufr_set           codes_parser      grib_copy     grib_get        grib_ls           gts_compare     gts_filter  metar_copy     metar_ls   ncdump
bufr_copy         bufr_get          codes_bufr_filter  codes_split_file  grib_count    grib_get_data   grib_merge        gts_copy        gts_get     metar_dump     nc4print   ncgen
bufr_count        bufr_index_build  codes_count        grib2ppm          grib_dump     grib_histogram  grib_set          gts_count       gts_ls      metar_filter   nc-config  ncgen3
```

```bash
ls lib
```
should return:
```bash
libeccodes.a      libeccodes_f90.so  libnetcdf.a   libnetcdff.settings  libnetcdff.so.7      libnetcdf.la        libnetcdf.so     libnetcdf.so.19.2.2
libeccodes_f90.a  libeccodes.so      libnetcdff.a  libnetcdff.so        libnetcdff.so.7.2.0  libnetcdf.settings  libnetcdf.so.19
```

## 4. CGRIBEX Compilation

```bash
cd cgribex-2.0.0/
./configure --prefix=/leonardo_work/DE360_GLORI/smr_prod/dace/install \
            CFLAGS="-D_FILE_OFFSET_BITS=64"
make
make install
```

Verification:
```bash
nm install/lib/libcgribex.a | grep pbseek64
ls install/lib/libcgribex.a
ls install/include/cgribex.h
```

They should return:
```bash
0000000000000280 T pbseek64_
/leonardo_work/DE360_GLORI/smr_prod/dace/install/lib/libcgribex.a
/leonardo_work/DE360_GLORI/smr_prod/dace/install/include/cgribex.h
```

## 5. DACE Compilation
Update Library Path
```bash
export LD_LIBRARY_PATH=/leonardo_work/DE360_GLORI/smr_prod/dace/install/lib:$LD_LIBRARY_PATH
```

### Configure DACE
Backup and then modify the configuration file:
```bash
dace_code-dace-dev/config/mh-linux-x64
```

Its new content should be the following:
```bash
# Compiler and host-specific configuration
ARCH    = LINUX64

CC      = icc
CFLAGS  = -O -g -std=c99
CFDEFS  = -DpgiFortran

GRIBROOT    = /leonardo_work/DE360_GLORI/smr_prod/dace/install
GRIB_LIBDIR = ${GRIBROOT}/lib
GRIB_LIB    = -L$GRIBROOT/lib -lcgribex
GRIBAPIROOT = ${GRIBROOT}
GRIBAPI_LIB = -L$(GRIBAPIROOT)/lib -lgrib_api_f90 -lgrib_api -Wl,-R$(GRIBAPIROOT)/lib

FC      = ifort
F77     = ifort
F90     = ifort

F90FLAGS   = -cpp
FFLAGS     = $FFLAGS -O -fp-model precise -g -traceback
F90FLAGS   = $F90FLAGS -stand=f03 -diag-disable 6477,7025 -O -xHost -g -traceback \
             -DUSE_PBSEEK64 -DHAVE_MAXRSS -DNO_RTTOV -D_RTTOV_DO_DISTRIBCOEF \
             -DGRIB_API -DNOBUFR
```

### Build DACE

```bash
cd dace_code-dace-dev
./configure CC=icc F90=ifort FC=ifort \
    --prefix=/leonardo_work/DE360_GLORI/smr_prod/dace/install \
    CFLAGS=-I/leonardo_work/DE360_GLORI/smr_prod/dace/install/include \
    LDFLAGS=-L/leonardo_work/DE360_GLORI/smr_prod/dace/install/lib \
    --enable-feature=intel-mpi \
    --with-rttov12=no \
    --with-rttov10=no \
    --with-netcdf4=/leonardo_work/DE360_GLORI/smr_prod/dace/install \
    --with-eccodes=/leonardo_work/DE360_GLORI/smr_prod/dace/install

make
```

### Verification
After successful compilation, verify the installation:
```bash
ls install/bin/var3d  # Should show the main executable
```
