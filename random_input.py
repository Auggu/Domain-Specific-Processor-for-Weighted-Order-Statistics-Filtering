import random
import numpy as np 
import scipy.signal

start_text = """
WIDTH=8;
DEPTH=256;

ADDRESS_RADIX=UNS;
DATA_RADIX=HEX;

CONTENT BEGIN
"""


n = 20
A = np.ndarray(n)
w = 3

f = open("ran_input.mif",'w')
f.write(start_text)

for i in range(n):
    num = random.randrange(0,2**8)
    A[i] = num
    f.write("	%s    :   %02X;\n" % (i, num))

f.write("	[%s..255]  :   00;\nEND;" % n)
f.close()

res = scipy.signal.medfilt(A,w)
#print(res)
hex_res = [format(int(x), "02X") for x in res]
print(hex_res)

res = scipy.signal.medfilt(A,5)
hex_res = [format(int(x), "02X") for x in res]
print(hex_res)


res = scipy.signal.medfilt(A,7)
hex_res = [format(int(x), "02X") for x in res]
print(hex_res)


res = scipy.signal.medfilt(A,9)
hex_res = [format(int(x), "02X") for x in res]
print(hex_res)


