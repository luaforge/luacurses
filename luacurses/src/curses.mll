
@#include <curses.h>
@#include "luacurses.h"

!module curses;

!typedef unsigned long chtype;
!typedef chtype attr_t;

int OK;
int ERR;

int WA_ATTRIBUTES;
int WA_NORMAL;
int WA_STANDOUT;
int WA_UNDERLINE;
int WA_REVERSE;
int WA_BLINK;
int WA_DIM;
int WA_BOLD;
int WA_ALTCHARSET;
int WA_INVIS;
int WA_PROTECT;
int WA_HORIZONTAL;
int WA_LEFT;
int WA_LOW;
int WA_RIGHT;
int WA_TOP;
int WA_VERTICAL;

int COLORS();%
int COLOR_PAIRS();%


int COLOR_BLACK;
int COLOR_RED;
int COLOR_GREEN;
int COLOR_YELLOW;
int COLOR_BLUE;
int COLOR_MAGENTA;
int COLOR_CYAN;
int COLOR_WHITE;

int NCURSES_ACS(char c);

#/* VT100 symbols begin here */
int ACS_ULCORNER();%
int ACS_LLCORNER();%
int ACS_URCORNER();%
int ACS_LRCORNER();%
int ACS_LTEE();%
int ACS_RTEE();%
int ACS_BTEE();%
int ACS_TTEE();%
int ACS_HLINE();%
int ACS_VLINE();%
int ACS_PLUS();%
int ACS_S1();%
int ACS_S9();%
int ACS_DIAMOND();%
int ACS_CKBOARD();%
int ACS_DEGREE();%
int ACS_PLMINUS();%
int ACS_BULLET();%
#/* Teletype 5410v1 symbols begin here */
int ACS_LARROW();%
int ACS_RARROW();%
int ACS_DARROW();%
int ACS_UARROW();%
int ACS_BOARD();%
int ACS_LANTERN();%
int ACS_BLOCK();%
#/*
# * These aren't documented, but a lot of System Vs have them anyway
# * (you can spot pprryyzz{{||}} in a lot of AT&T terminfo strings).
# * The ACS_names may not match AT&T's, our source didn't know them.
# */
int ACS_S3();%
int ACS_S7();%
int ACS_LEQUAL();%
int ACS_GEQUAL();%
int ACS_PI();%
int ACS_NEQUAL();%
int ACS_STERLING();%

#/*
# * Line drawing ACS names are of the form ACS_trbl, where t is the top, r
# * is the right, b is the bottom, and l is the left.  t, r, b, and l might
# * be B (blank), S (single), D (double), or T (thick).  The subset defined
# * here only uses B and S.
# */
int ACS_BSSB();%
int ACS_SSBB();%
int ACS_BBSS();%
int ACS_SBBS();%
int ACS_SBSS();%
int ACS_SSSB();%
int ACS_SSBS();%
int ACS_BSSS();%
int ACS_BSBS();%
int ACS_SBSB();%
int ACS_SSSS();%

# we can't use standard 'registerfile' because it has wrong format
!meta FILE*; ! @file @tofile @newfile @luacurses_regfile

!meta SCREEN*; @screen @luacurses_toscreen @luacurses_newscreen @luacurses_regscreen
void luacurses_delscreen (lua_State*);= @delscreen ^ @delscreen
SCREEN * set_term (SCREEN *); ^
char* luacurses_screen_tostring(SCREEN* s);$ @__tostring
void luacurses_screen_free(lua_State*);= @__gc
!endmeta SCREEN*;

!meta WINDOW*; @window @luacurses_towindow @luacurses_newwindow @luacurses_regwindow

char* luacurses_window_tostring(WINDOW* w);$ @__tostring
void luacurses_window_free(lua_State*);= @__gc

