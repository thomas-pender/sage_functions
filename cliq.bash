#!/bin/bash

ERR="\n\e[5;7mERROR:\e[0m"
helper="Use \e[4mcliq -h\e[0m for help.\n"

if [ $# -eq 0 ]; then echo -e "${ERR} Expected one option. ${helper}" ; exit 1 ; fi

eval set -- $(getopt -o phmo: -- "$@")

while [ -n "$1" ]; do
case "$1" in
-p) kind="p" ;;
-h) less /usr/local/lib/lCLIQ_HELP.txt ; exit 0 ;;
-m) kind="m" ;;
-o) outfile="$2" ; shift ;;
--) shift ; break ;;
*) echo -e "${ERR} Invalid options. ${helper}" ; exit 1 ;;
esac
shift
done

args=("$@")
if [ -z "$kind" ]; then echo -e "${ERR} Required options. ${helper}" ; exit 1
elif [ $# -eq 0 ]; then echo -e "${ERR} Expected 1 parameter. ${helper}" ; exit 1
elif [ "$kind" = "m" ] && [ -z "$outfile" ]; then echo -e "${ERR} Expected output file. ${helper}" ; exit 1
fi

file=/usr/local/lib/lfuncs.sage

case "$kind" in
p)

sage -q 1> /dev/null << EOF
load('$file')
f=open(${args[0]},'r')
A=matrix(rmspace([[int(x) for x in y] for y in f.read().split('\n')]))
f.close()
G=Graph(A)
import sys
sys.stderr.write(str(G.clique_polynomial())+'\n')
quit
EOF
;;

m)

sage -q 1> /dev/null << EOF
load('$file')
f=open(${args[0]},'r')
A=matrix(rmspace([[int(x) for x in y] for y in f.read().split('\n')]))
G=Graph(A)
cliques=list(G.cliques_maximum())
f=open('$outfile','w')
for clique in cliques:
    f.write(' '.join([str(x) for x in clique])+'\n')
f.close()
quit
EOF
;;

*)

echo -e "${ERR} Incorrect syntax. ${helper}"
exit 1
;;

esac
