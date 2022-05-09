#!/bin/bash

ERR="\n\e[5;7mERROR:\e[0m"
helper="Use \e[4mdesign -h\e[0m or for help.\n"

if [ $# -eq 0 ]; then echo -e "${ERR} Requires an option. ${helper}" ; exit 1 ; fi

eval set -- $(getopt -o abh -- "$@")

while [ -n "$1" ]; do
case "$1" in
-a) kind="a" ;;
-b) kind="b" ;;
-h) less /usr/local/lib/lDESIGN_HELP.txt ; exit 0 ;;
--) shift ; break ;;
*) echo -e "${ERR} Invalid options. ${helper}" ; exit 1 ;;
esac
shift
done

args=("$@")
if [ $# -eq 0 ]; then echo -e "${ERR} Requires 1 parameter. ${helper}" ; exit 1 ; fi

file=/usr/local/lib/lfuncs.sage

case "$kind" in
a)

sage -q 1> /dev/null << EOF
load('$file')
f=open(${args[0]},'r')
A=tran(rmspace([[int(x) for x in y] for y in f.read().split('\n')]))
B=[]
for line in A:
    l=[]
    for i in range(len(line)):
        if line[i]!=0:
            l.append(i+1)
    B.append(l)
f=open('design.log','w')
f.write('B:=')
f.write(str(B))
f.write(';\ndim:=')
f.write(str(len(B)))
f.write(';')
f.close()
quit
EOF

gap -q 1> /dev/null << EOF
LoadPackage("design");
Read("design.log");
D:=BlockDesign(dim,B);
num:=Size(AutGroupBlockDesign(D));
PrintTo("*errout*","Number of collineations: ",num,"\n");
quit;
EOF

rm -f design.log
;;

b)

sage -q 1> /dev/null << EOF
load('$file')
f=open(${args[0]},'r')
A=matrix(GF(2),rmspace([[int(x) for x in y] for y in f.read().split('\n')]))
f.close()
import sys
sys.stderr.write('Binary rank: '+str(A.rank())+'\n')
quit
EOF
;;

*)

echo -e "${ERR} Syntax error. ${helper}"
exit 1
;;

esac

