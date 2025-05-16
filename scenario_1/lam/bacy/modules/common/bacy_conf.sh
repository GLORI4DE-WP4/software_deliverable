#!/bin/ksh
#
###################################################################################
#
# Configuration file for "bacy"
#
# USAGE: source ./bacy_conf.sh model
#
#   - 'model': NWP model; options: ICON|COSMO|ICON-LAM
#
# DESCRIPTION: collects parameters needed for more than one module
#
# HISTORY:
#
#   - troesch  2017/04: first version for unified bacy BACY_1.0
#   - troesch  2018/01: 'model' as input argument added
#   - vbachman 2018/07: new variables for ART mode
#
###################################################################################
#
#
###################################################################################
# Begin of configuration script
#==================================================================================
if [ -z "$__BACY_CONF__" ]; then __BACY_CONF__=defined              # include-guard
###################################################################################
#
#
###################################################################################
# Module root path
#==================================================================================
BA_ROOT=$(cd $(dirname ${.sh.file}) && pwd) || exit 1
###################################################################################
#
#
###################################################################################
# For error handling
#==================================================================================
source $BA_ROOT/error_fcns.sh
trap 'f_error_handler $LINENO ER_msg' ERR
f_error_push_stacks SCRIPT "$0" "${.sh.file}"
###################################################################################
#
#
###################################################################################
# Checking input arguments
#==================================================================================
if [ "$#" -ne 1 ]; then
  f_error_set_msg_and_send 1 ER_msg \
    "Wrong number ($#) of arguments while sourcing" \
    "'${.sh.file}'."
fi
#----------------------------------------------------------------------------------
case "$1" in
  !(ICON|COSMO|ICON-LAM))
    f_error_set_msg_and_send 1 ER_msg \
      "Wrong value ($1) for first input argument while sourcing" \
      "'${.sh.file}'."
esac
###################################################################################
#
#
###################################################################################
# site and hpc specific parameter(s)
#==================================================================================
f_call_set_var BA_SITE_HPC    LEONARDO_GPU   # DWD_CRAY-XC|ECMWF_CRAY-XC|DWD_NEC-SX|HOREKA_CPU|LEONARDO_GPU
case "$BA_SITE_HPC" in
  DWD_CRAY-XC)
    f_call_set_var  BA_PATH        /lustre2/uwork/fe12bacy/BACY
    ;;
  DWD_NEC-SX)
    f_call_set_var  BA_PATH        /hpc/uwork/fe11bacy/bacy_data
    ;;
  HOREKA_CPU)
    f_call_set_var  BA_PATH        /directory_on_horeka	  
    ;;	
  LEONARDO_GPU)
    f_call_set_var  BA_PATH        /leonardo_work/DE360_GLORI/smr_prod/scenarios/scenario_1/bacy_data
    ;;
esac
###################################################################################
#
#
###################################################################################
# Surface analysis specific parameters
#==================================================================================
f_call_set_var  BA_RUN_SST   0                        # 0|1: 1 enables SST analysis
f_call_set_var  BA_RUN_SMA   0                        # 0|1: 1 enables SMA analysis
f_call_set_var  BA_RUN_SNW   0     # 0|1|2: '1' warm start using fg, '2' cold start
###################################################################################
#
#
###################################################################################
# routine specific parameters
#==================================================================================
f_call_set_var BA_ROUTFORFOX   ${BA_PATH}/routforfox
f_call_set_var BA_ROUTFOXFOX   ${BA_PATH}/routfoxfox
###################################################################################
#
#
###################################################################################
# COSMO specific parameters
#==================================================================================
if [[ "$1" = COSMO ]]; then
#==================================================================================
f_call_set_var  BA_C_COSMO_SETUP  D2                               # options: DE|D2
#==================================================================================
fi
###################################################################################
# ICON specific parameters
#==================================================================================
f_call_set_var  BA_ICON_CENTRE    78       # options: 78 (DWD)|252 (MPI)|255 (None)
#----------------------------------------------------------------------------------
f_call_set_var  BA_ICON_GRIDDIR   ${BA_ROUTFOXFOX}/icon/grids/public/edzw
f_call_set_var  BA_ICON_INVARDIR  ${BA_PATH}/invar_dir
f_call_set_var  BA_ICON_EXTPARDIR ${BA_PATH}/extpar_dir
# cwelzbac: starting from BA_ICON_EXTPARVER 20200527 the ICON-D2 grid was slightly
# enlarged (grid number 0044 -> 0047)
# tsteiner: starting from BA_ICON_EXTPARVER 20220601 the MERIT/REMA orography
# rawdata replace the GLOBE rawdata
case "$1" in
  ICON)     f_call_set_var  BA_ICON_EXTPARVER  20220601;;
  ICON-LAM) f_call_set_var  BA_ICON_EXTPARVER  20200527;;
