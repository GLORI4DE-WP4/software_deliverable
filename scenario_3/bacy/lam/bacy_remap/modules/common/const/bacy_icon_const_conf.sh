#!/bin/ksh
#
###################################################################################
#
# CONFIGURATION file for ICON grids
#
# USAGE: source $BACY/common/const/bacy_icon_const.conf
#
# DESCRIPTION: collects icon grid files
#
# HISTORY:
#
#   - tsteiner 2021/03: first version for unified bacy BACY_1.0
#   - tsteiner 2022/09: use gridnumber to identify grids
#
###################################################################################
#
#
###################################################################################
# Checking input arguments
#==================================================================================
if [ "$#" -ne 2 ]; then
  f_error_set_msg_and_send 1 ER_msg \
    "Wrong number ($#) of arguments while sourcing" \
    "'${.sh.file}'."
fi
#----------------------------------------------------------------------------------
typeset -Z4 in_gnum=$1
typeset in_centre=$2
typeset out_array
###################################################################################
#
#
###################################################################################
# Set grid files
#==================================================================================
# template:
#   out_array[0]: radiation grid
#   out_array[1]: normal grid
#   out_array[2]: 1. nest grid
#   out_array[3]: 2. nest grid
#   ...
#
#  ICON allows up to 9 nests
#
#  gridfile naming convention:
#                 icon_grid_<grid number>_R[0_9][0-9]B[0_9][0-9]_<ID>.nc
#    ID:
#          R:     radiation grid
#          G:     global grid
#          N02:   1. nest grid
#          N03:   2. nest grid
#          LR:    LAM radiation grid
#          L:     LAM grid
#          LN02:  1. LAM nest grid
#
#==================================================================================
case "${in_centre}:${in_gnum}" in
  # ICON global grids
  78:0024)
    # Resolutions: 40 km (atmosphere), 80 km (radiation)
    out_array[0]=icon_grid_0023_R02B05_R.nc
    out_array[1]=icon_grid_0024_R02B06_G.nc
    if [ "$BA_I_ART" -eq 1 ]; then
      out_array[2]=icon_grid_0050_R02B07_N02.nc
    else
      out_array[2]=icon_grid_0028_R02B07_N02.nc
    fi
    ;;
  78:0026)
    # Resolutions: 13 km (atmosphere), 26 km (radiation)
    out_array[0]=icon_grid_0025_R03B06_R.nc
    out_array[1]=icon_grid_0026_R03B07_G.nc
    out_array[2]=icon_grid_0027_R03B08_N02.nc
    ;;
  78:0030)
    # Resolutions: 80 km (atmosphere), 160 km (radiation)
    out_array[0]=icon_grid_0029_R02B04_R.nc
    out_array[1]=icon_grid_0030_R02B05_G.nc
    out_array[2]=icon_grid_0031_R02B06_N02.nc
    ;;
  78:0033)
    # Resolutions: 53 km (atmosphere), 106 km (radiation)
    out_array[0]=icon_grid_0032_R03B04_R.nc
    out_array[1]=icon_grid_0033_R03B05_G.nc
    out_array[2]=icon_grid_0034_R03B06_N02.nc
    ;;
  78:0036)
    # Resolutions: 26 km (atmosphere), 53 km (radiation)
    out_array[0]=icon_grid_0035_R03B05_R.nc
    out_array[1]=icon_grid_0036_R03B06_G.nc
    if [ "$BA_I_ART" -eq 1 ]; then
      out_array[2]=icon_grid_0051_R03B07_N02.nc
    else
      out_array[2]=icon_grid_0037_R03B07_N02.nc
    fi
    ;;
  78:0039)
    # Resolutions: 20 km (atmosphere), 40 km (radiation)
    out_array[0]=icon_grid_0038_R02B06_R.nc
    out_array[1]=icon_grid_0039_R02B07_G.nc
    out_array[2]=icon_grid_0040_R02B08_N02.nc
    ;;
  78:0012)
    # Resolutions: 160 km (atmosphere), 320 km (radiation)
    out_array[0]=icon_grid_0011_R02B03_R.nc
    out_array[1]=icon_grid_0012_R02B04_G.nc
    ;;
  252:0043)
    # Resolutions: 160 km (atmosphere), 160 km (ocean)
    out_array[0]=icon_grid_0043_R02B04_G.nc
    out_array[1]=icon_grid_0043_R02B04_G.nc
    ;;
  # ICON EU-nest grids
  78:0028)
    # Resolutions: 20 km (EU-nest)
    out_array[0]=icon_grid_0028_R02B07_N02.nc
    out_array[1]=icon_grid_0028_R02B07_N02.nc
    ;;
  78:0027)
    # Resolutions: 6.5 km (EU-nest)
    out_array[0]=icon_grid_0027_R03B08_N02.nc
    out_array[1]=icon_grid_0027_R03B08_N02.nc
    out_array[2]=icon_grid_0027_R03B08_N02.nc
    ;;
  78:0031)
    # Resolutions: 40 km (EU-nest)
    out_array[0]=icon_grid_0031_R02B06_N02.nc
    out_array[1]=icon_grid_0031_R02B06_N02.nc
    ;;
  78:0034)
    # Resolutions: 26 km (EU-nest)
    out_array[0]=icon_grid_0034_R03B06_N02.nc
    out_array[1]=icon_grid_0034_R03B06_N02.nc
    ;;
  78:0037)
    # Resolutions: 13 km (EU-nest)
    out_array[0]=icon_grid_0037_R03B07_N02.nc
    out_array[1]=icon_grid_0037_R03B07_N02.nc
    out_array[2]=icon_grid_0037_R03B07_N02.nc
    ;;
  78:0040)
    # Resolutions: 20 km (EU-nest)
    out_array[0]=icon_grid_0040_R02B08_N02.nc
    out_array[1]=icon_grid_0040_R02B08_N02.nc
    ;;
  78:0050)
    # Resolutions: 20 km (EU-NANA-nest)
    out_array[0]=icon_grid_0050_R02B07_N02.nc
    out_array[1]=icon_grid_0050_R02B07_N02.nc
    ;;
  78:0051)
    # Resolutions: 13 km (EU-NANA-nest)
    out_array[0]=icon_grid_0051_R03B07_N02.nc
    out_array[1]=icon_grid_0051_R03B07_N02.nc
    ;;
  # ICON regional grids
  78:0042)
    # Resolutions: 2.2 km (atmosphere)
    out_array[0]=icon_grid_0041_R02B09_LR.nc
    out_array[1]=icon_grid_0042_R02B10_L.nc
    ;;
  78:0044)
    # Resolutions: 2.2 km (atmosphere), 26 km (radiation)
    out_array[0]=icon_grid_0043_R19B06_LR.nc
    out_array[1]=icon_grid_0044_R19B07_L.nc
    out_array[2]=icon_grid_0045_R19B08_LN02.nc
    ;;
  78:0047)
    # Resolutions: 2.2 km (atmosphere)
    # N and K
    out_array[0]=icon_grid_0046_R19B06_LR.nc
    out_array[1]=icon_grid_0047_R19B07_L.nc
    ;;
  78:1000)
    # GLORI DWD Alpine 2.2km (atmosphere, 1km-nest)
    out_array[0]=icon_grid_0999_R19B06_LR.nc
    out_array[1]=icon_grid_1000_R19B07_L.nc
    out_array[2]=icon_grid_1001_R19B08_LN02.nc
    ;;
  78:0200)
    # GLORI new grid (22/11/2024)
    out_array[0]=icon_grid_0199_R19B07_LR.nc
    out_array[1]=icon_grid_0200_R19B08_L.nc
    out_array[2]=icon_grid_0201_R19B09_LN02.nc
    ;;
  78:9999)
    # Using IFS as input (dummy values)
    out_array[0]=icon_grid_0999_R19B06_LR.nc
    out_array[1]=icon_grid_1000_R19B07_L.nc
    out_array[2]=icon_grid_1001_R19B08_LN02.nc
    ;;
  *)
    f_error_set_msg_and_send 1 ER_msg \
      "Unsupported combination of grid number ($in_gnum)" \
      "and centre ($in_centre) while sourcing" \
      "'${.sh.file}'."
    ;;
esac
###################################################################################
#
#
###################################################################################
# End of configuration file
#==================================================================================
