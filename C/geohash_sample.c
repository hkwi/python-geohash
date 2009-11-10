#include <stdio.h>
#include "geohash.h"

int main(int argc,char* argv[]){
	char r[23];
	double lat,lon;
	if(geohash_encode(35.0, 135.0, r, 23)==GEOHASH_OK){
		printf("%s\n",r);
	}
	if(geohash_decode(r,23,&lat,&lon)==GEOHASH_OK){
		printf("%f %f\n",lat,lon);
	}
}
