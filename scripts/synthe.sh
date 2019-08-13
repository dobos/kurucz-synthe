#!/bin/bash

function get_filename() {
  local filename=$(basename -- "$1")
  filename="${filename%.*}"
  echo "$filename"
}

WORKDIR=$1
TEMPDIR=$2
INPUT_MODEL=$3
OUTDIR=$4

set -e

BINDIR=$(realpath $BINDIR)
DATADIR=$(realpath $DATADIR)
WORKDIR=$(realpath $WORKDIR)
TEMPDIR=$(realpath $TEMPDIR)
INPUT_MODEL=$(realpath $INPUT_MODEL)
OUTDIR=$(realpath $OUTDIR)
OUTFILE=$OUTDIR/$(get_filename $INPUT_MODEL).spec

echo "Creating workdir"

mkdir -p $WORKDIR
pushd $WORKDIR

PATTERN=(fort.*)
if [ -f ${PATTERN[0]} ]; then
  rm fort.*
fi

echo "Creating output directory $OUTDIR"

mkdir -p $OUTDIR

if [ ! -f $TEMPDIR/fort.12 ]; then
  echo "Run lines.sh first"
  exit
else
  echo "Reusing output from SYNBEG"
  ln -s $TEMPDIR/fort.12 fort.12
  cp $TEMPDIR/fort.14 fort.14 && chmod +w fort.14
  cp $TEMPDIR/fort.19 fort.19 && chmod +w fort.19
  ln -s $TEMPDIR/fort.20 fort.20
  cp $TEMPDIR/fort.93 fort.93 && chmod +w fort.93
fi

cp $INPUT_MODEL $OUTDIR/

echo "Running XNFPELSYN"

ln -s $DATADIR/molecules.dat fort.2
ln -s $DATADIR/continua.dat fort.17
$BINDIR/xnfpelsyn <$INPUT_MODEL >xnfpelsyn.out
cp fort.10 xnf.dat
rm fort.10
rm fort.17
rm fort.2

echo "Running SYNTHE"

ln -s xnf.dat fort.10
ln -s $DATADIR/linelists_castelli/he1tables.dat fort.18
time $BINDIR/synthe >synthe.out

echo "Running SPECTRV"

ln -s $DATADIR/molecules.dat fort.2
echo -e \
"0.0       0.        1.        0.        0.        0.        0.        0.
0.
RHOXJ     R1        R101      PH1       PC1       PSI1      PRDDOP    PRDPOW
" >fort.25
$BINDIR/spectrv <$INPUT_MODEL >spectrv.out
cp fort.7 spect.dat

echo "Running ROTATE"

echo -e \
"    1
2.
" > rotate.in
ln -s spect.dat fort.1
$BINDIR/rotate <rotate.in >rotate.out
mv ROT1 spect_vr.dat
rm fort.1

echo "Running BROADEN"

echo -e \
"$SP_BROADEN_TYPE $SP_BROADEN_AMNT $SP_BROADEN_UNIT
" >broaden.in
ln -s spect_vr.dat fort.21
$BINDIR/broaden <broaden.in >broaden.out
cp fort.22 spect_vr_br.bin

rm fort.*

echo "Converting to ASCII"

ln -s spect_vr_br.bin fort.1
$BINDIR/converfsynnmtoa
cp fort.2 $OUTFILE

echo "Cleaning up"

rm -Rf $WORKDIR
popd

echo "Done."

