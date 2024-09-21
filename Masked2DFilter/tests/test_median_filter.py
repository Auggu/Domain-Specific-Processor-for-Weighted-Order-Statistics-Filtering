import numpy as np
import scipy.signal as sc
import cv2

pic = np.arange(22*22)
pic += 1
pic[pic > 255] -= 255 
pic = pic.reshape((22,22))
print(pic)

res = sc.medfilt2d(pic,3)
print(res)