esac
#==================================================================================
if [[ "$1" = @(ICON|ICON-LAM) ]]; then
#==================================================================================
case "$1" in                                                          # grid number
  ICON)
    f_call_set_var  BA_I_GNUM_DET   0026                     # ICON (deterministic)
    f_call_set_var  BA_I_GNUM_ENS   0036                          # ICON (ensemble)
    ;;
  ICON-LAM)
    f_call_set_var  BA_I_GNUM_DET   1000                 # ICON-LAM (deterministic)
    f_call_set_var  BA_I_GNUM_ENS   1000                      # ICON-LAM (ensemble)
    ;;
esac
#----------------------------------------------------------------------------------
f_call_set_var  BA_I_USE_OWN_GRIDS     0            # 0|1: 1 use self defined grids
if [ "$BA_I_USE_OWN_GRIDS" -eq 1 ]; then
  f_call_set_var  BA_I_GRID_DET[0]   "icon_grid_0025_R03B06_R.nc"       # rad. grid
  f_call_set_var  BA_I_GRID_DET[1]   "icon_grid_0026_R03B07_G.nc"       # ICON grid
  f_call_set_var  BA_I_GRID_DET[2]   "icon_grid_0027_R03B08_N02.nc"     # nest grid
#----------------------------------------------------------------------------------
  f_call_set_var  BA_I_GRID_ENS[0]   "icon_grid_0023_R02B05_R.nc"       # rad. grid
  f_call_set_var  BA_I_GRID_ENS[1]   "icon_grid_0024_R02B06_G.nc"       # ICON grid
  f_call_set_var  BA_I_GRID_ENS[2]   "icon_grid_0028_R02B07_N02.nc"     # nest grid
fi
###################################################################################
# IAU specific parameters
#==================================================================================
case "$1" in                                                          # window size
  ICON)
    case "$BA_I_GNUM_DET" in
      0036)  f_call_set_var -t  BA_I_IAU_W_DELTA_DET  10560s;;
      *)     f_call_set_var -t  BA_I_IAU_W_DELTA_DET  10800s;;
    esac
    case "$BA_I_GNUM_ENS" in
      0036)  f_call_set_var -t  BA_I_IAU_W_DELTA_ENS  10560s;;
      *)     f_call_set_var -t  BA_I_IAU_W_DELTA_ENS  10800s;;
    esac
    ;;
  ICON-LAM)
    case "$BA_I_GNUM_DET" in
      0042)  f_call_set_var -t  BA_I_IAU_W_DELTA_DET  720s;;
      *)     f_call_set_var -t  BA_I_IAU_W_DELTA_DET  0s;;
    esac
    case "$BA_I_GNUM_ENS" in
      0042)  f_call_set_var -t  BA_I_IAU_W_DELTA_ENS  720s;;
      *)     f_call_set_var -t  BA_I_IAU_W_DELTA_ENS  600s;;
    esac
    ;;
esac
((BA_I_IAU_W_DELTA_DET > 0)) && BA_I_IAU_W_SHIFT_DET=$((BA_I_IAU_W_DELTA_DET / 2)) \
                             || BA_I_IAU_W_SHIFT_DET=0
((BA_I_IAU_W_DELTA_ENS > 0)) && BA_I_IAU_W_SHIFT_ENS=$((BA_I_IAU_W_DELTA_ENS / 2)) \
                             || BA_I_IAU_W_SHIFT_ENS=0
