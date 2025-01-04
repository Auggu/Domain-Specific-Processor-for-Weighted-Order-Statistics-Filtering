import random as ran

f0 = open("mem0.hex","a")
f1 = open("mem1.hex","a")
f2 = open("mem2.hex","a")
f3 = open("mem3.hex","a")
files = [f0, f1, f2, f3]

for i in range(3750):
    for f in files:
        n = ran.randint(0,255)
        f.write(f"{n:x}\n")
