#!/bin/bash

# This script is supposed to be run from the root dir of the git repo
BINDIR="bin"
DATADIR="data"
WORKDIR=$(mktemp -d -p ./temp/)
TEMPDIR=$(mktemp -d -p ./temp/)

INPUT_MODEL="examples/am15ak2odfnew.mod"
OUTDIR="models"

# Spectrum parameters must be left aligned numbers,
# 9 characters in total. Input wavelength is in nm,
# velocities are km/s. Right padding of variables with
# spaces is important!
#SP_STA="360.0    "
#SP_END="1265.0   "
SP_STA="360.0    "
SP_END="365.0    "
SP_RES="3000.0   "
SP_BROADEN_TYPE="GAUSSIAN "
SP_BROADEN_AMNT="3.5      "
SP_BROADEN_UNIT="KM        "

source scripts/lines.sh $WORKDIR $TEMPDIR
source scripts/synthe.sh $WORKDIR $TEMPDIR $INPUT_MODEL $OUTDIR

echo "Removing temp directory"

rm -Rf $TEMPDIR