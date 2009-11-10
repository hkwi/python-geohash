#include <stdio.h>
#include <math.h>
#include <stdint.h>
#include "geohash.h"

#if !defined(__LITTLE_ENDIAN__) && !defined(__BIG_ENDIAN__)
#ifdef __BYTE_ORDER
# if __BYTE_ORDER == __LITTLE_ENDIAN
#  define __LITTLE_ENDIAN__
# endif
# if __BYTE_ORDER == __BIG_ENDIAN
#  define __BIG_ENDIAN__
# endif
#endif
#endif

#if !defined(__LITTLE_ENDIAN__) && !defined(__BIG_ENDIAN__)
/* I don't have __PDP_ENDIAN machine. Please let me know if you have one. */
#define __UNSUPPORTED_ENDIAN__
#endif

#ifdef __LITTLE_ENDIAN__
#define B6 6
#define B5 5
#define B4 4
#define B3 3
#define B2 2
#define B1 1
#define B0 0
#endif

#ifdef __BIG_ENDIAN__
#define B6 1
#define B5 2
#define B4 3
#define B3 4
#define B2 5
#define B1 6
#define B0 7
#endif

int geohash_encode(double latitude, double longitude, char* r, size_t capacity){
	static const char* map="0123456789bcdefghjkmnpqrstuvwxyz";
	union {
		double d; // assuming IEEE 754-1985 binary64. This might not be true on some CPU (I don't know which).
		unsigned char s[8];
		// formally, we should use unsigned char for type-punning (see C99 ISO/IEC 9899:201x spec 6.2.6)
		uint64_t i64;
	} lat, lon;
	unsigned short lat_exp, lon_exp;
	uint16_t tmp;
	
#ifdef __UNSUPPORTED_ENDIAN__
	return GEOHASH_NOTSUPPORTED;
#endif
	
	if(capacity<23){
		return GEOHASH_OVERFLOW;
	}
	lat.d = (latitude+90.0)/180.0;
	lon.d = (longitude+180.0)/360.0;
	
	lat.d = lat.d-floor(lat.d);
	lon.d = lon.d-floor(lon.d);
	
	lat_exp = (lat.i64>>52) & 0x7FFLL;
	lon_exp = (lon.i64>>52) & 0x7FFLL;
	
	lat.i64 = (lat.i64 & 0xFFFFFFFFFFFFFLL) | 0x10000000000000LL;
	lon.i64 = (lon.i64 & 0xFFFFFFFFFFFFFLL) | 0x10000000000000LL;
	if(lat_exp<1022){ lat.i64 = lat.i64>>(1022-lat_exp); }
	if(lon_exp<1022){ lon.i64 = lon.i64>>(1022-lon_exp); }
	
	r[22]='\0';
	tmp = 0;
	tmp |= ((lon.s[B6]&0x10)<<5) | ((lat.s[B6]&0x10)<<4);
	tmp |= ((lon.s[B6]&0x08)<<4) | ((lat.s[B6]&0x08)<<3);
	tmp |= ((lon.s[B6]&0x04)<<3) | ((lat.s[B6]&0x04)<<2);
	tmp |= ((lon.s[B6]&0x02)<<2) | ((lat.s[B6]&0x02)<<1);
	tmp |= ((lon.s[B6]&0x01)<<1) | ((lat.s[B6]&0x01)<<0);
	r[0]=map[tmp>>5];
	r[1]=map[tmp&0x1F];
	tmp = 0;
	tmp |= ((lon.s[B5]&0x80)<<2) | ((lat.s[B5]&0x80)<<1);
	tmp |= ((lon.s[B5]&0x40)<<1) | ((lat.s[B5]&0x40)<<0);
	tmp |= ((lon.s[B5]&0x20)<<0) | ((lat.s[B5]&0x20)>>1);
	tmp |= ((lon.s[B5]&0x10)>>1) | ((lat.s[B5]&0x10)>>2);
	tmp |= ((lon.s[B5]&0x08)>>2) | ((lat.s[B5]&0x08)>>3);
	r[2]=map[tmp>>5];
	r[3]=map[tmp&0x1F];
	tmp = 0;
	tmp |= ((lon.s[B5]&0x04)<<7) | ((lat.s[B5]&0x04)<<6);
	tmp |= ((lon.s[B5]&0x02)<<6) | ((lat.s[B5]&0x02)<<5);
	tmp |= ((lon.s[B5]&0x01)<<5) | ((lat.s[B5]&0x01)<<4);
	tmp |= ((lon.s[B4]&0x80)>>4) | ((lat.s[B4]&0x80)>>5);
	tmp |= ((lon.s[B4]&0x40)>>5) | ((lat.s[B4]&0x40)>>6);
	r[4]=map[tmp>>5];
	r[5]=map[tmp&0x1F];
	tmp = 0;
	tmp |= ((lon.s[B4]&0x20)<<4) | ((lat.s[B4]&0x20)<<3);
	tmp |= ((lon.s[B4]&0x10)<<3) | ((lat.s[B4]&0x10)<<2);
	tmp |= ((lon.s[B4]&0x08)<<2) | ((lat.s[B4]&0x08)<<1);
	tmp |= ((lon.s[B4]&0x04)<<1) | ((lat.s[B4]&0x04)<<0);
	tmp |= ((lon.s[B4]&0x02)<<0) | ((lat.s[B4]&0x02)>>1);
	r[6]=map[tmp>>5];
	r[7]=map[tmp&0x1F];
	tmp = 0;
	tmp |= ((lon.s[B4]&0x01)<<9) | ((lat.s[B4]&0x01)<<8);
	tmp |= ((lon.s[B3]&0x80)<<0) | ((lat.s[B3]&0x80)>>1);
	tmp |= ((lon.s[B3]&0x40)>>1) | ((lat.s[B3]&0x40)>>2);
	tmp |= ((lon.s[B3]&0x20)>>2) | ((lat.s[B3]&0x20)>>3);
	tmp |= ((lon.s[B3]&0x10)>>3) | ((lat.s[B3]&0x10)>>4);
	r[8]=map[tmp>>5];
	r[9]=map[tmp&0x1F];
	tmp = 0;
	tmp |= ((lon.s[B3]&0x08)<<6) | ((lat.s[B3]&0x08)<<5);
	tmp |= ((lon.s[B3]&0x04)<<5) | ((lat.s[B3]&0x04)<<4);
	tmp |= ((lon.s[B3]&0x02)<<4) | ((lat.s[B3]&0x02)<<3);
	tmp |= ((lon.s[B3]&0x01)<<3) | ((lat.s[B3]&0x01)<<2);
	tmp |= ((lon.s[B2]&0x80)>>6) | ((lat.s[B2]&0x80)>>7);
	r[10]=map[tmp>>5];
	r[11]=map[tmp&0x1F];
	tmp = 0;
	tmp |= ((lon.s[B2]&0x40)<<3) | ((lat.s[B2]&0x40)<<2);
	tmp |= ((lon.s[B2]&0x20)<<2) | ((lat.s[B2]&0x20)<<1);
	tmp |= ((lon.s[B2]&0x10)<<1) | ((lat.s[B2]&0x10)<<0);
	tmp |= ((lon.s[B2]&0x08)<<0) | ((lat.s[B2]&0x08)>>1);
	tmp |= ((lon.s[B2]&0x04)>>1) | ((lat.s[B2]&0x04)>>2);
	r[12]=map[tmp>>5];
	r[13]=map[tmp&0x1F];
	tmp = 0;
	tmp |= ((lon.s[B2]&0x02)<<8) | ((lat.s[B2]&0x02)<<7);
	tmp |= ((lon.s[B2]&0x01)<<7) | ((lat.s[B2]&0x01)<<6);
	tmp |= ((lon.s[B1]&0x80)>>2) | ((lat.s[B1]&0x80)>>3);
	tmp |= ((lon.s[B1]&0x40)>>3) | ((lat.s[B1]&0x40)>>4);
	tmp |= ((lon.s[B1]&0x20)>>4) | ((lat.s[B1]&0x20)>>5);
	r[14]=map[tmp>>5];
	r[15]=map[tmp&0x1F];
	tmp = 0;
	tmp |= ((lon.s[B1]&0x10)<<5) | ((lat.s[B1]&0x10)<<4);
	tmp |= ((lon.s[B1]&0x08)<<4) | ((lat.s[B1]&0x08)<<3);
	tmp |= ((lon.s[B1]&0x04)<<3) | ((lat.s[B1]&0x04)<<2);
	tmp |= ((lon.s[B1]&0x02)<<2) | ((lat.s[B1]&0x02)<<1);
	tmp |= ((lon.s[B1]&0x01)<<1) | ((lat.s[B1]&0x01)<<0);
	r[16]=map[tmp>>5];
	r[17]=map[tmp&0x1F];
	tmp = 0;
	tmp |= ((lon.s[B0]&0x80)<<2) | ((lat.s[B0]&0x80)<<1);
	tmp |= ((lon.s[B0]&0x40)<<1) | ((lat.s[B0]&0x40)<<0);
	tmp |= ((lon.s[B0]&0x20)<<0) | ((lat.s[B0]&0x20)>>1);
	tmp |= ((lon.s[B0]&0x10)>>1) | ((lat.s[B0]&0x10)>>2);
	tmp |= ((lon.s[B0]&0x08)>>2) | ((lat.s[B0]&0x08)>>3);
	r[18]=map[tmp>>5];
	r[19]=map[tmp&0x1F];
	tmp = 0;
	tmp |= ((lon.s[B0]&0x04)<<7) | ((lat.s[B0]&0x04)<<6);
	tmp |= ((lon.s[B0]&0x02)<<6) | ((lat.s[B0]&0x02)<<5);
	tmp |= ((lon.s[B0]&0x01)<<5) | ((lat.s[B0]&0x01)<<4);
	r[20]=map[tmp>>5];
	r[21]=map[tmp&0x1F];
	return GEOHASH_OK;
}

