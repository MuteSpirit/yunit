local luaUnit = require('testunit.luaunit');
    function cppunitTest()
        -- load cppunit.dll
        package.cpath = "../_bin/?.dll;"..package.cpath;
        local cppUnit = require("cppunit");
        isNotNil(cppUnit);
        isNotNil(cppunit);
        areEq("table", type(package.loaded["cppunit"]));
        isNotNil(cppunit.getTestList);
        areEq("function", type(cppunit.getTestList));
        
        package.loadlib("../_bin/cppunit.t.dll", "");
        
        local testList, testCase;
        
        testList = cppUnit.getTestList();
        areNotEq(0, #testList);
        
        -- check validation of C++ TestCase interface
        testCase = testList[1];

        isNotNil(testCase.name_);
        areEq("string", type(testCase.name_));
        isNotNil(testCase.isIgnored_);
        areEq("boolean", type(testCase.isIgnored_));
        isNotNil(testCase.setUp);
        areEq("function", type(testCase.setUp));
        isNotNil(testCase.test);
        areEq("function", type(testCase.test));
        isNotNil(testCase.tearDown);
        areEq("function", type(testCase.tearDown));
    end
