import numpy as np

def apply_weight(w, a, x):
    res = []
    for i in range(len(w)):
       if w[i]:
        res.append(a[x+i])
    return res 


W = [1,1,1,0,1,1]
A = []

f = open('/home/august/Documents/StatisticFilter/WeightedRankOrderFilter/tests/test.hex', 'r')
for line in f:
    A.append(int(line,16))
f.close()

for i in range(len(W)//2):
    A.append(0)
    A.insert(0,0)
print(A)
for i in range(len(A) - len(W)//2):
    sort = sorted(apply_weight(W, A, i))
    res = sort[len(sort)//2]
    print(format(int(res), "02X"))
