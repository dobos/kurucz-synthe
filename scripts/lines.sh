#!/bin/bash

function get_filename() {
  local filename=$(basename -- "$1")
  filename="${filename%.*}"
  echo "$filename"
}

function read_lines() {
  local filename=$(get_filename $1)
  echo "... ... $filename"
  ln $1 fort.11
  $BINDIR/rgfalllinesnew >$TEMPDIR/$filename.out
  rm fort.11
}

function read_mol() {
  local filename=$(get_filename $1)
  echo "... ... $filename"
  ln -s $1 fort.11
  $BINDIR/rmolecasc >$TEMPDIR/$filename.out
  rm fort.11
}

WORKDIR=$1
TEMPDIR=$2

set -e

WORKDIR=$(realpath $WORKDIR)
TEMPDIR=$(realpath $TEMPDIR)
BINDIR=$(realpath $BINDIR)
DATADIR=$(realpath $DATADIR)

echo "Creating workdir $WORKDIR"

mkdir -p $WORKDIR
pushd $WORKDIR

echo "Running SYNBEG"

echo -e \
"AIR       $SP_STA $SP_END $SP_RES 0.     0          10 .001         0   00
AIRorVAC  WLBEG     WLEND     RESOLU    TURBV  IFNLTE LINOUT CUTOFF        NREAD
" >$TEMPDIR/synbeg.in
  $BINDIR/synbeg <$TEMPDIR/synbeg.in >$TEMPDIR/synbeg.out

echo "Processing line lists..."

echo "... atomic lines"
read_lines $DATADIR/linelists/gf100/gf0400.100
read_lines $DATADIR/linelists/gf100/gf0500.100
read_lines $DATADIR/linelists/gf100/gf0600.100
read_lines $DATADIR/linelists/gf100/gf0800.100
read_lines $DATADIR/linelists/gf100/gf1200.100
read_lines $DATADIR/linelists/gf100/gf3000.100

echo "... molecules"

read_mol $DATADIR/molecules/ch/chmasseron.asc
read_mol $DATADIR/linelists/linesmol/mgh.asc
read_mol $DATADIR/linelists/linesmol/nh.asc
read_mol $DATADIR/molecules/oh/ohupdate.asc
read_mol $DATADIR/molecules/sih/sihax.asc
read_mol $DATADIR/linelists/linesmol/h2.asc
read_mol $DATADIR/molecules/h2/h2xx.asc
read_mol $DATADIR/molecules/h2/hdxx.asc
read_mol $DATADIR/linelists/linesmol/c2ax.asc
read_mol $DATADIR/linelists/linesmol/c2ba.asc
read_mol $DATADIR/molecules/c2/c2dabrookek.asc
read_mol $DATADIR/linelists/linesmol/c2ea.asc
read_mol $DATADIR/molecules/cn/cnaxbrookek.asc
read_mol $DATADIR/molecules/cn/cnbxbrookek.asc
read_mol $DATADIR/molecules/co/coax.asc
read_mol $DATADIR/linelists/linesmol/coxx.asc
read_mol $DATADIR/linelists/linesmol/sioax.asc
read_mol $DATADIR/linelists/linesmol/sioex.asc
read_mol $DATADIR/linelists/linesmol/sioxx.asc

echo "... TiO from Schwenke"

mkdir -p $TEMPDIR/tmp
pushd $TEMPDIR/tmp
  
ln -s $DATADIR/molecules/tio/eschw46.asc fort.11
ln -s $DATADIR/molecules/tio/eschw47.asc fort.12
ln -s $DATADIR/molecules/tio/eschw48.asc fort.13
ln -s $DATADIR/molecules/tio/eschw49.asc fort.14
ln -s $DATADIR/molecules/tio/eschw50.asc fort.15
ln -s $TEMPDIR/eschwenke.bin fort.7
$BINDIR/eschwbin
rm fort.11
rm fort.12
rm fort.13
rm fort.14
rm fort.15
  
popd
rm -Rf $TEMPDIR/tmp

ln -s $DATADIR/molecules/tio/tioschwenke.bin fort.11
ln -s $TEMPDIR/eschwenke.bin fort.48
$BINDIR/rschwenk >$TEMPDIR/rschwenk.out
rm fort.11
rm fort.48

echo "... H2O (fast fix) from Partridge & Schwenke"

ln -s $DATADIR/molecules/h2o/h2ofastfix.bin fort.11
$BINDIR/rh2ofast >$TEMPDIR/h2ofastfix.out
rm fort.11

echo "Saving outputs for reuse"

cp fort.* $TEMPDIR/
chmod -w $TEMPDIR/fort.*

popd