int box (WINDOW *, chtype, chtype); ^
int clearok (WINDOW *,bool); ^
int luacurses_delwin (lua_State*);= @delwin ^ @delwin
WINDOW * derwin (WINDOW *,int,int,int,int); ^
WINDOW * dupwin (WINDOW *); ^
chtype getbkgd (WINDOW *); ^
void idcok (WINDOW *, bool); ^
int idlok (WINDOW *, bool); ^
void immedok (WINDOW *, bool); ^
int intrflush (WINDOW *,bool); ^
bool is_linetouched (WINDOW *,int); ^
bool is_wintouched (WINDOW *); ^
int keypad (WINDOW *,bool); ^
int leaveok (WINDOW *,bool); ^
int meta (WINDOW *,bool); ^
int mvderwin (WINDOW *, int, int); ^
int mvwaddch (WINDOW *, int, int, const chtype); @mvaddch ^
#int mvwaddchnstr (WINDOW *, int, int, const chtype *, int); @mvaddchnstr ^
#int mvwaddchstr (WINDOW *, int, int, const chtype *); @mvaddchstr ^
#int mvwaddnstr (WINDOW *, int, int, const char *, int); @mvaddnstr ^
int mvwaddstr (WINDOW *, int, int, const char *); @mvaddstr ^
int mvwchgat (WINDOW *, int, int, int, attr_t, short, %0); @mvchgat ^
int mvwdelch (WINDOW *, int, int); @mvdelch ^
int mvwgetch (WINDOW *, int, int); @mvgetch ^
char* luacurses_mvwgetnstr (WINDOW *, int, int, int); @mvgetnstr ^ @mvwgetnstr
#char* luacurses_mvwgetstr (WINDOW *, int, int); @mvgetstr ^ @mvwgetstr
int mvwhline (WINDOW *, int, int, chtype, int); @mvhline ^
int mvwin (WINDOW *,int,int); @mvin ^
chtype mvwinch (WINDOW *, int, int); @mvinch ^
#int mvwinchnstr (WINDOW *, int, int, chtype *, int); @mvinchnstr ^
#int mvwinchstr (WINDOW *, int, int, chtype *); @mvinchstr ^
int mvwinnstr (WINDOW *, int, int, char *, int); @mvinnstr ^
int mvwinsch (WINDOW *, int, int, chtype); @mvinsch ^
int mvwinsnstr (WINDOW *, int, int, const char *, int); @mvinsnstr ^
int mvwinsstr (WINDOW *, int, int, const char *); @mvinsstr ^
int mvwinstr (WINDOW *, int, int, char *); @mvinstr ^
int mvwvline (WINDOW *,int, int, chtype, int); @mvvline ^
int nodelay (WINDOW *,bool); ^
int notimeout (WINDOW *,bool); ^
int pechochar (WINDOW *, const chtype); ^
int pnoutrefresh (WINDOW*,int,int,int,int,int,int); ^
int prefresh (WINDOW *,int,int,int,int,int,int); ^
int putwin (WINDOW *, FILE *); ^
int redrawwin (WINDOW *); ^
int scroll (WINDOW *); ^
int scrollok (WINDOW *,bool); ^

int touchline (WINDOW *, int, int); ^
int touchwin (WINDOW *); ^
int untouchwin (WINDOW *); ^
int waddch (WINDOW *, const chtype); @addch ^
#int waddchnstr (WINDOW *,const chtype *,int); @addchnstr ^
#int waddchstr (WINDOW *,const chtype *); @addchstr ^
int waddnstr (WINDOW *,const char *,int); @addnstr ^
int waddstr (WINDOW *,const char *); @addstr ^
int wattron (WINDOW *, int); @attron ^
int wattroff (WINDOW *, int); @attroff ^
int wattrset (WINDOW *, int); @attrset ^
int wattr_get (WINDOW *, attr_t&!^ , short&!^ , %0); @attr_get ^
int wattr_on (WINDOW *, attr_t, %0); @attr_on ^
int wattr_off (WINDOW *, attr_t, %0); @attr_off ^
int wattr_set (WINDOW *, attr_t, short, %0); @attr_set ^
int wbkgd (WINDOW *, chtype); @bkgd ^
void wbkgdset (WINDOW *,chtype); @bkgdset ^
int wborder (WINDOW *,chtype,chtype,chtype,chtype,chtype,chtype,chtype,chtype); @border ^
int wchgat (WINDOW *, int, attr_t, short, %0); @chgat ^
int wclear (WINDOW *); @clear ^
int wclrtobot (WINDOW *); @clrtobot ^
int wclrtoeol (WINDOW *); @clrtoeol ^
int wcolor_set (WINDOW*,short,%0); @color_set ^
void wcursyncup (WINDOW *); @cursyncup ^
int wdelch (WINDOW *); @delch ^
int wdeleteln (WINDOW *); @deleteln ^
int wechochar (WINDOW *, const chtype); @echochar ^
int werase (WINDOW *); @erase ^
int wgetch (WINDOW *); @getch ^
char* luacurses_wgetnstr (WINDOW *,int); @getnstr ^ @wgetnstr
#char* luacurses_wgetstr (WINDOW *); @getstr ^ @wgetstr
int whline (WINDOW *, chtype, int); @hline ^
chtype winch (WINDOW *); @inch ^
#int winchnstr (WINDOW *, chtype *, int); @inchnstr ^
#int winchstr (WINDOW *, chtype *); @inchstr ^
int winnstr (WINDOW *, char *, int); @innstr ^
int winsch (WINDOW *, chtype); @insch ^
int winsdelln (WINDOW *,int); @insdelln ^
int winsertln (WINDOW *); @insertln ^
int winsnstr (WINDOW *, const char *,int); @insnstr ^
int winsstr (WINDOW *, const char *); @insstr ^
int winstr (WINDOW *, char *); @instr ^
int wmove (WINDOW *,int,int); @move ^
int wnoutrefresh (WINDOW *); @noutrefresh ^
int wredrawln (WINDOW *,int,int); @redrawln ^
int wrefresh (WINDOW *); @refresh ^
int wscrl (WINDOW *,int); @scrl ^
int wsetscrreg (WINDOW *,int,int); @setscrreg ^
int wstandout (WINDOW *); @standout ^
int wstandend (WINDOW *); @standend ^
void wsyncdown (WINDOW *); @syncdown ^
void wsyncup (WINDOW *); @syncup ^
void wtimeout (WINDOW *,int); @timeout ^
int wtouchln (WINDOW *,int,int,int); @touchln ^
int wvline (WINDOW *,chtype,int); @vline ^
bool wenclose (const WINDOW *, int, int); @enclose ^
bool wmouse_trafo (const WINDOW* win,int&^ y, int&^ x, bool to_screen); @mouse_trafo ^

