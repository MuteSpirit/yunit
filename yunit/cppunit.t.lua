local luaUnit = require('yunit.luaunit');
local fs = require('yunit.filesystem');

local cppUnit = require('cppunit')

function cppunit_test_unit_interface()
    isNotNil(cppUnit)
    
    isFunction(cppUnit.getTestContainerExtensions)
    isFunction(cppUnit.getTestList)
    isFunction(cppUnit.loadTestContainer)
    
    local exts = cppUnit.getTestContainerExtensions()
    areNotEq(0, #exts)
    
    local tests = cppUnit.getTestList()
    areEq(0, #tests)
end

function try_to_load_abscent_test_container()
    isNotNil(cppUnit)

    local path = '__cppunit.t.t.t.t.dll'
    isFalse(fs.isExist(path))
    local rc, msg = cppUnit.loadTestContainer(path)
    isFalse(rc)
    isNotNil(msg)
    areNotEq(0, string.len(msg))
end
