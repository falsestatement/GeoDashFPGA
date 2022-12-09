import numpy as np
from scipy.io import wavfile
f = wavfile.read("portal.wav")
print("read finished")
print(f[0])

sampledata = np.array(f[1])
print(sampledata[:20])


samples = len(f[1])
print(str(samples) + " samples obtained")

def tohex(val, nbits):
  return hex((val + (1 << nbits)) % (1 << nbits))


f = open("portal.txt", 'w+')
for i in range(samples):
  wrs = tohex(int(sampledata[i][0])>>8, 24)
  f.writelines(str(wrs)[2:]  + '\n')
f.close()
print("data")
