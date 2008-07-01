
SRC=src/curses.c src/luacurses.c
INCLUDE=src
CFLAGS=-shared -ansi -Wall -O2 -I$(INCLUDE)

all: lib/luacurses.so

lib/luacurses.so: $(SRC)
	if ! [ -d lib ]; then mkdir lib; fi
	gcc $(CFLAGS) -o lib/luacurses.so $(SRC)

clean:
	rm -Rf lib
	
	
