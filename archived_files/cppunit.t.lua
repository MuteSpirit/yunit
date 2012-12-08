local luaUnit = require "yunit.luaunit"
local fs = require "yunit.filesystem"

local cppUnit = require "yunit.cppunit"

function cppunit_lua_interface()
    isNotNil(cppUnit)
    
    isFunction(cppUnit.getTestContainerExtensions)
    isFunction(cppUnit.loadTestContainer)
    
    local exts = cppUnit.getTestContainerExtensions()
    areNotEq(0, #exts)
end

function try_to_load_abscent_test_container()
    isNotNil(cppUnit)

    local path = '__cppunit.t.t.t.t.dll'
    isFalse(fs.isExist(path))
    
    local resOrTests, msg = cppUnit.loadTestContainer(path)
    isBoolean(resOrTests)
    isFalse(resOrTests)
    areNotEq('', msg)
end

