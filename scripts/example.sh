#!/bin/bash

PARAMS="examples/params.sh"
INPUT_MODEL="examples/am15ak2odfnew.mod"

echo "Sourcing params file"
source $PARAMS

LINEDIR=$(mktemp -d -p $TEMPDIR/)

./scripts/lines.sh $PARAMS $LINEDIR
./scripts/synthe.sh $PARAMS $LINEDIR $INPUT_MODEL

echo "Removing temp directory"
rm -Rf $LINEDIR