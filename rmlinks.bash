#!/bin/bash

kind1=/usr/local/bin/
kind2=/usr/local/lib/l

rm -f "$kind2"funcs.sage

for file in $PWD/[!mr]*.bash; do
chmod u-x "$file"
name="$kind1"$(basename "$file" | sed "s%\.bash%%")
rm -f "$name"
done

for file in $PWD/*HELP*; do
name="$kind2"$(basename "$file")
rm -f "$name"
done