!endmeta WINDOW*;

WINDOW * stdscr();%
WINDOW * curscr();%
WINDOW * newscr();%

int LINES();%
int COLS();%
int TABSIZE();%

int ESCDELAY();%

bool is_term_resized (int, int);
char * keybound (int, int);$
const char * curses_version (void);
int assume_default_colors (int, int);
int define_key (const char *, int);
int key_defined (const char *);
int keyok (int, bool);
int resize_term (int, int);
int resizeterm (int, int);
int use_default_colors (void);
int use_extended_names (bool);
int wresize (WINDOW *, int, int);


int addch (const chtype);
#int addchnstr (const chtype *, int);
#int addchstr (const chtype *);
int addnstr (const char *, int);
int addstr (const char *);
int attroff (attr_t);
int attron (attr_t);
int attrset (attr_t);
int attr_get (attr_t&!^ , short&!^ , %0);
int attr_off (attr_t, %0);
int attr_on (attr_t, %0);
int attr_set (attr_t, short, %0);
int baudrate (void);
int beep  (void);
int bkgd (chtype);
void bkgdset (chtype);
int border (chtype,chtype,chtype,chtype,chtype,chtype,chtype,chtype);
bool can_change_color (void);
int cbreak (void);
int chgat (int, attr_t, short, %0);
int clear (void);
int clrtobot (void);
int clrtoeol (void);
int color_content (short,short&!^,short&!^,short&!^);
int color_set (short,%0);
int COLOR_PAIR (int);
int copywin (const WINDOW*,WINDOW*,int,int,int,int,int,int,int);
int curs_set (int);
int def_prog_mode (void);
int def_shell_mode (void);
int delay_output (int);
int delch (void);
int deleteln (void);
int doupdate (void);
int echo (void);
int echochar (const chtype);
int erase (void);
int endwin (void);
char erasechar (void);
void filter (void);
int flash (void);
int flushinp (void);
int getch (void);
char* luacurses_getnstr (int); @getnstr
# char* luacurses_getstr (); @getstr
WINDOW * getwin (FILE *);
int halfdelay (int);
bool has_colors (void);
bool has_ic (void);
bool has_il (void);
int hline (chtype, int);
chtype inch (void);
#int inchnstr (chtype *, int);
#int inchstr (chtype *);
WINDOW * initscr (void);
int init_color (short,short,short,short);
int init_pair (short,short,short);
int innstr (char *, int);
int insch (chtype);
int insdelln (int);
int insertln (void);
int insnstr (const char *, int);
int insstr (const char *);
int instr (char *);
bool isendwin (void);
const char * keyname (int);
char killchar (void);
char * longname (void);
int move (int, int);
int mvaddch (int, int, const chtype);
#int mvaddchnstr (int, int, const chtype *, int);
#int mvaddchstr (int, int, const chtype *);
int mvaddnstr (int, int, const char *, int);
int mvaddstr (int, int, const char *);
int mvchgat (int, int, int, attr_t, short, %0);
int mvcur (int,int,int,int);
int mvdelch (int, int);
int mvgetch (int, int);
char* luacurses_mvgetnstr (int, int, int); @mvgetnstr
# char* luacurses_mvgetstr (int, int); @mvgetstr
int mvhline (int, int, chtype, int);
chtype mvinch (int, int);
#int mvinchnstr (int, int, chtype *, int);
#int mvinchstr (int, int, chtype *);
int mvinnstr (int, int, char *, int);
int mvinsch (int, int, chtype);
int mvinsnstr (int, int, const char *, int);
int mvinsstr (int, int, const char *);
int mvinstr (int, int, char *);
int mvvline (int, int, chtype, int);
int napms (int);
WINDOW * newpad (int,int);
SCREEN * newterm (const char *,FILE *,FILE *);
WINDOW * newwin (int,int,int,int);
int nl (void);
int nocbreak (void);
int noecho (void);
int nonl (void);
void noqiflush (void);
int noraw (void);
int overlay (const WINDOW*,WINDOW *);
int overwrite (const WINDOW*,WINDOW *);
int pair_content (short,short&!^,short&!^);
int PAIR_NUMBER (int);
int putp (const char *);
void qiflush (void);
int raw (void);
int refresh (void);
int resetty (void);
int reset_prog_mode (void);
int reset_shell_mode (void);
int savetty (void);
int scr_dump (const char *);
int scr_init (const char *);
int scrl (int);
int scr_restore (const char *);
int scr_set (const char *);
int setscrreg (int,int);

