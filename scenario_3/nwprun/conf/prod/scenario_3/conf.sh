# Model environment variables
MODEL_BASE=/leonardo_work/DE360_GLORI/mkrayer0/icon-nwp/build/leo.gpu.nvhpc-2024-09-18-eccodes2.35-c14ffcdb70
MODEL_BIN=$MODEL_BASE/bin/icon
ECRAD_DATA=$MODEL_BASE/data
MODEL_STATIC=$WORKDIR_BASE/data/icon
PARENTMODEL_DATADIR=$WORKDIR/input/data

# Local installation of iconremap
module load profile/meteo
module load netcdf-c/4.9.2--intel-oneapi-mpi--2021.10.0--oneapi--2023.2.0
module load netcdf-fortran/4.6.1--intel-oneapi-mpi--2021.10.0--oneapi--2023.2.0
module load eccodes/2.25.0--gcc--11.3.0
module load cdo/2.1.0--gcc--11.3.0
export LD_LIBRARY_PATH=/leonardo_work/smr_prod/lami/srcintel/eccodes-2.32.0/lib64:/leonardo_work/smr_prod/lami/srcintel/install/lib:$LD_LIBRARY_PATH
MODEL_PRE_BINDIR=/leonardo_work/smr_prod/lami/srcintel/icontools-2.5.0/icontools
#MODEL_PRE_BINDIR=/leonardo_work/DE360_GLORI/smr_prod/lam_bacy/tests/dwd_icon_tools/icontools

# Working directories for observations
BUFR_WORKDIR=$WORKDIR/bufr
MODEL_LHN_WORKDIR=$WORKDIR/lhn
HDF5_WORKDIR=$WORKDIR/radar_vol

# Dataset arkimet for observations
BUFR_ARKI_DS_CONV=$ARKI_DIR/gts_bufr_conv
BUFR_ARKI_DS_NOCONV=$ARKI_DIR/gts_bufr_noconv
BUFR_ARKI_DS_RADARVOL=$ARKI_DIR/radar_vol
ARKI_LHN_DS=$ARKI_DIR/scenario_3_radar
MODEL_LHN_DT=600
FREQ_FILE_BUFR=1 #improve

# Working directories for ICON and its preprocessing
MODEL_PRE_WORKDIR=$WORKDIR/preicon
MODEL_PRE_DATADIR=$WORKDIR/preicon/data
MODEL_WORKDIR=$WORKDIR/icon
MODEL_DATADIR=$WORKDIR/icon/data

# ICON-2I domain and grid files
DOMAIN=ICON_GLORI_A
LOCALGRID=$MODEL_STATIC/domain_$DOMAIN/${DOMAIN}.nc
LOCALGRID_PARENT=$MODEL_STATIC/domain_$DOMAIN/${DOMAIN}.parent.nc
LOCALGRID_EXTERNAL=$MODEL_STATIC/domain_$DOMAIN/external_parameter_icon_${DOMAIN}_tiles.nc

# Time step
TIME_STEP=20

# Specifics for IAU initialization
ASS_CYCLE_LENGTH=1
DT_IAU=600

# eccodes definitions
ECCODES_DEFINITION_PATH=$ECCODES_DEFINITIONS_DWD:$ECCODES_DEFINITIONS_BASE

# Generating process
MODEL_ASSIM_GP=61
MODEL_ASSIM_INC_GP=61
MODEL_FCAST_GP=62
MODEL_FCRUC_GP=64
MODEL_FCENS_GP=65
MODEL_FCI2I_GP=66
MODEL_INTER_GP=63
MODEL_ARKI_TGP_ASSIM=0
MODEL_ARKI_TGP_ASSIM_INC=201
MODEL_ARKI_TIMERANGE_ASSIM="origin:GRIB2,,,0,,$MODEL_ASSIM_GP"
MODEL_ARKI_TIMERANGE_ASSIM_INC="origin:GRIB2,,,201,,$MODEL_ASSIM_INC_GP"
MODEL_ARKI_TIMERANGE_FCAST="origin:GRIB2,,,2,,$MODEL_FCAST"
ANA_EXT=0000
ANA_DET_EXT=.det
IMPORT_THREAD=output

# postprocessing
CROSS_COORD_FILE=$WORKDIR_BASE/nwprun/conf/cross.shp
# start output at beginning by default
OUTPUT_START=0

# Stop for experiments
STOP_ON_FAIL=Y
