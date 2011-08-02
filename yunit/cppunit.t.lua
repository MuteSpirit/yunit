local luaUnit = require('yunit.luaunit');

function cppunit_test_unit_interface()
    local cppUnitT = require('cppunit')
    isNotNil(cppUnitT)
    
    isFunction(cppUnitT.getTestContainerExtensions)
    isFunction(cppUnitT.getTestList)
    isFunction(cppUnitT.loadTestContainer)
    
    local exts = cppUnitT.getTestContainerExtensions()
    areNotEq(0, #exts);
end
