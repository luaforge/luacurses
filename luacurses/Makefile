
SRC=src/curses.c src/luacurses.c
INCLUDE=src
LUA_CFLAGS=-I/usr/include/lua5.1
CFLAGS=-shared -ansi -Wall -O2 -I$(INCLUDE) $(LUA_CFLAGS) -fPIC
SYMLINK=ln -s

all: lib/curses.so

lib/curses.so: $(SRC)
	if ! [ -d lib ]; then mkdir lib; fi
	gcc $(CFLAGS) -o lib/curses.so $(SRC)
	$(SYMLINK) ../lib/curses.so test/curses.so

clean:
	if [ -L test/curses.so ]; then rm test/curses.so; fi
	rm -Rf lib
	
	
