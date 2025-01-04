import sys
x = sys.argv[1]
c = 0
for i in range(0,151):
    if i%4 == int(x):
        c = c+1
        print("{:x}".format(i))
for i in range(255-c+1):
    print("00")
