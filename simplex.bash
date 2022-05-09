#!/bin/bash

ERR="\n\e[5;7mERROR:\e[0m"
helper="Use \e[4msimplex -h\e[0m for help.\n"

if [ $# -eq 0 ]; then echo -e "${ERR} Expected parameters. ${helper}" ; exit 1 ; fi

eval set -- $(getopt -o ho: -- "$@")

while [ -n "$1" ]; do
case "$1" in
-h) cat /usr/local/lib/lSIMPLEX_HELP.txt ; exit 0 ;;
-o) outfile="$2" ; shift ;;
--) shift ; break ;;
*) echo ***Error: Incorrect parameters. ; echo "$helper" ; exit 1 ;;
esac
shift
done

if [ $# -lt 2 ]; then echo -e "${ERR} Expects 2 parameters. ${helper}" ; exit 1 ; fi
args=("$@")
file=/usr/local/lib/lfuncs.sage

sage -q 1> /dev/null << EOF
load('$file')
S=simplex(int(${args[0]}),int(${args[1]}))
f=open('$outfile','w')
for line in S:
    f.write(' '.join([str(x) for x in line])+'\n')
f.close()
quit
EOF
