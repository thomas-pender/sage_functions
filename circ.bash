#!/bin/bash

ERR="\n\e[5;7mERROR:\e[0m"
helper="Use \e[4mcirc -h\e[0m for help.\n"

if [ $# -eq 0 ]; then echo -e "${ERR} Expected options. ${helper}" ; exit 1 ; fi

eval set -- $(getopt -o Cci:hNno: -- "$@")

while [ -n $1 ]; do
case "$1" in
-C) kind="C" ;;
-c) kind="c" ;;
-i) infile="$2" ; shift ;;
-h) less /usr/local/lib/lCIRC_HELP.txt ; exit 0 ;;
-N) kind="N" ;;
-n) kind="n" ;;
-o) outfile="$2" ; shift ;;
--) shift ; break ;;
*) echo -e "${ERR} \e[1;32mInvalid options.\e[0m ${helper}" ; exit 1 ;;
esac
shift
done

args=("$@")

if [ -z "$kind" ]; then echo -e "${ERR} Requires an option. ${helper}" ; exit 1
elif [ -z "$outfile" ]; then echo -e "${ERR} Requires output file. ${helper}" ; exit 1
elif [ $# -eq 0 ]; then echo -e "${ERR} Missing dimension of \(block\) generator. ${helper}" ; exit 1
elif [ "$kind" = "C" ] && [ -z "$infile" ]; then echo -e "${ERR} Input file required with \e[4m-C\e[0m. ${helper}" ; exit 1
elif [ "$kind" = "N" ] && [ -z "$infile" ]; then echo -e "${ERR} Input file required with \e[4m-N\e[0m. ${helper}" ; exit 1 ; fi

file=/usr/local/lib/lfuncs.sage

case "$kind" in
C)

sage -q 1> /dev/null << EOF
load('$file')
f=open('$infile','r')
g=matrix(rmspace([[int(x) for x in y.split()] for y in f.read().split('\n')]))
indim=g.nrows(); outdim=int(${args[0]})
G=[[zero_matrix(indim)]*outdim for i in range(outdim)]; G[0][1]=g
for i in range(1,outdim):
    for j in range(outdim):
        if j==0:
            G[i][j]=G[i-1][outdim-1]
        else:
            G[i][j]=G[i-1][j-1]
G=block_matrix(G)
f=open('$outfile','w')
for i in range(G.nrows()):
    f.write(''.join(['%2d' % x for x in G.row(i)])+'\n')
f.close()
quit
EOF
;;

c)

sage -q 1> /dev/null << EOF
dim=int(${args[0]})
g=matrix.circulant([(lambda i: 1 if i==1 else 0)(i) for i in range(dim)])
f=open('$outfile','w')
for i in range(dim):
    f.write(' '.join([str(x) for x in g.row(i)])+'\n')
f.close()
quit
EOF
;;

N)

sage -q 1> /dev/null << EOF
load('$file')
f=open('$infile','r')
g=matrix(rmspace([[int(x) for x in y.split()] for y in f.read().split('\n')]))
indim=g.nrows(); outdim=int(${args[0]})
G=[[zero_matrix(indim)]*outdim for i in range(outdim)]; G[0][1]=g
for i in range(1,outdim):
    for j in range(outdim):
        if j==0:
            G[i][j]=-G[i-1][outdim-1]
        else:
            G[i][j]=G[i-1][j-1]
G=block_matrix(G)
f=open('$outfile','w')
for i in range(G.nrows()):
    f.write(''.join(['%3d' % x for x in G.row(i)])+'\n')
f.close()
quit
EOF
;;

n)

sage -q 1> /dev/null << EOF
dim=int(${args[0]})
g=matrix(dim,dim); g[0,1]=1
for i in range(1,dim):
    for j in range(dim):
        if j==0:
            g[i,j]=-g[i-1,dim-1]
        else:
            g[i,j]=g[i-1,j-1]
f=open('$outfile','w')
for i in range(dim):
    f.write(''.join(['%3d' % x for x in g.row(i)])+'\n')
f.close()
quit
EOF
;;

*)

echo -e "${ERR} Syntax error. ${helper}"
exit 1
;;

esac