f_report_var    BA_I_IAU_W_SHIFT_DET                          # window shift in [s]
f_report_var    BA_I_IAU_W_SHIFT_ENS                          # window shift in [s]
#----------------------------------------------------------------------------------
f_call_set_var  BA_I_USE_TILES    1
#----------------------------------------------------------------------------------
case "$1" in
  ICON)     f_call_set_var  BA_I_NEST  1;;
  ICON-LAM) f_call_set_var  BA_I_NEST  1;;
esac
#==================================================================================
fi
###################################################################################
# CLIMA specific parameters
#==================================================================================
f_call_set_var  BA_RUN_PDAF        0                 # 0|1: 1 enables PDAF analysis
f_call_set_var  BA_I_CLIMA_INIT    RESTART  # initialization options: CLIMA|RESTART
f_call_set_var  BA_I_RESTART_MODE  SYNC     # restart_write_mode options:
                                                 # SYNC: sync. mode
                                                 # DEDICATED: async. mode, mulifile
f_call_set_var  BA_I_NUDGING       0         # 0|1: 1 enables atmos. Nudging (ERA5)
###################################################################################
# ART specific parameters
#==================================================================================
f_call_set_var  BA_I_ART            0                         # switch for ART mode
f_call_set_var  BA_I_ART_MODE       DUST               # options: DUST|SALT|SEASALT
# add suffix '.UR' for coldstart of ART fields or to omit the ART specific
# fields from database requests in get_data, i.e: DUST.UR or SALT.UR
# use delimiter '+' to activate multiple modes, i.e: DUST+SALT or DUST.UR+SALT
f_call_set_var  BA_I_ART_EXTPARDIR  ${BA_PATH}/const/ART
case "$1" in
  ICON)     f_call_set_var  BA_I_ART_EXTPARVER  20220302;;
  ICON-LAM) f_call_set_var  BA_I_ART_EXTPARVER  20201105;;
esac
###################################################################################
# Ocean specific parameters
#==================================================================================
f_call_set_var  BA_RUN_OCEAN        0                 # 0|1: enables ocean coupling
###################################################################################
#
#
###################################################################################
# ICON-LAM variable and microphysics specific parameters
# QX_ANA    0: no QX increments used/produced, 1: use QX increments  (CORE+MORE)
# GSCP_2MOM 0: 1MOM, 1: no num.concentr. (diagnose in MORE), 2: with num.concentr.
# usage of BA_IL_GSCP_2MOM>0 requires adequate ICON and DACE binaries
#==================================================================================
if [ "$1" = ICON-LAM ]; then
#==================================================================================
f_call_set_var  BA_IL_QI_ANA     1                                 # options: 0|1
f_call_set_var  BA_IL_QRSG_ANA   0                                 # options: 0|1
f_call_set_var  BA_IL_GSCP_2MOM  0                                 # options: 0|1|2
#==================================================================================
fi
###################################################################################
#
#
###################################################################################
# Observation processing specific parameters in local model (COSMO or ICON-LAM)
#==================================================================================
if [[ "$1" = @(COSMO|ICON-LAM) ]]; then
#==================================================================================
case "$1" in
  COSMO)
    f_call_set_var BA_L_OBSDIR[CONV]  ${BA_PATH}/obs_local/2019_june_cd2
    f_call_set_var BA_L_OBSDIR[LHN]   ${BA_L_OBSDIR[CONV]}/lhn_cd2
    ;;
  ICON-LAM)
    f_call_set_var BA_L_OBSDIR[CONV]  ${BA_PATH}/obs_local/2020_august_september
    f_call_set_var BA_L_OBSDIR[LHN]   ${BA_L_OBSDIR[CONV]}/lhn_icond2
    ;;
