# coding: UTF-8
"""
Copyright (C) 2009 Hiroaki Kawai <kawai@iij.ad.jp>
"""
__all__ = ['encode','decode','decode_exactly','bbox']

_base32 = '0123456789bcdefghjkmnpqrstuvwxyz'
_base32_map = {}
for i in range(len(_base32)):
	_base32_map[_base32[i]] = i
del i

# def _binstr(b, length=32):
# 	t = []
# 	while length>0:
# 		if b&1:
# 			t.append('1')
# 		else:
# 			t.append('0')
# 		b=b>>1
# 		length-=1
# 	
# 	t.reverse()
# 	return ''.join(t)

def encode(latitude, longitude, precision=12):
	if latitude > 90.0 or latitude < -90.0:
		raise Exception("invalid latitude.")
	while longitude > 180.0:
		longitude -= 360.0
	while longitude < -180.0:
		longitude += 360.0
	
	lat = (latitude+90.0)/180.0
	lon = (longitude+180.0)/360.0
	
	lat_length=lon_length=precision*5/2
	odd = False
	if precision%2==1:
		odd = True
		lon_length+=1
	
	if odd:
		b = int((1<<lat_length)*lat)
		a = int((1<<lon_length)*lon)
	else:
		a = int((1<<lat_length)*lat)
		b = int((1<<lon_length)*lon)
	
	ret = ''
	while precision>0:
		c = ((a&4)<<2) + ((b&2)<<2) + ((a&2)<<1) + ((b&1)<<1) + (a&1)
		ret += _base32[c]
		t = a>>3
		a = b>>2
		b = t
		precision-=1
	
	return ret[::-1]

def decode(hashcode, delta=False):
	lon = 0
	lat = 0
	bit_length = 0
	lat_length = 0
	lon_length = 0
	for i in hashcode:
		t = _base32_map[i]
		if bit_length%2==0:
			lon = lon<<3
			lat = lat<<2
			lon += (t>>2)&4
			lat += (t>>2)&2
			lon += (t>>1)&2
			lat += (t>>1)&1
			lon += t&1
			lon_length+=3
			lat_length+=2
		else:
			lon = lon<<2
			lat = lat<<3
			lat += (t>>2)&4
			lon += (t>>2)&2
			lat += (t>>1)&2
			lon += (t>>1)&1
			lat += t&1
			lon_length+=2
			lat_length+=3
		
		bit_length+=5
	
	lat = (lat<<1) + 1
	lon = (lon<<1) + 1
	lat_length += 1
	lon_length += 1
	
	latitude  = 180.0*lat/(1<<lat_length) - 90.0
	longitude = 360.0*lon/(1<<lon_length) - 180.0
	if delta:
		latitude_delta  = 180.0/(1<<lat_length)
		longitude_delta = 360.0/(1<<lon_length)
		return latitude,longitude,latitude_delta,longitude_delta
	
	return latitude,longitude

def decode_exactly(hashcode):
	return decode(hashcode, True)

def bbox(hashcode):
	lon = 0
	lat = 0
	bit_length = 0
	lat_length = 0
	lon_length = 0
	for i in hashcode:
		t = _base32_map[i]
		if bit_length%2==0:
			lon = lon<<3
			lat = lat<<2
			lon += (t>>2)&4
			lat += (t>>2)&2
			lon += (t>>1)&2
			lat += (t>>1)&1
			lon += t&1
			lon_length+=3
			lat_length+=2
		else:
			lon = lon<<2
			lat = lat<<3
			lat += (t>>2)&4
			lon += (t>>2)&2
			lat += (t>>1)&2
			lon += (t>>1)&1
			lat += t&1
			lon_length+=2
			lat_length+=3
		
		bit_length+=5
	
	ret={}
	ret['n'] = 180.0*(lat+1)/(1<<lat_length) - 90.0
	ret['s'] = 180.0*lat/(1<<lat_length) - 90.0
	ret['e'] = 360.0*(lon+1)/(1<<lon_length) - 180.0
	ret['w'] = 360.0*lon/(1<<lon_length) - 180.0
	return ret
