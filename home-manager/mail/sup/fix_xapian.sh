#!/bin/bash

for f in *xapian; do
  mv $f _$f;
done

sup-sync
