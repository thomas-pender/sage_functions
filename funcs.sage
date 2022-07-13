import copy
from itertools import combinations as combs

def reduce(W,g):
    return matrix(W.nrows(),W.ncols(),lambda i,j: (W[i,j]-1)%g + 1 if W[i,j] else 0)

def skew_conf(q):
    z=GF(q).primitive_element()
    zgp=[0]+[z**i for i in range(1,q)]
    zlogs={zgp[i] : i for i in range(q)}
    top=matrix(1,q+1,lambda i,j: q-1 if j else 0)
    bot=block_matrix([[matrix(q,1,lambda i,j: q-1 if q%2==0 else (q-1)/2),matrix(q,q,lambda i,j: zlogs[zgp[j]-zgp[i]])]])
    W=block_matrix([[top],[bot]])
    return W

def rmspace(l):
    while l[-1]==[]:
        l.pop()
    return l

def circ(q,d):
    qd=q**d
    z=GF(qd).primitive_element()
    logs=[q-1]+[i for i in range(1,q-1)]
    m=(qd-1)/(q-1)
    om=z**(-m)
    omlogs={om**i : logs[i] for i in range(q-1)}
    omlogs[0]=0
    w=[]
    for i in range(m):
        val=0
        num=z**i
        for j in range(d):
            val+=num**(q**j)
        w.append(val)
    W=[w]
    for i in range(m-1):
        w=[om*w[-1]]+w[:-1]
        W.append(w)
    for i in range(m):
        for j in range(m):
            W[i][j]=omlogs[W[i][j]]
    return W

def make_logs(logs,H):
    rdim=H.nrows()
    cdim=H.ncols()
    return matrix(rdim,cdim,lambda i,j: logs[H[i,j]])    

def make_one(A):
    rdim=len(A)
    cdim=len(A[0])
    for i in range(rdim):
        for j in range(cdim):
            if A[i][j]!=0:
                A[i][j]=(-1)**A[i][j]
    return A

def counter(n,q):
    code=[]
    def inner(k=n,word=''):
        if k:
            for i in range(q):
                inner(k-1,word+str(i)+',')
        else:
            code.append([int(x) for x in word.split(',')[:-1]])
    inner()
    return code

def counter2(n,gp):
    k=len(gp)
    return [[gp[x] for x in y] for y in counter(n,k)]

def tran(l):
    rdim=len(l)
    cdim=len(l[0])
    ll=[[0 for i in range(rdim)] for j in range(cdim)]
    for i in range(rdim):
        for j in range(cdim):
            ll[j][i]=l[i][j]
    return ll

def scalar_mult(z,l):
    return [z*x for x in l]

def ladd(l):
    ll=[]
    for i in range(len(l[0])):
        val=0
        for t in l:
            val+=t[i]
        ll.append(val)
    return ll

def make_logs(logs,l):
    return [logs[x] for x in l]

def simplex(q,d):
    qd=q**d
    m=(qd-1)/(q-1)
    z=GF(q).primitive_element()
    zgp=[0]+[z**i for i in range(q-1)]
    zlogs={zgp[i] : i for i in range(q)}
    V=counter2(d,zgp)
    V.remove([0 for i in range(d)])
    zgp.remove(0)
    S=[]
    while len(V)!=0:
        vec=V[0]
        S.append(vec)
        for g in zgp:
            V.remove([g*vec[i] for i in range(d)])
    S=tran(S)
    SS=[]
    zgp.append(0)
    for w in counter2(d,zgp):
        l=[]
        for i in range(d):
            l.append(scalar_mult(w[i],S[i]))
        SS.append(make_logs(zlogs,ladd(l)))
    return SS

def normalize_wmat(W):
    A=copy.deepcopy(W)
    for i in range(A.nrows()):
        if A[i,0]==-1:
            A[[i],[j for j in range(A.ncols())]]=-A[[i],[j for j in range(A.ncols())]]
    for i in range(1,A.ncols()):
        if A[0,i]==-1:
            A[[j for j in range(A.nrows())],[i]]=-A[[j for j in range(A.nrows())],[i]]
    return A

def res(W):
    return W[[i for i in range(W.nrows()) if W[i,0]==0],[j for j in range(1,W.ncols())]]
            
def der(W):
    return W[[i for i in range(W.nrows()) if W[i,0]!=0],[j for j in range(1,W.ncols())]]

def scalar_add(a,H):
    return matrix(H.nrows(),H.ncols(),lambda i,j: a+H[i,j])

def gh_kron(A,B):
    l=[[(lambda j: scalar_add(A[i,j],B))(j) for j in range(A.ncols())] for i in range(A.nrows())]
    return block_matrix(A.nrows(),A.ncols(),l)

def gh(q,d):
    if not is_prime(q):
        for i in range(2,floor(sqrt(q))+1):
            if is_prime(i) and q%i==0:
                p=i
                break
    else:
        p=q
    K.<x>=GF(p)[]
    n=log(q,p)
    F=list(K.quotient(GF(p**n).modulus()))
    Flogs={F[i] : i for i in range(q)}
    H=matrix(q,q,lambda i,j: F[i]*F[j])
    if d>1:
        T=copy.deepcopy(H)
    for i in range(1,d):
        H=gh_kron(H,T)
    return matrix(H.nrows(),H.ncols(),lambda i,j: Flogs[H[i,j]])

def hamming_dist(code):
    size=len(code[0])
    dist=size
    for x,y in combs(code,2):
        dist=min(dist,sum((lambda i: 1 if x[i]!=y[i] else 0)(i) for i in range(size)))
    return dist

def gh_msls(q):
    if not is_prime(q):
        for i in range(2,floor(sqrt(q))+1):
            if is_prime(i) and q%i==0:
                p=i
                break
    else:
        p=q
    K.<x>=GF(p)[]
    n=log(q,p)
    F=list(K.quotient(GF(p**n).modulus()))
    Flogs={F[i] : i for i in range(q)}   
    H=matrix(q,q,lambda i,j: F[i]*F[j])
    def addmult(a):
        return matrix(q,q,lambda i,j: Flogs[a[i]-a[j]])
    return [addmult(H.row(i)) for i in range(1,q)]
