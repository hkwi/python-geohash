#include <stdio.h>
#include <math.h>
#include <stdint.h>
#include "geohash.h"
#include <sys/param.h>

#if !defined(__LITTLE_ENDIAN__) && !defined(__BIG_ENDIAN__) /* MacOS X style */
#ifdef __BYTE_ORDER /* Linux style */
# if __BYTE_ORDER == __LITTLE_ENDIAN
#  define __LITTLE_ENDIAN__
# endif
# if __BYTE_ORDER == __BIG_ENDIAN
#  define __BIG_ENDIAN__
# endif
#endif
#ifdef BYTE_ORDER /* MinGW style */
# if BYTE_ORDER == LITTLE_ENDIAN
#  define __LITTLE_ENDIAN__
# endif
# if BYTE_ORDER == BIG_ENDIAN
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


#ifdef PYTHON_MODULE
#include <Python.h>
static PyObject *py_geohash_encode(PyObject *self, PyObject *args) {
	double latitude;
	double longitude;
	char hashcode[24];
	int ret = GEOHASH_OK;
	
	if(!PyArg_ParseTuple(args, "dd", &latitude, &longitude)) return NULL;
	
	if((ret=geohash_encode(latitude,longitude,hashcode,24))!=GEOHASH_OK){
		if(ret==GEOHASH_NOTSUPPORTED) PyErr_SetString(PyExc_EnvironmentError, "unknown endian");
		return NULL;
	}
	return Py_BuildValue("s",hashcode);
}
static PyObject *py_geohash_decode(PyObject *self, PyObject *args) {
	double latitude;
	double longitude;
	char *hashcode;
	int codelen=0;
	int ret = GEOHASH_OK;
	
	if(!PyArg_ParseTuple(args, "s", &hashcode)) return NULL;
	
	codelen = strlen(hashcode);
	if((ret=geohash_decode(hashcode,codelen,&latitude,&longitude))!=GEOHASH_OK){
		PyErr_SetString(PyExc_ValueError,"geohash code is [0123456789bcdefghjkmnpqrstuvwxyz]+");
		return NULL;
	}
	return Py_BuildValue("(ddii)",latitude,longitude, codelen/2*5+codelen%2*2, codelen/2*5+codelen%2*3);
}

static PyObject *py_geohash_neighbors(PyObject *self, PyObject *args) {
	static const unsigned char mapA[128] = {
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
	static const char rmap[32]="0123456789bcdefghjkmnpqrstuvwxyz";
	uint64_t lat, lon;
	char *hashcode;
	if(!PyArg_ParseTuple(args, "s", &hashcode)) return NULL;
	
	int length = strlen(hashcode);
	if(length>24){ length=24; } // round if the hashcode is too long (over 64bit)
	lat=lon=0;
	int cshift=0;
	while(cshift<length){
		unsigned char o1 = mapA[(unsigned char)hashcode[cshift]];
		if(o1=='@'){ break; }
		if(o1=='|'){
			PyErr_SetString(PyExc_ValueError,"geohash code is [0123456789bcdefghjkmnpqrstuvwxyz]+");
			return NULL;
		}
		if(cshift%2==0){
			lon = (lon<<3) | ((o1&0x10)>>2) | ((o1&0x04)>>1) | (o1&0x01);
			lat = (lat<<2) | ((o1&0x08)>>2) | ((o1&0x02)>>1);
		}else{
			lon = (lon<<2) | ((o1&0x08)>>2) | ((o1&0x02)>>1);
			lat = (lat<<3) | ((o1&0x10)>>2) | ((o1&0x04)>>1) | (o1&0x01);
		}
		cshift++;
	}
	
	char* buffer = (char*)malloc(8*(length+1)*sizeof(char));
	if(buffer==NULL){
		PyErr_NoMemory();
		return NULL;
	}
	int al=-1;
	int au=2;
	if(lat==0){
		al=0; au=2;
	}else if(lat+1==(1<<(length/2*5+length%2*2))){
		al=-1; au=1;
	}
	int blen=length+1; // block length
	int aoff=0;
	int a,o;
	for(a=al;a<au;a++){
		for(o=-1;o<2;o++){
			if(a==0 && o==0) continue;
			uint64_t ta = lat+a;
			uint64_t to = lon+o;
			buffer[blen*aoff+length]='\0';
			int cpos = length-1;
			while(cpos>=0){
				unsigned char z;
				if(cpos%2==0){
					z = ((to&4)<<2)|((to&2)<<1)|(to&1)|((ta&2)<<2)|((ta&1)<<1);
					buffer[blen*aoff+cpos]=rmap[z];
					ta=ta>>2;
					to=to>>3;
				}else{
					z = ((ta&4)<<2)|((ta&2)<<1)|(ta&1)|((to&2)<<2)|((to&1)<<1);
					buffer[blen*aoff+cpos]=rmap[z];
					ta=ta>>3;
					to=to>>2;
				}
				cpos--;
			}
			aoff++;
		}
	}
	PyObject *ret;
	if(lat==0){
		ret= Py_BuildValue("[sssss]",&buffer[0],&buffer[blen],&buffer[blen*2],&buffer[blen*3],&buffer[blen*4]);
	}else if(lat+1==(1<<(cshift/2*5+cshift%2*2))){
		ret= Py_BuildValue("[sssss]",&buffer[0],&buffer[blen],&buffer[blen*2],&buffer[blen*3],&buffer[blen*4]);
	}else{
		ret= Py_BuildValue("[ssssssss]",&buffer[0],&buffer[blen],&buffer[blen*2],&buffer[blen*3],
			&buffer[blen*4],&buffer[blen*5],&buffer[blen*6],&buffer[blen*7]);
	}
	free(buffer);
	return ret;
}

static PyMethodDef GeohashMethods[] = {
	{"encode", py_geohash_encode, METH_VARARGS, "geohash encoding."},
	{"decode", py_geohash_decode, METH_VARARGS, "geohash decoding."},
	{"neighbors", py_geohash_neighbors, METH_VARARGS, "geohash neighbor codes",},
	{NULL, NULL, 0, NULL}
};

PyMODINIT_FUNC init_geohash(void){
	(void)Py_InitModule("_geohash", GeohashMethods);
}
#endif /* PYTHON_MODULE */

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
	
	if(capacity<23){
		return GEOHASH_OVERFLOW;
	}
#ifdef __UNSUPPORTED_ENDIAN__
	r[0]='\0';
	return GEOHASH_NOTSUPPORTED;
#endif
	
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
	r[22]='\0';
	return GEOHASH_OK;
}

/*
   (latitude, longitude) will be that of south west point.
*/
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
		o1 = map[(unsigned char)r[cshift]];
		if(o1=='@'){ break; }
		cshift++;
		if(cshift<length){
			o2 = map[(unsigned char)r[cshift]];
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
