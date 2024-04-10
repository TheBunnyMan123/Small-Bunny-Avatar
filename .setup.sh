#!/bin/bash

mkdir --parents ../../data

for entry in .@*
do
  REALPATH=$(realpath ./$entry)
  ENTR=$(realpath ../../data/$entry.link)
  echo "Hard Linking $REALPATH to ../../data/$entry"
  ln "$REALPATH" "$ENTR"
done