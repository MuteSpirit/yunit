#include "lauxlib.h"
#include "lualib.h"


#define Naked __declspec(naked)


/*
** state manipulation
*/
lua_State *(lua_newstate_p) (lua_Alloc f, void *ud) {return lua_newstate(f, ud);}
void       (lua_close_p) (lua_State *L) {lua_close(L);}
lua_State *(lua_newthread_p) (lua_State *L) {return lua_newthread(L);}

lua_CFunction (lua_atpanic_p) (lua_State *L, lua_CFunction panicf) {return lua_atpanic(L, panicf);}


/*
** basic stack manipulation
*/
int   (lua_gettop_p) (lua_State *L) {return lua_gettop(L);}
void  (lua_settop_p) (lua_State *L, int idx) {lua_settop(L, idx);}
void  (lua_pushvalue_p) (lua_State *L, int idx) {lua_pushvalue(L, idx);}
void  (lua_remove_p) (lua_State *L, int idx) {lua_remove(L, idx);}
void  (lua_insert_p) (lua_State *L, int idx) {lua_insert(L, idx);}
void  (lua_replace_p) (lua_State *L, int idx) {lua_replace(L, idx);}
int   (lua_checkstack_p) (lua_State *L, int sz) {return lua_checkstack(L, sz);}

void  (lua_xmove_p) (lua_State *from, lua_State *to, int n) {lua_xmove(from, to, n);}


/*
** access functions (stack -> C)
*/

int             (lua_isnumber_p) (lua_State *L, int idx) {return lua_isnumber(L, idx);}
int             (lua_isstring_p) (lua_State *L, int idx) {return lua_isstring(L, idx);}
int             (lua_iscfunction_p) (lua_State *L, int idx) {return lua_iscfunction(L, idx);}
int             (lua_isuserdata_p) (lua_State *L, int idx) {return lua_isuserdata(L, idx);}
int             (lua_type_p) (lua_State *L, int idx) {return lua_type(L, idx);}
const char     *(lua_typename_p) (lua_State *L, int tp) {return lua_typename(L, tp);}

int            (lua_equal_p) (lua_State *L, int idx1, int idx2) {return lua_equal(L, idx1, idx2);}
int            (lua_rawequal_p) (lua_State *L, int idx1, int idx2) {return lua_rawequal(L, idx1, idx2);}
int            (lua_lessthan_p) (lua_State *L, int idx1, int idx2) {return lua_lessthan(L, idx1, idx2);}

lua_Number      (lua_tonumber_p) (lua_State *L, int idx) {return lua_tonumber(L, idx);}
lua_Integer     (lua_tointeger_p) (lua_State *L, int idx) {return lua_tointeger(L, idx);}
int             (lua_toboolean_p) (lua_State *L, int idx) {return lua_toboolean(L, idx);}
const char     *(lua_tolstring_p) (lua_State *L, int idx, size_t *len) {return lua_tolstring(L, idx, len);}
size_t          (lua_objlen_p) (lua_State *L, int idx) {return lua_objlen(L, idx);}
lua_CFunction   (lua_tocfunction_p) (lua_State *L, int idx) {return lua_tocfunction(L, idx);}
void	       *(lua_touserdata_p) (lua_State *L, int idx) {return lua_touserdata(L, idx);}
lua_State      *(lua_tothread_p) (lua_State *L, int idx) {return lua_tothread(L, idx);}
const void     *(lua_topointer_p) (lua_State *L, int idx) {return lua_topointer(L, idx);}


/*
** push functions (C -> stack)
*/
void  (lua_pushnil_p) (lua_State *L) {lua_pushnil(L);}
/*Naked void  (lua_pushnumber_p) (lua_State *L, lua_Number n) {lua_pushnumber(L, n);}*/
/*Naked void  (lua_pushinteger_p) (lua_State *L, lua_Integer n) {lua_pushinteger(L, n);}*/

Naked void  (lua_pushnumber_p) (lua_State *L, lua_Number n) {__asm jmp DWORD PTR lua_pushnumber}
Naked void  (lua_pushinteger_p) (lua_State *L, lua_Integer n) {__asm jmp DWORD PTR lua_pushinteger}

void  (lua_pushlstring_p) (lua_State *L, const char *s, size_t l) {lua_pushlstring(L, s, l);}
void  (lua_pushstring_p) (lua_State *L, const char *s) {lua_pushstring(L, s);}
const char *(lua_pushvfstring_p) (lua_State *L, const char *fmt, va_list argp) {return lua_pushvfstring(L, fmt, argp);}
const char *(lua_pushfstring_p) (lua_State *L, const char *fmt, ...) {return lua_pushfstring(L, fmt);}
void  (lua_pushcclosure_p) (lua_State *L, lua_CFunction fn, int n) {lua_pushcclosure(L, fn, n);}
void  (lua_pushboolean_p) (lua_State *L, int b) {lua_pushboolean(L, b);}
void  (lua_pushlightuserdata_p) (lua_State *L, void *p) {lua_pushlightuserdata(L, p);}
int   (lua_pushthread_p) (lua_State *L) {return lua_pushthread(L);}


