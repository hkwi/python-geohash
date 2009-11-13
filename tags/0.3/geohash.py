# coding: UTF-8
"""
Copyright (C) 2009 Hiroaki Kawai <kawai@iij.ad.jp>
"""
try:
	import _geohash
except ImportError,e:
	_geohash = None

__all__ = ['encode','decode','decode_exactly','bbox', 'neighbors', 'expand']

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

def _encode_i2c(lat,lon,lat_length,lon_length):
	precision=(lat_length+lon_length)/5
	if lat_length < lon_length:
		a = lon
		b = lat
	else:
		a = lat
		b = lon
	
	ret = ''
	while precision>0:
		c = ((a&4)<<2) + ((b&2)<<2) + ((a&2)<<1) + ((b&1)<<1) + (a&1)
		ret += _base32[c]
		t = a>>3
		a = b>>2
		b = t
		precision-=1
	
	return ret[::-1]

def encode(latitude, longitude, precision=12):
	if latitude > 90.0 or latitude < -90.0:
		raise Exception("invalid latitude.")
	while longitude < -180.0:
		longitude += 360.0
	while longitude >= 180.0:
		longitude -= 360.0
	
	if _geohash:
		basecode=_geohash.encode(latitude,longitude)
		if len(basecode)>precision:
			return basecode[0:precision]
		return basecode+'0'*(precision-len(basecode))
	
	lat = (latitude+90.0)/180.0
	lon = (longitude+180.0)/360.0
	
	lat_length=lon_length=precision*5/2
	if precision%2==1:
		lon_length+=1
	
	lat = int((1<<lat_length)*lat)
	lon = int((1<<lon_length)*lon)
	
	return _encode_i2c(lat,lon,lat_length,lon_length)

def _decode_c2i(hashcode):
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
	
	return (lat,lon,lat_length,lon_length)

def decode(hashcode, delta=False):
	'''
	decode a hashcode and get center coordinate, and distance between center and outer border
	'''
	if _geohash:
		(lat,lon,lat_bits,lon_bits) = _geohash.decode(hashcode)
		latitude_delta = 180.0/(2<<lat_bits)
		longitude_delta = 360.0/(2<<lon_bits)
		latitude = lat + latitude_delta
		longitude = lon + longitude_delta
		if delta:
			return latitude,longitude,latitude_delta,longitude_delta
		return latitude,longitude
	
	(lat,lon,lat_length,lon_length) = _decode_c2i(hashcode)
	
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

## hashcode operations below

def bbox(hashcode):
	'''
	decode a hashcode and get north, south, east and west border.
	'''
	if _geohash:
		(lat,lon,lat_bits,lon_bits) = _geohash.decode(hashcode)
		latitude_delta = 180.0/(1<<lat_bits)
		longitude_delta = 360.0/(1<<lon_bits)
		return {'s':lat,'e':lon,'n':lat+latitude_delta,'w':lon+longitude_delta}
	
	(lat,lon,lat_length,lon_length) = _decode_c2i(hashcode)
	
	ret={}
	ret['n'] = 180.0*(lat+1)/(1<<lat_length) - 90.0
	ret['s'] = 180.0*lat/(1<<lat_length) - 90.0
	ret['e'] = 360.0*(lon+1)/(1<<lon_length) - 180.0
	ret['w'] = 360.0*lon/(1<<lon_length) - 180.0
	return ret

def neighbors(hashcode):
	if _geohash and len(hashcode)<25:
		return _geohash.neighbors(hashcode)
	(lat,lon,lat_length,lon_length) = _decode_c2i(hashcode)
	ret = []
	tlat = lat
	for tlon in (lon-1, lon+1):
		ret.append(_encode_i2c(tlat,tlon,lat_length,lon_length))
	
	tlat = lat+1
	if not tlat >> lat_length:
		for tlon in (lon-1, lon, lon+1):
			ret.append(_encode_i2c(tlat,tlon,lat_length,lon_length))
	
	tlat = lat-1
	if tlat >= 0:
		for tlon in (lon-1, lon, lon+1):
			ret.append(_encode_i2c(tlat,tlon,lat_length,lon_length))
	
	return ret

def expand(hashcode):
	ret = neighbors(hashcode)
	ret.append(hashcode)
	return ret
