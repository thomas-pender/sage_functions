#!/bin/bash

ERR="\n\e[5;7mERROR:\e[0m"
helper="Use \e[4mbgw -h\e[0m for help.\n"

if [ $# -eq 0 ]; then echo -e "${ERR} Expects options. ${helper}" ; exit 1 ; fi

eval set -- $(getopt -o aCcg:Hhi:o:pw -- "$@")

while [ -n $1 ]; do
case "$1" in
-a) if [ -z $kind ]; then kind="a" ; fi ;;
-C) if [ -z $kind ]; then kind="C" ; fi ;;
-c) if [ -z $kind ]; then kind="c" ; fi ;;
-g) gp="g" ; gpord="$2" ; shift ;;
-H) if [ -z $kind ]; then kind="H" ; fi ;;
-h) less /usr/local/lib/lBGW_HELP.txt ; exit 0 ;;
-i) infile="$2" ; shift ;;
-o) outfile="$2" ; shift ;;
-p) perms="p" ;;
-w) weighing="w" ;;
--) shift ; break ;;
*) echo -e "${ERR} Invalid options. ${helper}" ; exit 1 ;;
esac
shift
done

if [ -z "$kind" ]; then echo -e "${ERR} Requires options. ${helper}" ; exit 1
elif [ -z "$outfile" ]; then echo -e "${ERR} Requires output file. ${helper}" ; exit 1
elif [ -n "$gp" ] && [ -z "$infile" ]; then echo -e "${ERR} Requires input file with \e[4m-g\e[0m. ${helper}" ; exit 1
elif [ "$kind" = "a" ] && [ -z "$infile" ]; then echo -e "${ERR} Requires input file with \e[4m-a\e[0m. ${helper}" ; exit 1
fi

file=/usr/local/lib/lfuncs.sage
args=("$@")

case "$kind" in
a)

if [ $# -lt 2 ]; then echo -e "${ERR} Expects 2 parameters. ${helper}" ; exit 1 ; fi

sage -q 1> /dev/null << EOF
load('$file')
q=int(${args[0]}); d=int(${args[1]})
qd=q**d; m=(qd-1)/(q-1)
f=open('$infile','r')
W=normalize_wmat(matrix(rmspace([[int(x) for x in y.split()] for y in f.read().split('\n')])))
R=res(W); D=der(W)
X=reduce(matrix(circ(q,d)),2)
X=matrix(m,m,lambda i,j: (-1)**X[i,j] if X[i,j] else 0)
X=X.tensor_product(R)
Y=simplex(q,d)
for i in range(qd):
    for j in range(m):
        Y[i][j]=matrix(D.row(Y[i][j]))
Y=block_matrix(Y)
Z=block_matrix([[zero_matrix(X.nrows(),1),X],[ones_matrix(Y.nrows(),1),Y]])
f=open('$outfile','w')
for i in range(Z.nrows()):
    f.write(''.join(['%3d' % x for x in Z.row(i)])+'\n')
f.close()
quit
EOF
;;

C)

if [ $# -eq 0 ]; then echo -e "${ERR} Expects one parameter. ${helper}" ; exit 1 ; fi

if [ -n "$gp" ]; then

sage -q 1> /dev/null << EOF
load('$file')
q=int(${args[0]}); gord=int($gpord)
A=reduce(skew_conf(q),gord)
f=open('$infile','r')
gen=matrix(rmspace([[int(x) for x in y.split()] for y in f.read().split('\n')]))
gp=[zero_matrix(gen.nrows(),gen.ncols())]+[gen**i for i in range(1,gord+1)]
W=block_matrix(q+1,q+1,[[(lambda j: gp[A[i,j]])(j) for j in range(q+1)] for i in range(q+1)])
f=open('$outfile','w')
for i in range(W.nrows()):
    f.write(''.join(['%3d' % x for x in W.row(i)])+'\n')
f.close()
quit
EOF

elif [ -n "$weighing" ]; then

sage -q 1> /dev/null << EOF
load('$file')
q=int(${args[0]})
A=reduce(skew_conf(q),2)
W=matrix(q+1,q+1,lambda i,j: (-1)**A[i,j] if A[i,j] else 0)
f=open('$outfile','w')
for i in range(q+1):
    f.write(''.join(['%3d' % x for x in W.row(i)])+'\n')
f.close()
quit
EOF

else

sage -q 1> /dev/null << EOF
load('$file')
W=skew_conf(int(${args[0]}))
f=open('$outfile','w')
for i in range(W.nrows()):
    f.write(' '.join([str(x) for x in W.row(i)])+'\n')
f.close()
quit
EOF

fi
;;

c)

