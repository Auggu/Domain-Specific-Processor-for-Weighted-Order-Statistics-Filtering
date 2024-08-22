import random
import numpy as np 
import scipy.signal

w = 3
A = []

f = open('tests/test.hex', 'r')
for line in f:
    A.append(int(line,16))

f.close()

res = scipy.signal.medfilt(A,w)
print(res)

hex_res = [format(int(x), "02X") for x in res]
print(hex_res)