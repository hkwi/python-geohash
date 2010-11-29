import random
import geohash
import time

os = []
for i in range(100000):
	o = ((random.random()*2 - 1.0)*90.0, (random.random()*2 - 1.0)*180.0)
	os.append(o)

tmstart = time.time()
for i in range(100000):
	geohash.encode(*os[i])

print time.time()-tmstart
