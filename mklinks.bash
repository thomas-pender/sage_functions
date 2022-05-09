#!/bin/bash

kind1=/usr/local/lib/l
kind2=/usr/local/bin/

ln -s $PWD/funcs.sage "$kind1"funcs.sage

for file in $PWD/[!mr]*.bash; do
chmod u+x "$file"
name="$kind2"$(basename "$file" | sed "s%\.bash%%")
ln -s "$file" "$name"
done

for file in $PWD/*HELP*; do
name="$kind1"$(basename "$file")
ln -s "$file" "$name"
done