# no slk* and ti* functions
!comment;
int slk_attroff (const chtype);
int slk_attr_off (const attr_t, %0);
int slk_attron (const chtype);
int slk_attr_on (attr_t,%0);
int slk_attrset (const chtype);
attr_t slk_attr (void);
int slk_attr_set (const attr_t,short,%0);
int slk_clear (void);
int slk_color (short);
int slk_init (int);
char * slk_label (int);
int slk_noutrefresh (void);
int slk_refresh (void);
int slk_restore (void);
int slk_set (int,const char *,int);
int slk_touch (void);
chtype termattrs (void);
char * termname (void);
int tigetflag (const char *);
int tigetnum (const char *);
char * tigetstr (const char *);

!endcomment;

int standout (void);
int standend (void);
int start_color (void);
WINDOW * subpad (WINDOW *, int, int, int, int);
WINDOW * subwin (WINDOW *,int,int,int,int);
int syncok (WINDOW *, bool);

void timeout (int);
int typeahead (int);
int ungetch (int);
void use_env (bool);
int vidattr (chtype);
int vline (chtype, int);


int A_NORMAL;
int A_ATTRIBUTES;
int A_CHARTEXT;
int A_COLOR;
int A_STANDOUT;
int A_UNDERLINE;
int A_REVERSE;
int A_BLINK;
int A_DIM;
int A_BOLD;
int A_ALTCHARSET;
int A_INVIS;
int A_PROTECT;
int A_HORIZONTAL;
int A_LEFT;
int A_LOW;
int A_RIGHT;
int A_TOP;
int A_VERTICAL;

void getyx(WINDOW*,int&! y, int&! x);
void getbegyx(WINDOW*,int&! y, int&! x);
void getmaxyx(WINDOW*,int&! y, int&! x);
void getparyx(WINDOW*,int&! y, int&! x);

int KEY_CODE_YES;
int KEY_MIN;
int KEY_BREAK;
int KEY_SRESET;
int KEY_RESET;