int geohash_decode(char* r, size_t length, double *latitude, double *longitude){
	static const unsigned char map[128] = {
		  '@',  '|',  '|',  '|',  '|',  '|',  '|',  '|',
		  '|',  '|',  '|',  '|',  '|',  '|',  '|',  '|',
		  '|',  '|',  '|',  '|',  '|',  '|',  '|',  '|',
		  '|',  '|',  '|',  '|',  '|',  '|',  '|',  '|',
		  '|',  '|',  '|',  '|',  '|',  '|',  '|',  '|',
		  '|',  '|',  '|',  '|',  '|',  '|',  '|',  '|',
		    0,    1,    2,    3,    4,    5,    6,    7,
		    8,    9,  '|',  '|',  '|',  '|',  '|',  '|',
		  '|',  '|', 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
		 0x10,  '|', 0x11, 0x12,  '|', 0x13, 0x14,  '|',
		 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C,
		 0x1D, 0x1E, 0x1F,  '|',  '|',  '|',  '|',  '|',
		  '|',  '|', 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
		 0x10,  '|', 0x11, 0x12,  '|', 0x13, 0x14,  '|',
		 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C,
		 0x1D, 0x1E, 0x1F,  '|',  '|',  '|',  '|',  '|',
	};
	int cshift=0;
	uint64_t base, lat, lon;
	if(length>24){ length=24; } // round if the hashcode is too long (over 64bit)
	base=lat=lon=0;
	while(cshift<length){
		unsigned char o1,o2;
		o1 = map[r[cshift]];
		if(o1=='@'){ break; }
		cshift++;
		if(cshift<length){
			o2 = map[r[cshift]];
		}else{
			o2 = 0;
		}
		cshift++;
		if(o1=='|' || o2=='|'){
			return GEOHASH_INVALIDCODE;
		}
		lon = lon<<5 | (o1&0x10)<<0 | (o1&0x04)<<1 | (o1&0x01)<<2 | (o2&0x08)>>2 | (o2&0x02)>>1;
		lat = lat<<5 | (o1&0x08)<<1 | (o1&0x02)<<2 | (o2&0x10)>>2 | (o2&0x04)>>1 | (o2&0x01)>>0;
		if(o2=='@'){ break; }
	}
	base = 1LL<<(5*cshift/2);
	*latitude = 180.0*(double)lat/(double)base - 90.0;
	*longitude = 360.0*(double)lon/(double)base - 180.0;
	return GEOHASH_OK;
}
