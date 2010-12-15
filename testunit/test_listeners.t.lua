--- \class TextTestProgressListener
--- \brief Derived from TestListener. Output messages to standat output.

local luaUnit = require("testunit.lua_unit");
local testListeners = require("testunit.test_listeners");

require("LuaXML");

local _G = _G;
local print = print;

local testModuleName = "TestListenerTest";

--------------------------------------------------------------------------------------------------------------
module(testModuleName, lunit.testcase)
--------------------------------------------------------------------------------------------------------------

local fakeTestCaseName;
local fakeTestName;
local fakeFailureMessage;
local fakeErrorObject;

------------------------------------------------------
function setUp()
    fakeTestCaseName = testModuleName;
    fakeTestName = "testObserverTest";
    fakeFailureMessage = "This is test message. It hasn't usefull information";
    fakeErrorObject = 
    {
        source = "test_runner.t.lua";
        func = "testTextTestProgressListenerCallAllFunctions";
        line = 113;
        message = fakeFailureMessage;
    };
end

------------------------------------------------------
function tearDown()
    fakeTestCaseName = nil;
    fakeTestName = nil;
    fakeFailureMessage = nil;
    fakeErrorObject = nil;
end

------------------------------------------------------
function testTextTestProgressListenerCreation()
    assert_not_nil(testListeners.TextTestProgressListener:new());
end

------------------------------------------------------
function testTextTestProgressListenerCallAllFunctions()
    local ttpl = testListeners.TextTestProgressListener:new();
    
    function ttpl:outputMessage(message)
    end

    ttpl:startTests();

    ttpl:startTest(fakeTestCaseName, fakeTestName);
    ttpl:addSuccessful(fakeTestCaseName, fakeTestName);
    ttpl:endTest(fakeTestCaseName, fakeTestName);

    ttpl:startTest(fakeTestCaseName, fakeTestName);
    ttpl:addFailure(fakeTestCaseName, fakeErrorObject);
    ttpl:endTest(fakeTestCaseName, fakeTestName);

    ttpl:startTest(fakeTestCaseName, fakeTestName);
    ttpl:addError(fakeTestCaseName, fakeErrorObject);
    ttpl:endTest(fakeTestCaseName, fakeTestName);

    ttpl:startTest(fakeTestCaseName, fakeTestName);
    ttpl:addIgnore(fakeTestCaseName);
    ttpl:endTest(fakeTestCaseName, fakeTestName);
    
    ttpl:endTests();
end

------------------------------------------------------
function testXmlListenerSimulateTestRunning()
    local ttpl = testListeners.XmlListenerAlaCppUnitXmlOutputter:new();
    
    function ttpl:outputMessage(message)
    end

    ttpl:startTests();

    assert_equal(0, #ttpl.reportContent.FailedTests);
    ttpl:startTest(fakeTestCaseName, fakeTestName);
    ttpl:addSuccessful(fakeTestCaseName, fakeTestName);
    ttpl:endTest(fakeTestCaseName, fakeTestName);
    assert_equal(0, #ttpl.reportContent.FailedTests);
    
    assert_equal(0, #ttpl.reportContent.FailedTests);
    ttpl:startTest(fakeTestCaseName, fakeTestName);
    ttpl:addFailure(fakeTestCaseName, fakeErrorObject);
    ttpl:endTest(fakeTestCaseName, fakeTestName);
    assert_equal(1, #ttpl.reportContent.FailedTests);

    ttpl:startTest(fakeTestCaseName, fakeTestName);
    ttpl:addError(fakeTestCaseName, fakeErrorObject);
    ttpl:endTest(fakeTestCaseName, fakeTestName);

   ttpl:startTest(fakeTestCaseName, fakeTestName);
    ttpl:addIgnore(fakeTestCaseName);
    ttpl:endTest(fakeTestCaseName, fakeTestName);
 
    assert_equal(1, #ttpl.reportContent.SuccessfulTests);
    assert_equal(1, #ttpl.reportContent.ErrorTests);
    assert_equal(1, #ttpl.reportContent.IgnoredTests);
    
    ttpl:endTests();
    
end

-- function testLuaXml()
--     local resInfo = 
--     {
--         Location = 
--         {
--             a = '123', --
--             File = {'main.cpp'},
--         },
--         Test = 
--         {
--             id = 1,
--             Name = {'Test1'},
--         },
--         Test = 
--         {
--             id = 2,
--             Name = {'Test2'},
--         },
--     };
--     print(_G.xml.str(resInfo, 0, ''));
-- end