#/*
# * These definitions were generated by ../../include/MKkey_defs.sh ../../include/Caps
# */
int KEY_DOWN;
int KEY_UP;
int KEY_LEFT;
int KEY_RIGHT;
int KEY_HOME;
int KEY_BACKSPACE;
int KEY_F0;
int KEY_F(int n);
int KEY_DL;
int KEY_IL;
int KEY_DC;
int KEY_IC;
int KEY_EIC;
int KEY_CLEAR;
int KEY_EOS;
int KEY_EOL;
int KEY_SF;
int KEY_SR;
int KEY_NPAGE;
int KEY_PPAGE;
int KEY_STAB;
int KEY_CTAB;
int KEY_CATAB;
int KEY_ENTER;
int KEY_PRINT;
int KEY_LL;
int KEY_A1;
int KEY_A3;
int KEY_B2;
int KEY_C1;
int KEY_C3;
int KEY_BTAB;
int KEY_BEG;
int KEY_CANCEL;
int KEY_CLOSE;
int KEY_COMMAND;
int KEY_COPY;
int KEY_CREATE;
int KEY_END;
int KEY_EXIT;
int KEY_FIND;
int KEY_HELP;
int KEY_MARK;
int KEY_MESSAGE;
int KEY_MOVE;
int KEY_NEXT;
int KEY_OPEN;
int KEY_OPTIONS;
int KEY_PREVIOUS;
int KEY_REDO;
int KEY_REFERENCE;
int KEY_REFRESH;
int KEY_REPLACE;
int KEY_RESTART;
int KEY_RESUME;
int KEY_SAVE;
int KEY_SBEG;
int KEY_SCANCEL;
int KEY_SCOMMAND;
int KEY_SCOPY;
int KEY_SCREATE;
int KEY_SDC;
int KEY_SDL;
int KEY_SELECT;
int KEY_SEND;
int KEY_SEOL;
int KEY_SEXIT;
int KEY_SFIND;
int KEY_SHELP;
int KEY_SHOME;
int KEY_SIC;
int KEY_SLEFT;
int KEY_SMESSAGE;
int KEY_SMOVE;
int KEY_SNEXT;
int KEY_SOPTIONS;
int KEY_SPREVIOUS;
int KEY_SPRINT;
int KEY_SREDO;
int KEY_SREPLACE;
int KEY_SRIGHT;
int KEY_SRSUME;
int KEY_SSAVE;
int KEY_SSUSPEND;
int KEY_SUNDO;
int KEY_SUSPEND;
int KEY_UNDO;
int KEY_MOUSE;
int KEY_RESIZE;
int KEY_EVENT;

int KEY_MAX;

#/* event masks */

int BUTTON1_RELEASED;
int BUTTON1_PRESSED;
int BUTTON1_CLICKED;
int BUTTON1_DOUBLE_CLICKED;
int BUTTON1_TRIPLE_CLICKED;
int BUTTON1_RESERVED_EVENT;
int BUTTON2_RELEASED;
int BUTTON2_PRESSED;
int BUTTON2_CLICKED;
int BUTTON2_DOUBLE_CLICKED;
int BUTTON2_TRIPLE_CLICKED;
int BUTTON2_RESERVED_EVENT;
int BUTTON3_RELEASED;
int BUTTON3_PRESSED;
int BUTTON3_CLICKED;
int BUTTON3_DOUBLE_CLICKED;
int BUTTON3_TRIPLE_CLICKED;
int BUTTON3_RESERVED_EVENT;
int BUTTON4_RELEASED;
int BUTTON4_PRESSED;
int BUTTON4_CLICKED;
int BUTTON4_DOUBLE_CLICKED;
int BUTTON4_TRIPLE_CLICKED;
int BUTTON4_RESERVED_EVENT;
int BUTTON_CTRL;
int BUTTON_SHIFT;
int BUTTON_ALT;
int ALL_MOUSE_EVENTS;
int REPORT_MOUSE_POSITION;

#/* macros to extract single event-bits from masks */

bool BUTTON_RELEASE(int, int);
bool BUTTON_PRESS(int, int);
bool BUTTON_CLICK(int, int);
bool BUTTON_DOUBLE_CLICK(int, int);
bool BUTTON_TRIPLE_CLICK(int, int);
bool BUTTON_RESERVED_EVENT(int, int);

!typedef unsigned long mmask_t;

bool luacurses_getmouse (short&!^ id, int&!^ x, int&!^ y, int&!^ z, mmask_t&!^ bstate); @getmouse
bool luacurses_ungetmouse (short id, int x, int y, int z, mmask_t bstate); @ungetmouse
mmask_t mousemask (mmask_t, mmask_t&!^);
mmask_t luacurses_addmousemask(mmask_t); @addmousemask
int mouseinterval (int);
bool mouse_trafo (int&^, int&^, bool);

