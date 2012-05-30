//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#if _MSC_VER > 1000
#  pragma once
#endif

// when Lua execute code, like:
//      require 'yunit.lfs'
// it try to find exported function with name "luaopen_yunit_lfs" in file "yunit.dll"
// So, name of function is depend on shared library output name. And it is naturally to
// set OUTPUT_NAME in project comlilation properties instead of #define in source file, which
// does not known it's project.
// 
#define LUA_SUBMODULE(name) luaopen_yunit_lua_52_ ## name
