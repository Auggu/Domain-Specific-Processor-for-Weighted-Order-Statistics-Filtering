import numpy as np

image = np.ndarray((10,15))

n = 5
k = n >> 1
neg_k = - k

h = 10
w = 15

xr = 0
xw = 0

yw = 0
yc = 0
yr = 0

w_addr = 0
r_addr = 0
w_en = False
r_en = False

start_address = 0
state = 1


image = [] 

for i in range (h*w):
    image.append(i) 

while(w_addr < h*w):
    if(r_en):
        print("r_a: ", r_addr)
    if(w_en):
        print("w_a: ", w_addr)

    r_en = yr >= 0 and yr < h and xr < w
    yr = yw + yc
    xw = xr + neg_k

    if (state == 1):
        if (yc == k):
            state = 3

    elif state == 3:
        if(xw == w-1):
            state = 2
        else:
            state = 1
    else:
        state = 1


    if(state == 1):
        if(r_en): 
            r_addr = r_addr = r_addr + w
        if(w_en): 
            w_addr = w_addr +1
        yc = yc + 1
        w_en = 0
        continue

    if(state == 2):
        print("new line")
        if (yr < 0):
            r_addr = 0
        else: 
            r_addr = start_address + w
        w_addr = w_addr +1
        yc = neg_k
        yw = yw + 1
        xr = 0
        if (yr < 0 ):
            start_address = 0
        else:
            start_address = start_address + w
        write = 0
        continue

    if(state == 3):
        print("new col")
        r_addr = start_address + xr + 1
        yc = neg_k
        xr = xr +1
        w_en = xw > 0
        continue