if [ $# -lt 2 ]; then echo -e "${ERR} Expects 2 parameters. ${helper}" ; exit 1 ; fi

if [ -n "$gp" ]; then

sage -q 1> /dev/null << EOF
load('$file')
q=int(${args[0]}); d=int(${args[1]}); gord=int($gpord)
qd=q**d; m=(qd-1)/(q-1)
A=reduce(matrix(circ(q,d)),gord)
f=open('$infile','r')
gen=matrix(rmspace([[int(x) for x in y.split()] for y in f.read().split('\n')]))
gp=[zero_matrix(gen.nrows(),gen.ncols())]+[gen**i for i in range(1,gord+1)]
W=block_matrix(m,m,[[(lambda j: gp[A[i,j]])(j) for j in range(m)] for i in range(m)])
f=open('$outfile','w')
for i in range(W.nrows()):
    f.write(''.join(['%3d' % x for x in W.row(i)])+'\n')
f.close()
quit
EOF

elif [ -n "$weighing" ]; then

sage -q 1> /dev/null << EOF
load('$file')
q=int(${args[0]}); d=int(${args[1]})
qd=q**d; m=(qd-1)/(q-1)
A=reduce(matrix(circ(q,d)),2)
W=matrix(m,m,lambda i,j: (-1)**A[i,j] if A[i,j] else 0)
f=open('$outfile','w')
for i in range(m):
    f.write(''.join(['%3d' % x for x in W.row(i)])+'\n')
f.close()
quit
EOF

else

sage -q 1> /dev/null<< EOF
load('$file')
q=int(${args[0]}); d=int(${args[1]})
W=circ(q,d)
f=open('$outfile','w')
for line in W:
    f.write(' '.join([str(x) for x in line])+'\n')
f.close()
quit
EOF

fi
;;

H)

if [ $# -lt 2 ]; then echo -e "${ERR} Expects 2 parameters. ${helper}" ; exit 1 ; fi

if [ -n "$perms" ]; then

sage -q 1> /dev/null << EOF
load('$file')
q=int(${args[0]}); d=int(${args[1]})
H=gh(q,d)
if not is_prime(q):
    for i in range(2,floor(sqrt(q))+1):
        if is_prime(i) and q%i==0:
            p=i
            break
else:
    p=q
n=log(q,p)
g=matrix.circulant([(lambda i: 1 if i==1 else 0)(i) for i in range(p)])
gp=[g**i for i in range(p)]
L=counter2(n,gp)
Gp=[]
for line in L:
    temp=matrix(1,1,[1])
    for mat in reversed(line):
        temp=temp.tensor_product(mat)
    Gp.append(temp)
HH=block_matrix(H.nrows(),H.ncols(),[[(lambda j: Gp[H[i,j]])(j) for j in range(H.ncols())] for i in range(H.nrows())])
f=open('$outfile','w')
for i in range(HH.nrows()):
    f.write(''.join([str(x) for x in HH.row(i)])+'\n')
f.close()
quit
EOF

else

sage -q 1> /dev/null << EOF
load('$file')
q=int(${args[0]}); d=int(${args[1]})
H=gh(q,d)
f=open('$outfile','w')
for i in range(H.nrows()):
    f.write(' '.join([str(x) for x in H.row(i)])+'\n')
f.close()
quit
EOF

fi
;;

*)

echo -e "${ERR} Syntax error. ${helper}"
exit 1
;;

esac
