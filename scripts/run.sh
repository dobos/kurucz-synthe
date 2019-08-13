#!/bin/bash

PARAMS=$1
INPUT_MODELS=$2

echo "Sourcing params file"
source $PARAMS

LINEDIR=$(mktemp -d -p $TEMPDIR)
./scripts/lines.sh $PARAMS $LINEDIR

echo -e $INPUT_MODELS | sed -e 's/\s\+/\n/g' \
  | xargs --max-procs=20 --replace=% ./scripts/synthe.sh $PARAMS $LINEDIR %

echo "Removing temp directory"
rm -Rf $LINEDIR