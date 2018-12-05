#ifdef __cplusplus
extern "C" {
#endif

enum {
	GEOHASH_OK,
	GEOHASH_NOTSUPPORTED,
	GEOHASH_INVALIDCODE,
	GEOHASH_INVALIDARGUMENT,
	GEOHASH_INTERNALERROR,
	GEOHASH_NOMEMORY
};

int geohash_encode(double latitude, double longitude, char* r, size_t capacity);
int geohash_decode(char* r, size_t length, double *latitude, double *longitude);
int geo_neighbors(char *hashcode, char* dst, size_t dst_length, int *string_count);

#ifdef __cplusplus
}
#endif
