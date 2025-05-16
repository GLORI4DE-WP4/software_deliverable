#!/bin/bash

# Input parameters
REF_DATE=$1
REF_TIME=$2
DELTA_T=$3

# Compute the new reference time
NEW_REFTIME=$(date -u -d "${REF_DATE} ${REF_TIME} +${DELTA_T}hour")

# Format the output without using %
YEAR=$(date -u -d "${NEW_REFTIME}" +"%Y")
MONTH=$(date -u -d "${NEW_REFTIME}" +"%m")
DAY=$(date -u -d "${NEW_REFTIME}" +"%d")
HOUR=$(date -u -d "${NEW_REFTIME}" +"%H")
MINUTE=$(date -u -d "${NEW_REFTIME}" +"%M")

# Print the formatted reference time
echo "${YEAR}${MONTH}${DAY} ${HOUR}${MINUTE}"