/*
** get functions (Lua -> stack)
*/
void  (lua_gettable_p) (lua_State *L, int idx) {lua_gettable(L, idx);}
void  (lua_getfield_p) (lua_State *L, int idx, const char *k) {lua_getfield(L, idx, k);}
void  (lua_rawget_p) (lua_State *L, int idx) {lua_rawget(L, idx);}
void  (lua_rawgeti_p) (lua_State *L, int idx, int n) {lua_rawgeti(L, idx, n);}
void  (lua_createtable_p) (lua_State *L, int narr, int nrec) {lua_createtable(L, narr, nrec);}
void *(lua_newuserdata_p) (lua_State *L, size_t sz) {return lua_newuserdata(L, sz);}
int   (lua_getmetatable_p) (lua_State *L, int objindex) {return lua_getmetatable(L, objindex);}
void  (lua_getfenv_p) (lua_State *L, int idx) {lua_getfenv(L, idx);}


/*
** set functions (stack -> Lua)
*/
void  (lua_settable_p) (lua_State *L, int idx) {lua_settable(L, idx);}
void  (lua_setfield_p) (lua_State *L, int idx, const char *k) {lua_setfield(L, idx, k);}
void  (lua_rawset_p) (lua_State *L, int idx) {lua_rawset(L, idx);}
void  (lua_rawseti_p) (lua_State *L, int idx, int n) {lua_rawseti(L, idx, n);}
int   (lua_setmetatable_p) (lua_State *L, int objindex) {return lua_setmetatable(L, objindex);}
int   (lua_setfenv_p) (lua_State *L, int idx) {return lua_setfenv(L, idx);}


/*
** `load' and `call' functions (load and run Lua code)
*/
void  (lua_call_p) (lua_State *L, int nargs, int nresults) {lua_call(L, nargs, nresults);}
int   (lua_pcall_p) (lua_State *L, int nargs, int nresults, int errfunc) {return lua_pcall(L, nargs, nresults, errfunc);}
int   (lua_cpcall_p) (lua_State *L, lua_CFunction func, void *ud) {return lua_cpcall(L, func, ud);}
int   (lua_load_p) (lua_State *L, lua_Reader reader, void *dt, const char *chunkname) {return lua_load(L, reader, dt, chunkname);}

int (lua_dump_p) (lua_State *L, lua_Writer writer, void *data) {return lua_dump(L, writer, data);}


/*
** coroutine functions
*/
int  (lua_yield_p) (lua_State *L, int nresults) {return lua_yield(L, nresults);}
int  (lua_resume_p) (lua_State *L, int narg) {return lua_resume(L, narg);}
int  (lua_status_p) (lua_State *L) {return lua_status(L);}

/*
** garbage-collection function and options
*/

int (lua_gc_p) (lua_State *L, int what, int data) {return lua_gc(L, what, data);}


/*
** miscellaneous functions
*/

int   (lua_error_p) (lua_State *L) {return lua_error(L);}

int   (lua_next_p) (lua_State *L, int idx) {return lua_next(L, idx);}

void  (lua_concat_p) (lua_State *L, int n) {lua_concat(L, n);}

lua_Alloc (lua_getallocf_p) (lua_State *L, void **ud) {return lua_getallocf(L, ud);}
void lua_setallocf_p (lua_State *L, lua_Alloc f, void *ud) {lua_setallocf(L, f, ud);}


void (luaL_openlib_p) (lua_State *L, const char *libname, const luaL_Reg *l, int nup) {luaL_openlib(L, libname, l, nup);}
void (luaL_register_p) (lua_State *L, const char *libname, const luaL_Reg *l) {luaL_register(L, libname, l);}
int (luaL_getmetafield_p) (lua_State *L, int obj, const char *e) {return luaL_getmetafield(L, obj, e);}
int (luaL_callmeta_p) (lua_State *L, int obj, const char *e) {return luaL_callmeta(L, obj, e);}
int (luaL_typerror_p) (lua_State *L, int narg, const char *tname) {return luaL_typerror(L, narg, tname);}
int (luaL_argerror_p) (lua_State *L, int numarg, const char *extramsg) {return luaL_argerror(L, numarg, extramsg);}
const char *(luaL_checklstring_p) (lua_State *L, int numArg, size_t *l) {return luaL_checklstring(L, numArg, l);}
const char *(luaL_optlstring_p) (lua_State *L, int numArg, const char *def, size_t *l) {return luaL_optlstring(L, numArg, def, l);}
lua_Number (luaL_checknumber_p) (lua_State *L, int numArg) {return luaL_checknumber(L, numArg);}

/*lua_Number (luaL_optnumber_p) (lua_State *L, int nArg, lua_Number def) {return luaL_optnumber(L, nArg, def);}*/
Naked lua_Number (luaL_optnumber_p) (lua_State *L, int nArg, lua_Number def) {__asm jmp DWORD PTR luaL_optnumber}

