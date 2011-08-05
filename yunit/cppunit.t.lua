local luaUnit = require('yunit.luaunit');

function cppunit_test_unit_interface()
    local cppUnit = require('cppunit')
    isNotNil(cppUnit)
    
    isFunction(cppUnit.getTestContainerExtensions)
    isFunction(cppUnit.getTestList)
    isFunction(cppUnit.loadTestContainer)
    
    local exts = cppUnit.getTestContainerExtensions()
    areNotEq(0, #exts);
    
    local tests = cppUnit.getTestList()
    areEq(0, #tests)
end
