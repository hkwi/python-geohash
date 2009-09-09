# coding: UTF-8
# Coder for Japanese iarea area mesh.
# DoCoMo's Open-iarea in japan use a meshcode which is very similar to
# JIS X 0410, but absolutely different in detail.

def encode(lat, lon):
	if lat<7 or lon<100:
		raise Exception('Unsupported location')
	
	t = []
	ab = int(lat * 192)
	ob = int(lon * 128)
	for i in [3,4,5,6,7]:
		t.append((ab&1)*2 + (ob&1))
		ab = ab>>1
		ob = ob>>1
	
	t.append(int(lon *  8)%8)
	t.append(int(lat * 12)%8)
	
	t.append(int(lon)%100)
	t.append(int(lat*1.5))
	t.reverse()
	return ''.join([str(i) for i in t])

def decode_ws(meshcode, delta=False):
	lat = lon = 0
	base = 1
	if len(meshcode)>6:
		for i in meshcode[6:]:
			lat = (lat<<1) + int(i)/2
			lon = (lon<<1) + int(i)%2
			base = base<<1
	
	lat = int(meshcode[4:5])*base + lat
	lon = int(meshcode[5:6])*base + lon
	
	base = base * 8
	lat = int(meshcode[0:2])*base + lat
	lon = int(meshcode[2:4])*base + lon
	
	if delta:
		return (float(lat)/(1.5*base), float(lon)/base+100.0, 1.0/(1.5*base), 1.0/base)
	else:
		return (float(lat)/(1.5*base), float(lon)/base+100.0)

def decode(meshcode):
	(a,b,c,d) = decode_ws(meshcode, True)
	return a+c/2.0, b+d/2.0

def bbox(meshcode):
	(a,b,c,d) = decode_ws(meshcode, True)
	return {'w':a, 's':b, 'n':b+d, 'e':a+c}
