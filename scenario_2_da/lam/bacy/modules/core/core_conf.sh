#!/bin/ksh
#
###################################################################################
#
# Configuration file for module "core"
#
###################################################################################
#
#
###################################################################################
# Begin of configuration script
#==================================================================================
if [ -z "$__CORE_CONF__" ]; then __CORE_CONF__=defined        # include-guard begin
###################################################################################
#
#
###################################################################################
# General configuration
#==================================================================================
f_call_set_var CO_EXPID        ${CY_EXPID:-0001}
###################################################################################
#
#
###################################################################################
# LETKF COSMO specific parameters
#==================================================================================
f_call_set_var CO_C_BIASDIR    /lustre2/uwork/hreich/cosmo_letkf/bias/bias_icon/test
f_call_set_var CO_C_CONSTDIR   ${BA_ROUTFORFOX}/lm/const
###################################################################################
#
#
###################################################################################
# Ensemble specific parameters
#==================================================================================
f_call_set_var   CO_I_HETENS         0     # 0|1|2: '1' only ENVAR, '2' ENVAR+LETKF
#-- size of first guess ensembles -------------------------------------------------
f_call_set_var   CO_I_ENSIZE[0]      ${BA_ENSIZE_ASS}        # size of sub-ensemble
f_call_set_var   CO_I_ENSIZE[1]      0                       # ignore if set to 0
#-- source of ensemble first guesses ----------------------------------------------
f_call_set_var   CO_I_ENVAR_PATH[0]  ${BA_PATH}/envar_data   # only method = ENVAR
f_call_set_var   CO_I_ENVAR_PATH[1]  ${BA_PATH}/envar_art    # all ensmble methods
###################################################################################
#
#
###################################################################################
# ??? specific parameters
#==================================================================================
f_call_set_var   CO_I_RTCOF       ${BA_ROUTFORFOX}/rttov/const/rttov13pred54L
f_call_set_var   CO_I_CONST       ${BA_ROUTFORFOX}/3dvar/const
f_call_set_var   CO_I_W_ENS_B     0.7
#----------------------------------------------------------------------------------
f_call_set_var   CO_BLKLST        ${BA_DATAINDIR}/blk
#----------------------------------------------------------------------------------
# list of conventional observations to be removed
#----------------------------------------------------------------------------------
f_call_set_var CO_I_OBS_CONV_NOT_USED        ""
#----------------------------------------------------------------------------------
# list of satellites to be removed (NOTE: use three digits with leading zeros!)
#----------------------------------------------------------------------------------
f_call_set_var CO_I_SATPP_SAT_NOT_USED       ""
#----------------------------------------------------------------------------------
# list of satellite instruments to be removed
#----------------------------------------------------------------------------------
f_call_set_var CO_I_SATPP_INSTR_NOT_USED     ""
#----------------------------------------------------------------------------------
# list of satellite instruments to be removed
#----------------------------------------------------------------------------------
f_call_set_var CO_I_SATPP_SAT_INSTR_NOT_USED ""
###################################################################################
#
#
###################################################################################
# Bias correction specific parameters
#==================================================================================
# list of observations to use external bias corrections
#----------------------------------------------------------------------------------
f_call_set_var CO_BC_EXT_OT     ""
#----------------------------------------------------------------------------------
# directory for external bias corrections
# (NOTE: string '__PDATE__' is replaced with current pdate)
#----------------------------------------------------------------------------------
f_call_set_var CO_BC_EXT_SRC    ""
#----------------------------------------------------------------------------------
# check initial bias correction files for new satellite observations
#----------------------------------------------------------------------------------
f_call_set_var CO_BC_INIT_RAD    none              # options: none|rout|para0|para1
###################################################################################
#
#
###################################################################################
# trace gas specific parameters
#==================================================================================
f_call_set_var   CO_I_TRG         1                   # 0|1: use trace gas forecast
f_call_set_var   CO_I_TRG_PATH    ${BA_PATH}/trg
###################################################################################
#
#
###################################################################################
# ENVAR specific parameters
#==================================================================================
if [[ "$CO_IN_METHOD" != "PSAS" ]]; then
#----------------------------------------------------------------------------------
case "$CO_IN_MODEL" in
  ICON)
    f_call_set_var CO_RHO           1.1               # covariance inflation factor
    f_call_set_var CO_RHO_ADAP      1                     # adaptive inflation: 0|1
    f_call_set_var CO_RHO_ADAP_LO   0.9            # adaptive inflation lower bound
    f_call_set_var CO_RHO_ADAP_UP   1.5            # adaptive inflation upper bound
    f_call_set_var CO_RHO_TARGET    2           # apply inflation 1:in LETKF 2:on W
    ;;
  ICON-LAM)
    f_call_set_var CO_RHO           1.1               # covariance inflation factor
    f_call_set_var CO_RHO_ADAP      1                     # adaptive inflation: 0|1
    f_call_set_var CO_RHO_ADAP_LO   0.5            # adaptive inflation lower bound
    f_call_set_var CO_RHO_ADAP_UP   3.0            # adaptive inflation upper bound
    f_call_set_var CO_RHO_TARGET    2           # apply inflation 1:in LETKF 2:on W
    ;;
  COSMO)
    f_call_set_var CO_RHO           1.1               # covariance inflation factor
    f_call_set_var CO_RHO_ADAP      1                     # adaptive inflation: 0|1
    f_call_set_var CO_RHO_ADAP_LO   0.5            # adaptive inflation lower bound
    f_call_set_var CO_RHO_ADAP_UP   3.0            # adaptive inflation upper bound
    f_call_set_var CO_RHO_TARGET    2           # apply inflation 1:in LETKF 2:on W
    ;;
