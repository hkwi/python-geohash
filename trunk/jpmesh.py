# coding: UTF-8
# Coder for Japanese area mesh. (JIS C 6304 / JIS X 0410)
# 行政管理庁告示第143号 http://www.stat.go.jp/data/mesh/

def encode_tuple(lat, lon, duals=3):
	if lat<7 or lon<100:
		raise Exception('Unsupported location')
	
	a1 = int(lat*1.5)
	o1 = int(lon)%100
	a2 = int(lat * 12)%8
	o2 = int(lon *  8)%8
	a3 = int(lat * 120)%10
	o3 = int(lon *  80)%10
	
	ab = int(lat * 960)&15
	ob = int(lon * 640)&15
	
	if duals==0:
		return a1, o1, a2, o2, a3, o3
	
	d2 = 1+((ab>>1)&2)+(ob>>2)
	if duals==1:
		return a1, o1, a2, o2, a3, o3, d2
	
	d3 = 1+(ab&2)+((ob&2)>>1)
	if duals==2:
		return a1, o1, a2, o2, a3, o3, d2, d3
	
	d4 = 1+((ab<<1)&2)+(ob&1)
	return a1, o1, a2, o2, a3, o3, d2, d3, d4

def encode_uni5(lat, lon):
	if lat<7 or lon<100:
		raise Exception('Unsupported location')
	
	a1 = int(lat*1.5)
	o1 = int(lon)%100
	lat = int(lat * 24)
	lon = int(lon * 16)
	a2 = (lat>>1)%8
	o2 = (lon>>1)%8
	d = 1 + (lat&1)*2 + (lon&1)
	
	return a1, o1, a2, o2, d

def encode_uni2(lat, lon):
	if lat<7 or lon<100:
		raise Exception('Unsupported location')
	
	a1 = int(lat*1.5)
	o1 = int(lon)%100
	a2 = int(lat * 12)%8
	o2 = int(lon *  8)%8
	a3 = int(lat * 60)%5 * 2
	o3 = int(lon * 40)%5 * 2
	
	return a1, o1, a2, o2, a3, o3, 5


def encode(lat, lon, duals=3):
	return ''.join([str(i) for i in encode_tuple(lat,lon, duals)])

def decode_ws(meshcode, delta=True):
	level = len(meshcode)
	lat = lon = 0
	base = 1
	if level>8:
		if meshcode[8:]=='5': # Uni2 mesh
			pass
		else:
			for i in meshcode[8:]:
				i = int(i)-1
				lat = (lat<<1) + i/2
				lon = (lon<<1) + i%2
				base = base<<1
	
	if level>6:
		if level==7:
			base = base*5
			i = int(meshcode[7:8])-1
			lat += (i/2) * base
			lon += (i%2) * base
		else:
			lat += int(meshcode[6:7])*base
			lon += int(meshcode[7:8])*base
	
	if level>4:
		base = base*10
		lat += int(meshcode[4:5])*base
		lon += int(meshcode[5:6])*base
	
	base = base*8
	lat += int(meshcode[0:2])*base
	lon += int(meshcode[2:4])*base
	
	lat = float(lat)/(base*1.5)
	lon = float(lon)/base + 100.0
	if delta:
		return (lat, lon, 1.0/(base*1.5), 1.0/base)
	else:
		return (lat, lon)

def decode(meshcode):
	(a,b,c,d) = decode_ws(meshcode, True)
	return a+c/2.0, b+d/2.0

def bbox(meshcode):
	(a,b,c,d) = decode_ws(meshcode, True)
	return {'w':a, 's':b, 'n':b+d, 'e':a+c}


## short-cut methods
def encodeLv1(lat, lon):
	return encode(lat,lon,0)[0:4]

def encodeLv2(lat, lon):
	return encode(lat,lon,0)[0:6]

def encodeLv3(lat, lon):
	return encode(lat,lon,0)

def encodeBase(lat,lon):
	return encodeLv3(lat,lon)

def encodeHalf(lat,lon):
	return encode(lat,lon,1)

def encodeQuarter(lat,lon):
	return encode(lat,lon,2)

def encodeEighth(lat,lon):
	return encode(lat,lon,3)

def encodeUni10(lat,lon):
	return encodeLv2(lat,lon)

def encodeUni5(lat, lon):
	return ''.join([str(i) for i in encode_uni5(lat,lon)])

def encodeUni2(lat, lon):
	return ''.join([str(i) for i in encode_uni2(lat,lon)])
