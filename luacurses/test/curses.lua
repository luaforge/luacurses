
mklualib_open_curses = loadlib("../lib/luacurses.so", "mklualib_open_curses");
assert(mklualib_open_curses, "can't load curses library");
mklualib_open_curses();
