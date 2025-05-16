#!/bin/ksh
#
###################################################################################
#
# Configuration file for module "get_data"
#
###################################################################################
#
#
###################################################################################
# Begin of configuration script
#==================================================================================
if [ -z "$__DATA_CONF__" ]; then __DATA_CONF__=defined        # include-guard begin
###################################################################################
#
#
###################################################################################
# Module specific parameters
#==================================================================================
f_call_set_var DA_CLEANUP               1                            # options: 0|1
###################################################################################
#
#
###################################################################################
# Path specific parameters
#==================================================================================
f_call_set_var  DA_CONSTDIR        ${BA_PATH}/const
###################################################################################
#
#
###################################################################################
# Data base specific parameters
#==================================================================================
f_call_set_var DA_PAMORE_BIN       ${BA_PATH}/bin/pamore
f_call_set_var DA_STATROUGET_BIN   ${BA_PATH}/bin/stat_rou_get
f_call_set_var DA_STATROUGET_EBIN  ${BA_PATH}/bin/exp_stat_rou_get
f_call_set_var DA_BLKLST_BIN       ${BA_PATH}/bin/mk_blacklist
f_call_set_var DA_DC_MLD_BIN       ${BA_PATH}/bin/dc_mld
f_call_set_var DA_SAT_PP_BIN       ${BA_PATH}/bin/sat_pp
case "$BA_SITE_HPC" in
  DWD_CRAY-XC)
    f_call_set_var  DA_CDO_BIN    \
            /e/rhome/for0adm/lc/unsupported/cdo-1.6.3/bin/cdo
    ;;
  DWD_NEC-SX)
    f_call_set_var  DA_CDO_BIN    \
            /hpc/sw/cdo/2.2.0/x86/gnu/bin/cdo
    ;;
  HOREKA_CPU)
    f_call_set_var  DA_CDO_BIN    \
           /cdo_directory_on_horeka           # To do Xu
    ;; 
  LEONARDO_GPU)
    f_call_set_var  DA_CDO_BIN    \
           /leonardo/prod/spack/03/install/0.19/linux-rhel8-icelake/gcc-11.3.0/cdo-2.1.0-2ltng25xbm7yakxoon4dyehxev5ynaw2/bin/cdo
    ;;   
