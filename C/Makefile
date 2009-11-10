CC	= gcc
CFLAGS	= -O3
LDFLAGS	=
TARGET	= sample
OBJS	= geohash_sample.o geohash.o

all:	$(TARGET)
$(TARGET):	$(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
clean:
	-rm -f $(TARGET) $(OBJS)
.c.o:
	$(CC) $(CFLAGS) -c $<
