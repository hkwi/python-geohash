CXX	= g++
CXXFLAGS	= -O3
TARGET	= sample
OBJS	= geohash_sample.o geohash.o

all:	$(TARGET)
$(TARGET):	$(OBJS)
	$(CXX) -o $@ $(OBJS)
clean:
	-rm -f $(TARGET) $(OBJS)
.cpp.o:
	$(CXX) $(CXXFLAGS) -c $<