esac
f_call_set_var BA_L_OBSDIR[MODES]     ${BA_L_OBSDIR[CONV]}
f_call_set_var BA_L_OBSDIR[RADAR]     ${BA_L_OBSDIR[CONV]}/radar_qc_dt5
f_call_set_var BA_L_OBSDIR[SEVIRI]    ${BA_L_OBSDIR[CONV]}/seviri_3chans
f_call_set_var BA_L_OBSDIR[LIGHTNING] ${BA_PATH}/obs_local/obs_misc/lightning
f_call_set_var BA_L_OBSDIR[GPSGB]     ${BA_L_OBSDIR[CONV]}
f_call_set_var BA_L_OBSDIR[MWRGB]     ${BA_PATH}/obs_local/obs_misc/mwrgb
f_call_set_var BA_L_OBSDIR[IRS]       ${BA_PATH}/obs_local/obs_misc/irs
f_call_set_var BA_L_OBSDIR[IASI]      ${BA_PATH}/obs_local/obs_misc/iasi
#==================================================================================
f_call_set_var BA_MODES_IN_CONV            .TRUE.
#==================================================================================
f_call_set_var BA_L_USE[CONV]              1          # options:  1 (online active)
f_call_set_var BA_L_USE[RADWINDVOL]        1          #          2 (online passive)
f_call_set_var BA_L_USE[RADREFLVOL]        1          #          3 (online monitor)
f_call_set_var BA_L_USE[RADWINDPRECIP]     7          #      4 (offline/MEC active)
f_call_set_var BA_L_USE[RADREFLPRECIP]     7          #     5 (offline/MEC passive)
f_call_set_var BA_L_USE[OBJECT]            7          #     6 (offline/MEC monitor)
f_call_set_var BA_L_USE[K3DFeature]        7          #              7 (off/forget)
f_call_set_var BA_L_USE[SEVIRI_VIS]        1
f_call_set_var BA_L_USE[SEVIRI_WV]         1
f_call_set_var BA_L_USE[IRS]               7
f_call_set_var BA_L_USE[IASI]              7
f_call_set_var BA_L_USE[LIGHTNING]         7
f_call_set_var BA_L_USE[GPS_STD]           7
f_call_set_var BA_L_USE[GPS_ZTD]           7
f_call_set_var BA_L_USE[SYNOP_T2M]         1
f_call_set_var BA_L_USE[SYNOP_RH2M]        1
f_call_set_var BA_L_USE[MWRGB]             7
f_call_set_var BA_L_USE_DACE_OP            "AIREP"    # use dace obs. oper. (AIREP)
#==================================================================================
# use feedback files as input for MEC
f_call_set_var BA_L_USE_FDBK               0            #   0/1    not use/use fdbk
f_call_set_var BA_L_FDBKDIR                ${BA_PATH}/obs_local/nature_data
#==================================================================================
# Channels to simulate for SEVIRI (this setting is only relevant for offline MEC)
f_call_set_var BA_SEVIRI_CHANNEL[0]     "1"
f_call_set_var BA_SEVIRI_CHANNEL[1]     "5"
f_call_set_var BA_SEVIRI_CHANNEL[2]     "6"
#==================================================================================
# RTTOV DATA PATH
f_call_set_var BA_RTTOV_PATH  ${BA_ROUTFORFOX}/rttov/const/rt13coeffs_rttov7pred54L
###################################################################################
#
#
###################################################################################
# Local model specific parameters for radar/sinfony output
#==================================================================================
# Radar usage of observation (cdfin-files) in MAIN mode. If not used, list in
# namelist_iconlam_main.rad is used for beam configuration and station information
f_call_set_var BA_L_MAIN_RADOBS            0          #   0/1    not/use radar obs
#==================================================================================
# Radar Refl composite output in more for ASS/MAIN mode
f_call_set_var BA_L_OUT[VOLCOMP_ASS]       0          #   0/1    no/write composite
f_call_set_var BA_L_OUT[VOLCOMP_MAIN]      0          #   0/1    no/write composite
f_call_set_var BA_L_OUT[PRECIPCOMP_ASS]    0          #   0/1    no/write composite
f_call_set_var BA_L_OUT[PRECIPCOMP_MAIN]   0          #   0/1    no/write composite
#==================================================================================
# Radar Refl Volume composite list of output elevations for ASS/MAIN mode
f_call_set_var BA_VOLCOMPELE_OUT[0]      "1"
f_call_set_var BA_VOLCOMPELE_OUT[1]      "2"
#==================================================================================
# Radar output (cdfin) in more for ASS/MAIN mode
f_call_set_var BA_L_OUT[RADWINDVOL_ASS]       0       #                 0 no output
f_call_set_var BA_L_OUT[RADWINDVOL_MAIN]      0       #              1 write output
f_call_set_var BA_L_OUT[RADREFLVOL_ASS]       0       #
f_call_set_var BA_L_OUT[RADREFLVOL_MAIN]      0       #
f_call_set_var BA_L_OUT[RADWINDPRECIP_ASS]    0       #
f_call_set_var BA_L_OUT[RADWINDPRECIP_MAIN]   0       #
f_call_set_var BA_L_OUT[RADREFLPRECIP_ASS]    0       #
f_call_set_var BA_L_OUT[RADREFLPRECIP_MAIN]   0       #
#==================================================================================
# Compute radar composite with POLARA in more for ASS/MAIN mode
f_call_set_var BA_L_POLARACOMP_ASS        0           #   0/1  no/compute composite
f_call_set_var BA_L_POLARACOMP_MAIN       0
#==================================================================================
# Transfer volume scans and precip scans in MAIN for generation of Sinfony products
f_call_set_var BA_L_SINFONYPRODUCTS       0                  #   0/1 no/do products
#==================================================================================
# Write precipitation output for verification and LHN
f_call_set_var -t BA_DELT_PREC            0s                     # output frequency
#==================================================================================
#
#
###################################################################################
# POLARA specific parameter(s)
#==================================================================================
f_call_set_var BA_POLARA_EXECUTION         1 # 1=Container / 2=Level2-Server
f_call_set_var BA_POLARA_KONRAD_TRACKING   0 # 0=off / 1=on, avail. for container
f_call_set_var BA_POLARA_CG_PNG            0 # Produce png's for composites
                                             # 0=off / 1=on, avail. for container
