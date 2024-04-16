#!/bin/bash

mkdir --parents ../../data/scripts

for entry in scripts/.@*
do
  REALPATH=$(realpath ./$entry)
  ENTR=$(realpath ../../data/$entry.link)
  echo "Hard Linking $REALPATH to ../../data/$entry"
  ln "$REALPATH" "$ENTR"
done