esac
#----------------------------------------------------------------------------------
  f_call_set_var CO_R_ADAP      1       # use adap. R-corr. (local, ens space): 0|1
  f_call_set_var CO_R_ADAP_LO   1.0                        # lower bound for adap R
  f_call_set_var CO_R_ADAP_UP   1.0                        # upper bound for adap R
#----------------------------------------------------------------------------------
  f_call_set_var CO_RTPP        1    # apply relaxation to prior perturbations: 0|1
  f_call_set_var CO_RTPP_ALPHA  0.75                                  # rtpp factor
  f_call_set_var CO_RTPS        0           # apply relaxation to prior spread: 0|1
  f_call_set_var CO_RTPS_ALPHA  0.75                                  # rtps factor
#----------------------------------------------------------------------------------
case "$CO_IN_MODEL" in
  ICON)
    f_call_set_var CO_LOC_H    300.0    # horizontal localisation length scale (km)
    f_call_set_var CO_LOC_V_SFC 0.3           # min.ver.lenghtscale for obs.weights
    f_call_set_var CO_LOC_V_TOP 0.8           # max.ver.lenghtscale for obs.weights
    f_call_set_var CO_LOC_V_RAD 0.3    # min. vert. loc. length scale for radiances
    ;;
  ICON-LAM)
    f_call_set_var CO_LOC_H     80.0    # horizontal localisation length scale (km)
    f_call_set_var CO_LOC_V_SFC 0.075         # min.ver.lenghtscale for obs.weights
    f_call_set_var CO_LOC_V_TOP 0.5           # max.ver.lenghtscale for obs.weights
    f_call_set_var CO_LOC_V_RAD 0.3    # min. vert. loc. length scale for radiances
    ;;
  COSMO)
    f_call_set_var CO_LOC_H     80.0    # horizontal localisation length scale (km)
    f_call_set_var CO_LOC_V_SFC 0.075         # min.ver.lenghtscale for obs.weights
    f_call_set_var CO_LOC_V_TOP 0.5           # max.ver.lenghtscale for obs.weights
    f_call_set_var CO_LOC_V_RAD 0.3    # min. vert. loc. length scale for radiances
    ;;
esac
#----------------------------------------------------------------------------------
fi
###################################################################################
#
#
###################################################################################
# Ensemble recentering
#==================================================================================
case "$CO_IN_MODEL" in
  ICON)
    f_call_set_var CO_RECENTER  1                       # 0|1: ensemble recentering
    ;;
  ICON-LAM)
    f_call_set_var CO_RECENTER  0                       # 0|1: ensemble recentering
    ;;
esac
###################################################################################
#
#
###################################################################################
# Job specific parameters
#==================================================================================
# for 'CO_IN_MODEL=ICON|ICON-LAM' only 'CO_BINARY' is relevant
#----------------------------------------------------------------------------------
f_call_set_var CO_BINARY      ${BA_PATH}/bin/var3d
f_call_set_var CO_BIN_ADJ     ${BA_PATH}/bin/adjust_sst_snow
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
