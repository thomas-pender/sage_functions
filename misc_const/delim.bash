#!/bin/bash

if [ $# -eq 0 ]; then echo ***Error: Requires use of options and parametes. ; exit 1 ; fi

eval set -- $(getopt -o d:i:o:t: -l delim:,infile:,outfile:,type: -- "$@")

while [ -n "$1" ]; do
case "$1" in
-d | --delim) del="$2" ; shift ;;
-i | --infile) ifile="$2" ; shift ;;
-o | --outfile) ofile="$2"  ; shift ;;
-t | --type) kind="$2" ; shift ;;
--) shift ; break ;;
*) echo ***Error: Invalid options. ; exit 1 ;;
esac
shift
done

args=("$@")
if [ -z "$args" ]; then echo ***Error: Requires input file as parameter. ; exit 1
elif [ -z "$del" ]; then echo ***Error: Requires delimiter. ; exit 1
elif [ -z "ifile" ]; then echo ***Error: Requires substitution var. ; exit 1
elif [ -z "ofile" ]; then echo ***Error: Requires output file. ; exit 1
elif [ -z "$kind" ]; then echo ***Error: Requires computer algebra system to execute. ; exit 1
fi


shopt -s nocasematch

case "$kind" in
gap)

sed "s%$del%$ifile%g" ${args[0]} > temp.g
gap -q < temp.g > "$ofile"
rm -f temp.g
;;

maple)

sed "s%$del%$ifile%g" ${args[0]} > temp.wm
maple -q < temp.wm > "$ofile"
rm -f temp.wm
;;

sage)

sed "s%$del%$ifile%g" ${args[0]} > temp.sage
sage -q < temp.sage > "$ofile"
rm -f temp.sage
;;

*)

echo ***Error: Incorrect syntax. ; exit 1 ;;

esac

shopt -u nocasematch