f_call_set_var BA_POLARA_ASS_SERVER        oflxs386.dwd.de
f_call_set_var BA_POLARA_OBJEPROD_SERVER   oflxs295.dwd.de
f_call_set_var BA_POLARA_AREAPROD_SERVER   oflks439.dwd.de
f_call_set_var BA_POLARA_MOUNT_POINT       /hpc/uwork/sinfony/nfs_export_sinfony/

# Compute objects with POLARA in ASS mode at following time stepping
if [ "$BA_POLARA_KONRAD_TRACKING" -eq 0 ]; then
  f_call_set_var -t BA_L_OBJECTASS_DT      60min
else;
  f_call_set_var -t BA_L_OBJECTASS_DT       5min
fi
###################################################################################
fi
###################################################################################
#
#
###################################################################################
# Local model specific parameters
#==================================================================================
if [[ "$1" = @(COSMO|ICON-LAM) ]]; then
#==================================================================================
f_call_set_var  BA_L_USE_LBC       1          # 0|1 : enable dynamical lateral bc's
f_call_set_var  BA_L_BC_DIR        ${BA_PATH}/boundary_data
#----------------------------------------------------------------------------------
f_call_set_var  BA_L_BC_GNUM_DET    0027    # ICON gridnumber boundary fields (det)
f_call_set_var  BA_L_BC_GNUM_ENS    0037    # ICON gridnumber boundary fields (ens)
if [ "$BA_I_USE_OWN_GRIDS" -eq 1 ]; then
  f_call_set_var  BA_BC_GRID_DET    "icon_grid_0027_R03B08_N02.nc"   # LBC src grid
  f_call_set_var  BA_BC_GRID_ENS    "icon_grid_0037_R03B07_N02.nc"   # LBC src grid
fi
#----------------------------------------------------------------------------------
f_call_set_var  BA_L_BC_EXTPARVER   20220601            #  extpar version of source
f_call_set_var  BA_L_BC_I_N_LEVEL   120                 # vertical levels of source
                                                        #  (domain 1)
#----------------------------------------------------------------------------------
f_call_set_var  BA_L_BC_SRC_FNAME   'DBASE'    # filename source: 'BACY','DBASE'
                                               #   DBASE: e.g. iefff....
                                               #   BACY: e.g. fc_....
f_call_set_var  BA_L_BC_SRC_GLOBAL  0     # get boundary data from global data: 0|1
f_call_set_var  BA_L_BC_SRC_MODE    'MAIN'     # data source from -SAME:  same MODE
                                               #                   -ASS: ass  cycle
                                               #                  -MAIN: main cycle
