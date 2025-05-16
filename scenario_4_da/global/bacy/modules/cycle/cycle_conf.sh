#!/bin/ksh
#
###################################################################################
#
# Configuration file for module "cycle"
#
###################################################################################
#
#
###################################################################################
# Begin of configuration script
#==================================================================================
if [ -z "$__CYCLE_CONF__" ]; then __CYCLE_CONF__=defined            # include-guard
###################################################################################
#
#
###################################################################################
# Cycling specific parameters
#==================================================================================
f_call_set_var -e  CY_EXPID   0002
#--data-cleanup--------------------------------------------------------------------
f_call_set_var  CY_DATA_CLEANUP_IGN      "00|12"      # ignore: ""|"*"|00|03|...|21
#shollbor, cwelzbac: check function f_cycle_icon_cleanup
f_call_set_var  CY_DATA_CLEANUP_KEEP_DET    1    # keep always determ. results: 0|1
f_call_set_var  CY_DATA_CLEANUP_KEEP_ENVAR  0     # keep ensemble fg for envar: 0|1
#----------------------------------------------------------------------------------
f_call_set_var  CY_ASS_WAIT_FOR    0          # wait for analysis in main cycle 0|1
f_call_set_var  CY_MAIN_WAIT_FOR   0          # wait for forecast in veri cycle 0|1
#----------------------------------------------------------------------------------
f_call_set_var  CY_ASYNC_JOB      0                     # run jobs asynchronous 0|1
#----------------------------------------------------------------------------------
f_call_set_var  CY_ICON_NO_ANALYSIS  1        # no analysis (for output in FDB) 0|1
#----------------------------------------------------------------------------------
case "$CY_IN_MODEL" in         # PSAS|PSAS+LETKF|LETKF|LETKF_URDA|ENVAR|ENVAR+LETKF
  ICON)     f_call_set_var  CY_METHOD  ENVAR+LETKF;;
  COSMO)    f_call_set_var  CY_METHOD  LETKF;;
  ICON-LAM) f_call_set_var  CY_METHOD  LETKF;;
esac
###################################################################################
#
#
###################################################################################
# ICON specific parameters
#==================================================================================
if [[ "$CY_IN_MODEL" == ICON ]]; then
#----------------------------------------------------------------------------------
f_call_set_var  CY_I_FCDEL  0       # delete 24hr fcs at 0UTC after SMA ready (0|1)
f_call_set_var  CY_I_ANA2REG_TIMES ""               # options: ""|"*"|00|03|...|21
f_call_set_var  CY_I_ANA2REG_ENS    0                  # ana2reg for ensemble (0|1)
#----------------------------------------------------------------------------------
case "$CY_IN_MODE" in                                     # PDAF analysis algorithm
  CLIMA) f_call_set_var    CY_METHOD_PDAF LSEIK;;
esac
#f_call_set_var -e EX_MO_CLIMA_START_DATE  1959-01-01
#f_call_set_var -e EX_MO_CLIMA_END_DATE    2099-01-01
fi
###################################################################################
#
#
###################################################################################
# Local model specific parameters
#==================================================================================
case "$CY_IN_MODEL" in
#==================================================================================
COSMO)
#----------------------------------------------------------------------------------
f_call_set_var CY_L_FC_START_ENS "all"       # frcst start: hhmmss|hhmmss|... or "all"
#----------------------------------------------------------------------------------
f_call_set_var CY_L_BC_WAIT_FOR     0            # wait for boundary conditions 0|1
#----------------------------------------------------------------------------------
;;
#==================================================================================
ICON-LAM)
#----------------------------------------------------------------------------------
f_call_set_var CY_L_FC_START_ENS    "all"    # frcst start: hhmmss|hhmmss|... or "all"
#----------------------------------------------------------------------------------
f_call_set_var CY_L_BC_WAIT_FOR     0            # wait for boundary conditions 0|1
#----------------------------------------------------------------------------------
f_call_set_var CY_L_MAIN_FROM_IEU   1    # run MAIN (ILAM) with interp. ICON-EU 0|1
f_call_set_var -e  EX_MO_L_MAIN_FROM_IEU  $CY_L_MAIN_FROM_IEU
f_call_set_var -e  EX_BC_L_MAIN_FROM_IEU  $CY_L_MAIN_FROM_IEU
#----------------------------------------------------------------------------------
f_call_set_var CY_L_INI_NEST        1          # initialize nest in first cycle 0|1
#----------------------------------------------------------------------------------
;;
#==================================================================================
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
