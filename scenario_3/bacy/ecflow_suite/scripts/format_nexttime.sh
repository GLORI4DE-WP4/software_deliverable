#!/bin/bash

# Input parameters
CURR_DATE=$1
CURR_HOUR=$2
TIME_INTERVAL=$3

# Compute the new time by adding the interval
NEW_TIME=$(date -u -d "${CURR_DATE} ${CURR_HOUR} +${TIME_INTERVAL} hour" +"%Y%m%d%H")

# Print the updated time in YYYYMMDDHH format
echo "${NEW_TIME}"
