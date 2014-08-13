import random
import geohash
import time
import sys

os = []
for i in range(100000):
	o = ((random.random()*2 - 1.0)*90.0, (random.random()*2 - 1.0)*180.0)
	os.append(o)

ds = []
tmstart = time.time()
for i in range(100000):
	ds.append(geohash.encode(*os[i]))

sys.stdout.write("encode %f sec\n" % (time.time()-tmstart,))

tmstart = time.time()
for i in range(100000):
	geohash.decode(ds[i])

sys.stdout.write("decode %f sec\n" % (time.time()-tmstart,))
