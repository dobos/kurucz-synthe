#!/bin/bash

BINDIR="bin"
DATADIR="data"
TEMPDIR="temp"
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

