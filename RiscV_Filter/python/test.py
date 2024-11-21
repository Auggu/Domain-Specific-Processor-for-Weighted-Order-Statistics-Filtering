import scipy.signal as sc
import numpy as np

A = np.ndarray((15,10))
c = 0
for i in range(15):
    for j in range(10):
        A[i][j] = c
        c = c+1
print (A)

B = sc.medfilt(A,5)
print(B)
