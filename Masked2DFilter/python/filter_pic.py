import numpy as np
import serial
import scipy.signal as sc
import cv2


def main():
    n = 5
    r = 13
    
    mask5_3 = [[1,1,1,0,0],
               [1,1,1,0,0],
               [1,1,1,0,0],
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
    
    
   
    img_noisy = create_noisy_image("duckSmall.png")
    print("original")
    print(img_noisy)
    ser = serial.Serial("/dev/ttyUSB0", 115200)
    filtered = run_filter(img_noisy, n, r, mask5_5 ,ser)
    filtUint8 = filtered.astype(np.uint8)  
    print("filterd")
    print(filtered) 
    
    true_filtered = sc.medfilt(img_noisy,5)

    print("truenormal")
    print(true_filtered) 
    cv2.imshow("img_filtered", img_noisy)
    cv2.waitKey(0)
    cv2.imshow("img_filtered", filtUint8)
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
    for i in range(n):
        for j in range(n):
            byte = byte + (mask[j][i] << c)
            c = c + 1
            if (c == 8):
                byte_list.append(byte)
                c = 0
                byte = 0
    byte_list.append(byte)

    for _ in range(4 - len(byte_list)):
        byte_list.append(0)
    
    ba = bytearray(byte_list)
    serial.write(bytes(b'm'))
    print(ba)
    serial.write(ba)

def send_n(n, serial):
    serial.write(bytes(b'n'))
    serial.write(bytes([n]))
    print('Setting n: ' + str(n))


if __name__ == '__main__':
    main()