#----------------------------------------------------------------------------------
f_call_set_var -t BA_BC_SRCTSHIFT      0h   # time shift to use boundary conditions
                                            # from earlier IGLO forecast for same
                                            # valid time (x*3h)
#==================================================================================
fi
###################################################################################
#
#
###################################################################################
# ensemble specific parameters
#==================================================================================
f_call_set_var BA_ENSIZE_ASS       0  # ensemble size (for assimilation forecasts)
#----------------------------------------------------------------------------------
case "$1" in
  COSMO|ICON-LAM)
    f_call_set_var BA_ENSIZE_MAIN      0      # ensemble size (for main forecasts)
    ;;
  ICON)
    f_call_set_var BA_ENSIZE_MAIN      0      # ensemble size (for main forecasts)
    ;;
esac
###################################################################################
#
#
###################################################################################
# assimilation specific path parameters
#==================================================================================
case "$1" in
  ICON) f_call_set_var BA_DATAINDIR      ${BA_PATH}/obs_global;;
  *)    f_call_set_var BA_DATAINDIR      ${BA_PATH}/obs_local;;
esac
#----------------------------------------------------------------------------------
if [[ "$1" = ICON ]]; then
#==================================================================================
f_call_set_var BA_I_OBSDIR       $BA_DATAINDIR
#----------------------------------------------------------------------------------
f_call_set_var BA_I_OBSDIR_CONV[0]  $BA_I_OBSDIR/netcdf
f_call_set_var BA_I_OBSDIR_CONV[1]  $BA_I_OBSDIR/netcdf_additional
#----------------------------------------------------------------------------------
# path of SATPP files; set BA_I_OBSDIR_SATPP="" if no radiances are desired
#----------------------------------------------------------------------------------
f_call_set_var BA_I_OBSDIR_SATPP[0] $BA_I_OBSDIR/satpp
f_call_set_var BA_I_OBSDIR_SATPP[1] $BA_I_OBSDIR/satpp_additional
#----------------------------------------------------------------------------------
# further observation paths
#----------------------------------------------------------------------------------
f_call_set_var BA_I_SNW_MLD      $BA_I_OBSDIR/bufr
f_call_set_var BA_I_SST_MLD      $BA_I_OBSDIR/bufr
f_call_set_var BA_I_SFC_MLD      $BA_I_OBSDIR/netcdf
f_call_set_var BA_I_SNW_GRIB     $BA_I_OBSDIR/grib
f_call_set_var BA_I_SST_GRIB     $BA_I_OBSDIR/grib
f_call_set_var BA_I_SST_NETC     $BA_I_OBSDIR/netcdf
f_call_set_var BA_I_OCE_NETC[0]  $BA_PATH/icon_sml/obs_ocean/EN4_R2B4_0043
f_call_set_var BA_I_OCE_NETC[1]  $BA_PATH/icon_sml/obs_ocean/anomalies_R2B4_0043
#==================================================================================
fi
###################################################################################
#
#
###################################################################################
# time specific parameters
#==================================================================================
f_call_set_var -t BA_DELT_ASS_ICON         3h              # frequency of ass cycle
f_call_set_var -t BA_DELT_ASS_ICONLAM      1h              # frequency of ass cycle
f_call_set_var -t BA_DELT_ASS_COSMO        1h              # frequency of ass cycle
f_call_set_var -t BA_DELT_URDA_COSMO       1h             # frequency of urda cycle
f_call_set_var -t BA_DELT_ASS_ICON_O       1mo       # frequency of ocean ass cycle
#----------------------------------------------------------------------------------
f_call_set_var    BA_START_MAIN_ICON       "00|12"        # start of main forecasts
f_call_set_var    BA_START_MAIN_ICONLAM    "00|06|12|18"  #   option: hh|hh|....
f_call_set_var    BA_START_MAIN_COSMO      "00|06|12|18"  #   or "*" for always
#----------------------------------------------------------------------------------
case "$1" in
  ICON)
    f_call_set_var -t BA_FCLNG_DET       180h                      # main fc length
    f_call_set_var -t BA_FCLNG_ENS       180h                      # main fc length
    f_call_set_var -t BA_FCSTP_DET         3h            # main fc output frequency
    f_call_set_var -t BA_FCSTP_ENS         3h            # main fc output frequency
    ;;
  COSMO)
    f_call_set_var -t BA_FCLNG_DET        24h                      # main fc length
    f_call_set_var -t BA_FCLNG_ENS        24h                      # main fc length
    f_call_set_var -t BA_FCSTP_DET         1h            # main fc output frequency
    f_call_set_var -t BA_FCSTP_ENS         1h            # main fc output frequency
    ;;
  ICON-LAM)
    f_call_set_var -t BA_FCLNG_DET         6h                      # main fc length
    f_call_set_var -t BA_FCLNG_ENS         6h                      # main fc length
    f_call_set_var -t BA_FCSTP_DET         1h            # main fc output frequency
    f_call_set_var -t BA_FCSTP_ENS         1h            # main fc output frequency
    ;;
