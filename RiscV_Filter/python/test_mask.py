import numpy as np

def main():
    n = 5
    r = 4

    #n = 3
    #r = 3

    mask5_3 = [[1,0,1,0,0],
               [0,1,0,0,0],
               [1,0,1,0,0],
               [0,0,0,0,0],
               [0,0,0,0,0]]

    mask5_32 = [[0,0,0,0,1],
                [0,0,0,0,1],
                [0,0,0,0,1],
                [1,0,0,0,0],
                [0,0,0,0,1]]

    mask5_33 = [[1,1,1,1,1],
               [0,0,0,0,0],
               [0,0,0,0,0],
               [0,0,0,0,0],
               [0,0,0,0,0]]


    mask5_5 = [[1,1,1,1,1],
               [1,1,1,1,1],
               [1,1,1,1,1],
               [1,1,1,1,1],
               [1,1,1,1,1]]

    mask3 = [[1,1,1],
            [1,1,1],
            [1,1,1]]


    A = np.ndarray((15,10))
    c = 0
    for i in range(15):
        for j in range(10):
            A[i][j] = c
            c = c+1
    print (A)

    B = mask_filter(A, n, mask5_32, r)
    print (B)

def mask_filter(image, n, mask, rank):
    h = image.shape[0]
    w = image.shape[1]
    res = np.ndarray(image.shape)

    for (r, row) in enumerate(image) :
        for (c, pixel) in enumerate(row):

            array = []
            k = n//2

            for i in range(-k,k+1):
                for j in range(-k, k+1):
                    mask_val = mask[i+k][j+k]
                    r2 = r+i
                    c2 = c+j
                    in_bounce = r2 >= 0 and r2 < h and c2 >= 0 and c2 < w
                    if(mask_val == 1):
                        if(in_bounce):
                            array.append(image[r2][c2])
                        else:
                            array.append(np.uint8(0))

            array.sort()
            res[r][c] = array[rank-1]

    return res.astype(np.uint8)

if __name__ == '__main__':
    main()
