CFLAGS=-W -Wall
LDFLAGS=-lz

all: lzma2eva

lzma2eva: lzma2eva.c
	$(CC) -o $@ $^ -lz

clean:
	rm -f lzma2eva *.o

.PHONY: all clean