esac
###################################################################################
#
#
###################################################################################
# Bias correction parameter for aircraft, scatterometer, ...
#==================================================================================
#  BA_BIASC_ACTIVATE[<TYPE>] < adate: continues an existing bc
#  BA_BIASC_ACTIVATE[<TYPE>] = adate: starts a new bc (coldstart)
#  BA_BIASC_ACTIVATE[<TYPE>] > adate: disables bc (e.g. 2099010100)
#----------------------------------------------------------------------------------
# default: date of first operational usage
#==================================================================================
case "$1" in
#==================================================================================
ICON)
#----------------------------------------------------------------------------------
f_call_set_var  BA_BIASC_ACTIVATE[AIREP]         2012010100
f_call_set_var  BA_BIASC_ACTIVATE[SCATT]         2012010100
f_call_set_var  BA_BIASC_ACTIVATE[GPSGB]         2012010100
f_call_set_var  BA_BIASC_ACTIVATE[SYNOP]         2012010100
f_call_set_var  BA_BIASC_ACTIVATE[WLIDAR]        2020051909
#----------------------------------------------------------------------------------
;;
#==================================================================================
COSMO|ICON-LAM)
#----------------------------------------------------------------------------------
f_call_set_var  BA_BIASC_ACTIVATE[AIREP]         2099010100
f_call_set_var  BA_BIASC_ACTIVATE[SCATT]         2099010100
f_call_set_var  BA_BIASC_ACTIVATE[GPSGB]         2099010100
f_call_set_var  BA_BIASC_ACTIVATE[SYNOP]         2099010100
#f_call_set_var  BA_BIASC_ACTIVATE[SYNOP]         2019010100 # envarlam (random date)
f_call_set_var  BA_BIASC_ACTIVATE[WLIDAR]        2099010100 # for cenvar
f_call_set_var  BA_BIASC_ACTIVATE[RAD_02070001]  2099010100
f_call_set_var  BA_BIASC_ACTIVATE[MWRGB]         2021060200  # $CY_IN_STARTDATE
#----------------------------------------------------------------------------------
;;
#==================================================================================
esac
###################################################################################
#
#
###################################################################################
# LETKF specific parameter(s)
#==================================================================================
f_call_set_var BA_LETKF_DET_RUN   1                                           # 0|1
###################################################################################
#
#
###################################################################################
# external tool specific parameter(s)
#==================================================================================
f_call_set_var     BA_CONST          $BA_ROOT/const
f_call_set_var     BA_DATCONV        $BA_ROOT/const/datconv
f_call_set_var -e  ROUTINE_PERL      $BA_ROOT/const/perl
f_call_set_var     BA_NPROC_PSH      0
f_call_set_var     BA_QSUBW          qsubw
f_call_set_var     BA_QSUBW_ERRTRY   2
###################################################################################
#
#
###################################################################################
# set number of vertical ICON levels
#==================================================================================
case "$1" in
  ICON)     f_call_set_var  BA_I_N_LEVEL  120;;                            # 90|120
  ICON-LAM) f_call_set_var  BA_I_N_LEVEL   65;;
esac
###################################################################################
#
#
###################################################################################
# End of configuration file
#==================================================================================
f_error_end_of_script
#----------------------------------------------------------------------------------
fi                                                            # include-guard (end)
###################################################################################
