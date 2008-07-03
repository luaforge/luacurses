
#include <stdlib.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include <curses.h>
#include "luacurses.h"

SCREEN* luacurses_toscreen(lua_State* L, int index)
{
    SCREEN** pscreen = (SCREEN**) luaL_checkudata(L, index, MKLUALIB_META_CURSES_SCREEN);
    if (!pscreen) luaL_argerror(L, index, "bad screen");
    if (!*pscreen) luaL_error(L, "attempt to use invalid screen");
    return *pscreen;
}

SCREEN** luacurses_newscreen(lua_State* L)
{
    SCREEN** pscreen = (SCREEN**) lua_newuserdata(L, sizeof(SCREEN*));
    *pscreen = 0;
    luaL_getmetatable(L, MKLUALIB_META_CURSES_SCREEN);
    lua_setmetatable(L, -2);
    return pscreen;
}

void luacurses_regscreen(lua_State* L, const char* name, SCREEN* userdata)
{
    lua_pushstring(L, name);
    SCREEN** pscreen = luacurses_newscreen(L);
    *pscreen = userdata;
    lua_settable(L, -3);
}

WINDOW* luacurses_towindow(lua_State* L, int index)
{
    WINDOW** pwindow = (WINDOW**) luaL_checkudata(L, index, MKLUALIB_META_CURSES_WINDOW);
    if (!pwindow) luaL_argerror(L, index, "bad window");
    if (!*pwindow) luaL_error(L, "attempt to use invalid window");
    return *pwindow;
}

WINDOW** luacurses_newwindow(lua_State* L)
{
    WINDOW** pwindow = (WINDOW**) lua_newuserdata(L, sizeof(WINDOW*));
    *pwindow = 0;
    luaL_getmetatable(L, MKLUALIB_META_CURSES_WINDOW);
    lua_setmetatable(L, -2);
    return pwindow;
}

void luacurses_regwindow(lua_State* L, const char* name, WINDOW* userdata)
{
    lua_pushstring(L, name);
    WINDOW** pwindow = luacurses_newwindow(L);
    *pwindow = userdata;
    lua_settable(L, -3);
}

FILE* tofile(lua_State* L, int index)
{
    FILE** pf = (FILE**) luaL_checkudata(L, index, MKLUALIB_META_CURSES_FILE);
    if (!pf) luaL_argerror(L, index, "bad file");
    if (!*pf) luaL_error(L, "attempt to use invalid file");
    return *pf;
}

FILE** newfile(lua_State* L)
{
    FILE** pf = (FILE**) lua_newuserdata(L, sizeof(FILE*));
    *pf = 0;
    luaL_getmetatable(L, MKLUALIB_META_CURSES_FILE);
    lua_setmetatable(L, -2);
    return pf;
}

void luacurses_regfile(lua_State* L, const char* name, FILE* f)
{
    lua_pushstring(L, name);
    FILE** pf = newfile(L);
    *pf = f;
    lua_settable(L, -3);
}

char* luacurses_wgetnstr(WINDOW* w, int n)
{
    char* s = (char*) malloc(n + 1);
    wgetnstr(w, s, n);
    return s;
}

char* luacurses_window_tostring(WINDOW* w)
{
    char* buf = (char*) malloc(64);
    sprintf(buf, "window %p", w);
    return buf;
}

char* luacurses_screen_tostring(SCREEN* s)
{
    char* buf = (char*) malloc(64);
    sprintf(buf, "screen %p", s);
    return buf;  
}

/**********************************************************************/

/*
 * Garbage collection (by Claude Marinier)
 *
 * Userdata which is dead and has a finalizer (a __gc field in its
 * metatable) is not collected immediately by the garbage collector.
 * Instead, Lua puts it in a list. After collection, Lua does the
 * equivalent of the following function for each userdata in that
 * list:
 *
 *    function gc_event (udata)
 *        local h = metatable(udata).__gc
 *        if h then
 *            h(udata)
 *        end
 *    end
 *
 * The above paragraph and pseude-code were taken from the Lua 5.1
 * manual. They imply that the finalize function is called with the
 * userdata as the only parameter. Seems it is actually called with
 * the Lua state.  Aha! the userdata is passed as a Lua arg, hence
 * the need for a lua_State.
 *
 * In "Programming In Lua", section 29.1, there is an example of a
 * gc metamethod.
 *
 *     static int dir_gc (lua_State *L) {
 *         DIR *d = *(DIR **)lua_touserdata(L, 1);
 *         if (d) closedir(d);
 *         return 0;
 *     }
 */

int luacurses_screen_free(lua_State* L)
{
    SCREEN** pscreen = (SCREEN**) luaL_checkudata(L, 1, MKLUALIB_META_CURSES_SCREEN);
    if (!pscreen)
    {
	return luaL_argerror(L,	1, "bad screen, screen_gc");
    }
    if (*pscreen)
    {
	delscreen(*pscreen);
	*pscreen = 0;  /* make sure we only do this once */
    }
    return 0;
}

int luacurses_window_free(lua_State* L)
{
    WINDOW** pwindow = (WINDOW**) luaL_checkudata(L, 1, MKLUALIB_META_CURSES_WINDOW);
    if (!pwindow)
    {
	return luaL_argerror(L, 1, "bad window, win_gc");
    }
    if (*pwindow)
    {
	/*
	 * the Lua value created by curses.stdscr() will
	 * eventually end up here
	 * do not delete the corresponding stdscr window
	 */
	if(*pwindow != stdscr) delwin(*pwindow);
	*pwindow = 0;   /* make sure we only do this once */
    }
    return 0;
}

int luacurses_delscreen(lua_State* L)
{
    SCREEN** pscreen = (SCREEN**) luaL_checkudata(L, 1, MKLUALIB_META_CURSES_SCREEN);
    if (!pscreen)
    {
	return luaL_argerror(L, 1, "bad screen, delscreen");
    }
    if (!*pscreen)
    {
	return luaL_error(L, "attempt to use invalid screen, delscreen");
    }
    delscreen(*pscreen);
    *pscreen = 0;  /* make sure we only do this once */
    return 0;
}

/**********************************************************************/


bool luacurses_getmouse(short* id, int* x, int* y, int* z, mmask_t* bstate)
{
    MEVENT e;
    int res = getmouse(&e);

    *id = e.id;
    *x = e.x;
    *y = e.y;
    *z = e.z;
    *bstate = e.bstate;
    return (res == OK);
}

bool luacurses_ungetmouse (short id, int x, int y, int z, mmask_t bstate)
{
    MEVENT e;
    e.id = id;
    e.x = x;
    e.y = y;
    e.z = z;
    e.bstate = bstate;
    return (ungetmouse(&e) == OK);
}

mmask_t luacurses_addmousemask(mmask_t m)
{
    mmask_t old;
    mousemask(m, &old);
    return mousemask(old | m, 0);
}

