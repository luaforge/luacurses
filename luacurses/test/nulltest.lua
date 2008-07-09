
require("curses");

curses.initscr();
curses.cbreak();
while true do
    curses.addstr("Enter size of window (format: nlines, ncols) or quit\n");
    local line = curses.getnstr(1000);
    if not line then curses.addstr("line = nil\n"); line = ""; end
    if (line == "quit" or line == "exit") then break; end
    local b, e, nl, nc = string.find(line, "^(-?%d*),%s*(-?%d*)$");
    if not nl or not nc then
	curses.addstr("Invalid string format\n");
    else
	curses.addstr("Creating window with size (" .. nl .. ", " .. nc .. ") ");
	local w = curses.newwin(nl, nc, 0, 0);
	if not w then
	    curses.addstr("failed\n");
	else
	    curses.addstr("successful\n");
	    curses.delwin(w);
	end
    end
end

curses.endwin();