lua_Integer (luaL_checkinteger_p) (lua_State *L, int numArg) {return luaL_checkinteger(L, numArg);}
lua_Integer (luaL_optinteger_p) (lua_State *L, int nArg, lua_Integer def) {return luaL_optinteger(L, nArg, def);}

void (luaL_checkstack_p) (lua_State *L, int sz, const char *msg) {luaL_checkstack(L, sz, msg);}
void (luaL_checktype_p) (lua_State *L, int narg, int t) {luaL_checktype(L, narg, t);}
void (luaL_checkany_p) (lua_State *L, int narg) {luaL_checkany(L, narg);}

int   (luaL_newmetatable_p) (lua_State *L, const char *tname) {return luaL_newmetatable(L, tname);}
void *(luaL_checkudata_p) (lua_State *L, int ud, const char *tname) {return luaL_checkudata(L, ud, tname);}

void (luaL_where_p) (lua_State *L, int lvl) {luaL_where(L, lvl);}
int (luaL_error_p) (lua_State *L, const char *fmt, ...) {return luaL_error(L, fmt);}

int (luaL_checkoption_p) (lua_State *L, int narg, const char *def, const char *const lst[]) {return luaL_checkoption(L, narg, def, lst);}

int (luaL_ref_p) (lua_State *L, int t) {return luaL_ref(L, t);}
void (luaL_unref_p) (lua_State *L, int t, int ref) {luaL_unref(L, t, ref);}

int (luaL_loadfile_p) (lua_State *L, const char *filename) {return luaL_loadfile(L, filename);}
int (luaL_loadbuffer_p) (lua_State *L, const char *buff, size_t sz, const char *name) {return luaL_loadbuffer(L, buff, sz, name);}
int (luaL_loadstring_p) (lua_State *L, const char *s) {return luaL_loadstring(L, s);}

lua_State *(luaL_newstate_p) (void) {return luaL_newstate();}


const char *(luaL_gsub_p) (lua_State *L, const char *s, const char *p, const char *r) {return luaL_gsub(L, s, p, r);}

const char *(luaL_findtable_p) (lua_State *L, int idx, const char *fname, int szhint) {return luaL_findtable(L, idx, fname, szhint);}


void (luaL_buffinit_p) (lua_State *L, luaL_Buffer *B) {luaL_buffinit(L, B);}
char *(luaL_prepbuffer_p) (luaL_Buffer *B) {return luaL_prepbuffer(B);}
void (luaL_addlstring_p) (luaL_Buffer *B, const char *s, size_t l) {luaL_addlstring(B, s, l);}
void (luaL_addstring_p) (luaL_Buffer *B, const char *s) {luaL_addstring(B, s);}
void (luaL_addvalue_p) (luaL_Buffer *B) {luaL_addvalue(B);}
void (luaL_pushresult_p) (luaL_Buffer *B) {luaL_pushresult(B);}


void luaL_openlibs_p (lua_State *L) {luaL_openlibs(L);}
int (luaopen_base_p) (lua_State *L) {return luaopen_base(L);}
int (luaopen_table_p) (lua_State *L) {return luaopen_table(L);}
int (luaopen_io_p) (lua_State *L) {return luaopen_io(L);}
int (luaopen_os_p) (lua_State *L) {return luaopen_os(L);}
int (luaopen_string_p) (lua_State *L) {return luaopen_string(L);}
int (luaopen_math_p) (lua_State *L) {return luaopen_math(L);}
int (luaopen_debug_p) (lua_State *L) {return luaopen_debug(L);}
int (luaopen_package_p) (lua_State *L) {return luaopen_package(L);}


int lua_getstack_p (lua_State *L, int level, lua_Debug *ar) {return lua_getstack(L, level, ar);}
int lua_getinfo_p (lua_State *L, const char *what, lua_Debug *ar) {return lua_getinfo(L, what, ar);}
const char *lua_getlocal_p (lua_State *L, const lua_Debug *ar, int n) {return lua_getlocal(L, ar, n);}
const char *lua_setlocal_p (lua_State *L, const lua_Debug *ar, int n) {return lua_setlocal(L, ar, n);}
const char *lua_getupvalue_p (lua_State *L, int funcindex, int n) {return lua_getupvalue(L, funcindex, n);}
const char *lua_setupvalue_p (lua_State *L, int funcindex, int n) {return lua_setupvalue(L, funcindex, n);}

int lua_sethook_p (lua_State *L, lua_Hook func, int mask, int count) {return lua_sethook(L, func, mask, count);}
lua_Hook lua_gethook_p (lua_State *L) {return lua_gethook(L);}
int lua_gethookmask_p (lua_State *L) {return lua_gethookmask(L);}
int lua_gethookcount_p (lua_State *L) {return lua_gethookcount(L);}

void lua_setlevel_p	(lua_State *from, lua_State *to) {lua_setlevel(from, to);}