esac
###################################################################################
#
#
###################################################################################
# Observation specific parameters
#==================================================================================
#-choose-observations-to-obtain----------------------------------------------------
f_call_set_var DA_OBS_CONV              1                      # conventional (0|1)
f_call_set_var DA_OBS_RADAR             1                             # radar (0|1)
f_call_set_var DA_OBS_LIGHTNING         1                         # lightning (0|1)
f_call_set_var DA_OBS_LHN               1               # latent heat nudging (0|1)
f_call_set_var DA_OBS_MODES             1                             # MODES (0|1)
f_call_set_var DA_OBS_GNSS              1                 # GNSS ZTD (E-GVAP) (0|1)
f_call_set_var DA_OBS_SST               1                               # SST (0|1)
f_call_set_var DA_OBS_SMA               1                               # SMA (0|1)
f_call_set_var DA_OBS_SNOW              1                              # SNOW (0|1)
f_call_set_var DA_OBS_SEVIRI            0                            # SEVIRI (0|1)
#----------------------------------------------------------------------------------
f_call_set_var DA_BUFR2NC_JOBS          8      # parallel conversion BUFR -> NetCDF
#----------------------------------------------------------------------------------
f_call_set_var DA_LOGFILE_CORE_CONV_DB  $DA_IN_TOPATH/get_data_core_database.log
f_call_set_var DA_LOGFILE_CORE_CONV_B2N $DA_IN_TOPATH/get_data_core_bufr2netcdf.log
f_call_set_var DA_LOGFILE_CORE_SATPP    $DA_IN_TOPATH/get_data_core_satpp.log
#----------------------------------------------------------------------------------
f_call_set_var DA_LOGFILE_SNOW_MLD      $DA_IN_TOPATH/get_data_snow_mld.log
f_call_set_var DA_LOGFILE_SNOW_NMC      $DA_IN_TOPATH/get_data_snow_nmc.log
#----------------------------------------------------------------------------------
f_call_set_var DA_LOGFILE_SST_MLD       $DA_IN_TOPATH/get_data_sst_mld.log
f_call_set_var DA_LOGFILE_SST_NMC       $DA_IN_TOPATH/get_data_sst_nmc.log
#----------------------------------------------------------------------------------
f_call_set_var DA_LOGFILE_SMA_SFC       $DA_IN_TOPATH/get_data_sma_sfc.log
f_call_set_var DA_LOGFILE_SMA_CONV_B2N  $DA_IN_TOPATH/get_data_sma_bufr2netcdf.log
###################################################################################
#
#
###################################################################################
# Radar Data specific parameters
# DA_OBS_RADAR_FREQ is the interval which determines how often a radar sweep is
# stored, starting from each full hour, for the hourly files.
# DA_OBS_RADAR_INT is the interval for which radar obs are retrieved in one go via
# pshell (should adjusted to the total time interval). The used startdate is set to
# the beginning of the interval in which DA_IN_STARTDATE is and the enddate to the
# end of the interval in which DA_IN_ENDDATE is.
#==================================================================================
f_call_set_var -t DA_OBS_RADAR_FREQ        5min
f_call_set_var -t DA_OBS_RADAR_INT         3h
f_call_set_var    DA_OBS_RADAR_FMT         HDF5
###################################################################################
#
#
###################################################################################
# Boundary conditions specific parameters (MAIN runs regional models)
#==================================================================================
f_call_set_var -t DA_BC_MAIN_DET_FREQ      3h              # in multiples of 3h
f_call_set_var -t DA_BC_MAIN_ENS_FREQ      3h              # to trigger pamore call
###################################################################################
#
#
###################################################################################
# Core ENVAR specific parameters
#==================================================================================
f_call_set_var DA_LOGFILE_ENVAR_FG_SKY      $DA_IN_TOPATH/get_data_envar_fg_sky.log
###################################################################################
#
#
###################################################################################
# Interpolation specific parameters
#==================================================================================
case "$BA_SITE_HPC" in
  DWD_CRAY-XC)
    f_call_set_var  DA_I_REMAP_ATMO_BINARY   ${BA_ROUTFORFOX}/abs/iconremap_mpi
    f_call_set_var  DA_I_REMAP_SOIL_BINARY   \
            ${BA_ROUTFORFOX}/abs/interpolate_soil_flake
    ;;
  DWD_NEC-SX)
    f_call_set_var  DA_I_REMAP_ATMO_BINARY   ${BA_PATH}/bin/iconremap-2.5.1.a
    f_call_set_var  DA_I_REMAP_SOIL_BINARY   \
            ${BA_PATH}/bin/interpolate_soil_flake_V2_19
    ;;
  HOREKA_CPU)
    f_call_set_var  DA_I_REMAP_ATMO_BINARY   ${BA_PATH}/bin/iconremap_20210709
    f_call_set_var  DA_I_REMAP_SOIL_BINARY   \
	    ${BA_PATH}/bin/interpolate_soil_flake_V2_10  # To do Xu
   ;;   
  LEONARDO_GPU)
    f_call_set_var  DA_I_REMAP_ATMO_BINARY   ${BA_PATH}/bin/iconremap
    f_call_set_var  DA_I_REMAP_SOIL_BINARY   \
	    ${BA_PATH}/bin/interpolate_soil_flake_V2_10  # To do (copied from HOREKA)
   ;;  
esac
###################################################################################
#
#
###################################################################################
# Core blacklist specific parameters
#==================================================================================
f_call_set_var  DA_LOGFILE_CORE_BLACKLIST $DA_IN_TOPATH/get_data_core_blacklist.log
###################################################################################
#
#
###################################################################################
# SST blacklist specific parameters
#==================================================================================
f_call_set_var  DA_LOGFILE_SST_BLACKLIST   $DA_IN_TOPATH/get_data_sst_blacklist.log
###################################################################################
#
#
###################################################################################
# More specific parameters
#==================================================================================
f_call_set_var -t  DA_OPT_WAITTIME 24h         # Optional wait-time for model data
                                                # to be in database
###################################################################################
#
#
###################################################################################
# Data base specific parameters
#==================================================================================
#-source-of-model-files------------------------------------------------------------
f_call_set_var  DA_DB_SOURCE  rout # db suite; options: rout|para0|para1|numex|bacy
f_call_set_var  DA_DB_RUN     ass              # db run type; options: ass|pre|main
f_call_set_var  DA_EXP_SRC    11200   # source experiment; numex id or path to bacy
#----------------------------------------------------------------------------------
# source of SATPP feedback files
#----------------------------------------------------------------------------------
f_call_set_var  DA_I_SATPPALT  rout                     # options: rout|para0|para1
###################################################################################
#
#
###################################################################################
# End of configuration file
#==================================================================================
f_error_end_of_script
#----------------------------------------------------------------------------------
fi                                                              # include-guard end
###################################################################################
