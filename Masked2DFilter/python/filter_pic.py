import numpy as np
import serial
import scipy.signal as sc
import cv2


def main():
    n = 5
    r = 2

    #n = 3
    #r = 3

    mask5_3 = [[1,0,1,0,0],
               [0,1,0,0,0],
               [1,0,1,0,0],
               [0,0,0,0,0],
               [0,0,0,0,0]]

    mask5_32 = [[0,0,0,0,0],
               [0,0,0,1,0],
               [0,1,0,0,0],
               [0,0,1,0,0],
               [0,0,0,0,0]]


    mask5_5 = [[1,1,1,1,1],
               [1,1,1,1,1],
               [1,1,1,1,1],
               [1,1,1,1,1],
               [1,1,1,1,1]]

    mask3 = [[1,1,1],
            [1,1,1],
            [1,1,1]]



    img_noisy = create_noisy_image("duckSmall.png")
    print("original")
    #print(img_noisy)
    ser = serial.Serial("/dev/ttyUSB0", 115200)
    filtered = run_filter(img_noisy, n, r, mask5_32 ,ser)
    filtUint8 = filtered.astype(np.uint8)
    print("filterd")
    #print(filtered)
    true_filtered = sc.medfilt(img_noisy,n)
    masked_res = mask_filter(img_noisy, n, mask5_32, r)

    print("truenormal")
    #print(true_filtered)
    cv2.imshow("img_filtered", img_noisy)
    cv2.waitKey(0)
    cv2.imshow("img_filtered", filtUint8)
    cv2.waitKey(0)
    cv2.imshow("img_filtered", masked_res)
    cv2.waitKey(0)
    cv2.imshow("img_filtered", true_filtered)
    cv2.waitKey(0)


    ser.close()


def run_filter(pic, n, r, mask, ser):
    shape = pic.shape
    send_n(n, ser)
    send_w(pic, ser)
    send_h(pic, ser)
    send_r(r, ser)
    send_m(mask, n, ser)
    send_i(pic, ser)
    ser.write(bytes(b's'))
    res = np.array(list(ser.read(pic.size)))
    return res.reshape(shape)

def create_noisy_image(path):
    img = cv2.imread(path)
    img_grey = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    return add_salt_and_pepper_noise(img_grey)

def add_salt_and_pepper_noise(image, salt_ratio=0.05, pepper_ratio=0.05):
    row, col = image.shape
    salt = np.random.rand(row, col) < salt_ratio
    pepper = np.random.rand(row, col) < pepper_ratio
    noisy_image = np.copy(image)
    noisy_image[salt] = 1
    noisy_image[pepper] = 0
    return noisy_image

def send_w(image, serial):
    serial.write(bytes(b'w'))
    w = image.shape[0]
    serial.write(bytes([w]))
    print('Setting w: ' + str(w))

def send_h(image, serial):
    serial.write(bytes(b'h'))
    h = image.shape[1]
    serial.write(bytes([h]))
    print('Setting h: ' + str(h))

def send_i(image, serial):
    serial.write(bytes(b'i'))
    for line in image:
        for i in line:
            serial.write(bytes([i]))

def send_r(r, serial):
    serial.write(bytes(b'r'))
    serial.write(bytes([r]))
    print('Setting r: ' + str(r))


def send_m(mask, n, serial):
    byte = 0
    byte_list = []
    c = 0
    for i in range(n-1,-1, -1):
        for j in range(n-1, -1, -1):
            byte = byte + (mask[j][i] << c)
            c = c + 1
            if (c == 8):
                byte_list.append(byte)
                c = 0
                byte = 0
    byte_list.append(byte)

    for _ in range(4 - len(byte_list)):
        byte_list.append(0)

    print(byte_list)
    ba = bytearray(byte_list)
    serial.write(bytes(b'm'))
    print(ba)
    serial.write(ba)

def send_n(n, serial):
    serial.write(bytes(b'n'))
    serial.write(bytes([n]))
    print('Setting n: ' + str(n))

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
