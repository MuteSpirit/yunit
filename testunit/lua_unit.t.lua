--- \fn copyTable(object, clone)
--- \brief Make full copy of table
--- \param[in] object Sample for cloning
--- \return Cloned object of original object

--- \class TestFuxture
--- \brief Class, whtich has setUp and tearDown function. It is base for TestCase class.

--- \class TestCase
--- \brief Single Test. TestCase object contain test code and namely it is executed.

--- \class TestSuite
--- \brief Class, whitch has name and contains TestCase objects. One level at tree of tests.

--- \class TestRegistry
--- \brief Contain all TestSuites from loaded Lua test scripts (*.t.lua) and C++ test drivers (*.t.dll)

--- \fn TestRegistry:addTestCase(testcase)
--- \brief Add TestCase object into default TestSuite

--- \fn TestRegistry:reset()
--- \brief return TestRegistry to the default state

--- \fn getTestList()
--- \brief Return collection of objects with TestCase interface ("name_", setUp, test, tearDown). Names of TestCases contains TestSuite and TestCase name, separated by '::'
--- \return List of TestCases-like objects 

--- \fn ASSERT_EQUAL(expected, actual)
--- \brief Compare two values of the same type and check their equation.
--- \param[in] expected Expected value
--- \param[in] actual Actual value
--- \return None. Throw exception in case of error.

--- \fn ASSERT_MULTIPLE_EQUAL(...)
--- \brief Compare first half of argument (expected values) with second half of arguments (actual values). If function receive odd number of 
--- arguments, then it will throw error exception.
--- \param[in] ... Value for comparison
--- \return None. Throw exception in case of error.

--- \fn ASSERT_STRING_EQUAL(expected, actual)
--- \brief Compare two multiline strings (usualy long string and very long strings) and in case of unequation it show only
--- differential lines of 'expected' and 'actual'
--- \param[in] expected Expected string
--- \param[in] actual Actual string
--- \return None. Throw exception in case of error.

--- \fn TEST_FIXTURE(name)
--- \brief Only insert fixture object into global table _G
--- \param[in] name Name of TestFixture object
--- \return 

--- \fn TEST_SUITE(name)
--- \brief Create new TestSuite object, add it to 'TestRegistry', set 'curSuite' vaiable
--- \param[in] name Name of TestSuite

--- \fn TEST_CASE(args)
--- \brief Create new TestCase object, add it to it's TestSuite
--- \param[in] args Table {name, function}, containing name and test function of TestCase

--- \fn TEST_CASE_EX(args)
--- \brief Create new TestCase object, whitch are derived from some TestFixture classes. 
--- Multiple inheritance is allowed
--- \param[in] args Table {name, TestFixtureName[, ...], function}, containing name of TestCase, names
--- of base TestFixture classes and test function of TestCase

--- \fn testmodule(moduleTable)
--- \brief This function become available such function as ASSERT_ directly from test module.
--- Pass this function as argument (after module name) of function 'module', for example: \n 
--- module("lua_test_sample", luaUnit.testmodule, package.seeall);\n

--- \fn callTestCaseMethod(testcase, testFunc)
--- \brief Call method of TestCase object and get advanced info in case of mistaken execution
--- \param[in] testcase TestCase object
--- \param[in] testFunc 'test', 'setUp' or 'tearDown' function of 'testcase'
--- \return status code of 'testFunc' execution and ErrorObject with additional info

local luaUnit = require("afl.lua_unit");

--------------------------------------------------------------------------------------------------------------
-- Sample of test writing sintax
--------------------------------------------------------------------------------------------------------------
-- module("luaUnitTests", luaUnit.testmodule, package.seeall)
--------------------------------------------------------------------------------------------------------------
-- 
-- TEST_FIXTURE("MessageQueues")
-- {
--     setUp = function(self)
--         self.q1_.initialize();
--     end
--     ;
--     tearDown = function(self)
--         self.q1_.release();
--     end
--     ;
--     q1_ = 
--     {
--         initialize = function() end;
--         release = function() end;
--         add = 
--             function(self, value)
--                 table.insert(self.list, value);
--                 if self.list[#self.list] then
--                     return true;
--                 end
--             end;
--         list = {};
--     };
-- };
--
-- TEST_SUITE("Messaging")
-- {
--     TEST_CASE_EX{"testMessageEnqueue", "MessageQueues", function(self)
--         ASSERT(self.q1_.add(""));
--     end
--     };
--     TEST_CASE{"testSimple", function(self)
--         local q = 2;
--         ASSERT_EQUAL(4, q + 2);
--     end
--     };
-- };

-- TEST_SUITE("AppliedFunctionTestSuite")
-- {
--     TEST_CASE{"copyTableTest", function(self)
--         local object = 
--         {
--             a_ = 5;
--             get = function() return a_; end;
--             set = function(v) a_ = v; end;
--         };
--         local mt; mt = 
--         {
--             b_ = 10;
--             __index = mt;
--         };
--         setmetatable(object, mt);
--         local clone = {};
--         luaUnit.copyTable(object, clone);
--         ASSERT_EQUAL(object.a_, clone.a_);
--         ASSERT_EQUAL(object.get(), clone.get());
--         object.set(1); clone.set(1);
--         ASSERT_EQUAL(object.get(), clone.get());
--         ASSERT_EQUAL(getmetatable(object), getmetatable(clone));
--     end
--     };
-- };

--------------------------------------------------------------------------------------------------------------
module("AppliedFunctionTestSuite", lunit.testcase, package.seeall)
--------------------------------------------------------------------------------------------------------------

function copyTableTest()
    local object = 
    {
        a_ = 5;
        get = function() return a_; end;
        set = function(v) a_ = v; end;
    };
    local mt; mt = 
    {
        b_ = "arigato";
        __index = mt;
    };
    setmetatable(object, mt);
    local clone = luaUnit.copyTable(object);
    assert_equal(object.a_, clone.a_);
    assert_equal(object.get(), clone.get());
    object.set(1); clone.set(1);
    assert_equal(object.get(), clone.get());
    assert_equal(object.b_, clone.b_);
    assert_equal(getmetatable(object), getmetatable(clone));
end   

--------------------------------------------------------------------------------------------------------------
module("TestCaseTest", lunit.testcase, package.seeall)
--------------------------------------------------------------------------------------------------------------

function createTestCaseTest()
    local testcase = luaUnit.TestCase:new("OnlyCreatedTestCase");
    assert_not_nil(testcase);
    assert_not_nil(testcase.setUp);
    assert_equal("function", type(testcase.setUp));
    assert_not_nil(testcase.test);
    assert_equal("function", type(testcase.test));
    assert_not_nil(testcase.tearDown);
    assert_equal("function", type(testcase.tearDown));
end

function runSimpleTestCaseTest()
    local testcase = luaUnit.TestCase:new("runSimpleTestCase");
    testcase.test = function()
        luaUnit.ASSERT_EQUAL(0, 0);
    end
    assert_pass("runSimpleTestCase:setUp", testcase.setUp);
    assert_pass("runSimpleTestCase:test", testcase.test);
    assert_pass("runSimpleTestCase:tearDown", testcase.tearDown);
end

--------------------------------------------------------------------------------------------------------------
module("LuaUnitTestRegistryTest", lunit.testcase, package.seeall)
--------------------------------------------------------------------------------------------------------------

local testRunner = require("afl.test_runner");

function setUp()
    luaUnit.TestRegistry:reset();
end

function tearDown()
    luaUnit.TestRegistry:reset();
end

function addingTestCasesToTestRegistryTest()
    assert_equal(1, #luaUnit.TestRegistry.testsuites);
    assert_equal("Default", luaUnit.TestRegistry.testsuites[1].name_);
    assert_equal(0, #luaUnit.TestRegistry.testsuites[1].testcases);
    
    luaUnit.TestRegistry:addTestCase(luaUnit.TestCase:new("TestCaseForDefaultTestSuite"));
    assert_equal(1, #luaUnit.TestRegistry.testsuites);
    assert_equal(1, #luaUnit.TestRegistry.testsuites[1].testcases);
    
    local testsuite = luaUnit.TestSuite:new("NotDefaultTestSuite");
    luaUnit.TestRegistry:addTestSuite(testsuite);
    assert_equal(2, #luaUnit.TestRegistry.testsuites);
    assert_equal(1, #luaUnit.TestRegistry.testsuites[1].testcases);
    assert_equal(0, #luaUnit.TestRegistry.testsuites[2].testcases);

    luaUnit.TestRegistry:addTestCase(luaUnit.TestCase:new("OtherTestCaseForDefaultTestSuite"));
    assert_equal(2, #luaUnit.TestRegistry.testsuites);
    assert_equal(2, #luaUnit.TestRegistry.testsuites[1].testcases);
    assert_equal(0, #luaUnit.TestRegistry.testsuites[2].testcases);
    
    testsuite:addTestCase(luaUnit.TestCase:new("TestCase1"));
    assert_equal(2, #luaUnit.TestRegistry.testsuites);
    assert_equal(2, #luaUnit.TestRegistry.testsuites[1].testcases);
    assert_equal(1, #luaUnit.TestRegistry.testsuites[2].testcases);
    
    luaUnit.TestRegistry:reset();
    assert_equal(1, #luaUnit.TestRegistry.testsuites);
    assert_equal("Default", luaUnit.TestRegistry.testsuites[1].name_);
    assert_equal(0, #luaUnit.TestRegistry.testsuites[1].testcases);
end

function getTestListTest()
    local testList;
    -- check that no one test is present in TestRegistry
    testList = luaUnit.getTestList();
    assert_not_nil(testList);
    assert_equal(0, #testList);
    -- add one TestCase
    local testcaseName = "GetTestListTestCase";
    local testcase = luaUnit.TestCase:new(testcaseName);
    testcase.test = function()
        luaUnit.ASSERT_EQUAL(0, 0);
    end
    luaUnit.TestRegistry:addTestCase(testcase);

    testList = luaUnit.getTestList();
    assert_not_nil(testList);
    assert_equal(1, #testList);
    
    -- try run that TestCase
    assert_pass(testcaseName..":setUp", function() testList[1]:setUp() end);
    assert_pass(testcaseName..":test", function() testList[1]:test() end);
    assert_pass(testcaseName..":tearDown", function() testList[1]:tearDown() end);
end

function protectTestCaseMethodCallTest()
    -- we try to call create simple TestCAse and call 'setUp', 'test', 'tearDown' in protected mode
    -- in the result we must receive object with such data:
    -- - file name of script  with error
    -- - line number of failed ASSERT
    -- - text message from that ASSERT
    
    local testcase = luaUnit.TestCase:new("TestCaseForProtectCall");
    testcase.test = function()
        -- must except error
        luaUnit.ASSERT_NOT_EQUAL(0, 0);
    end
    
    local statusCode, errorObject = luaUnit.callTestCaseMethod(testcase, testcase.test);
    assert_false(statusCode);
    assert_equal("lua_unit.t.lua", errorObject.source);
    assert_equal("testFunc", errorObject.func);
    assert_equal(279, errorObject.line);
    assert_not_nil(errorObject.message);
end

function macroTest()
    luaUnit.TEST_SUITE("EmptyMacroTestSuite")
    {
    };
    
    assert_equal(2, #luaUnit.TestRegistry.testsuites);
    assert_equal(0, #luaUnit.TestRegistry.testsuites[2].testcases);

    luaUnit.TEST_SUITE("MacroTestSuiteWithOneTestCase")
    {
        luaUnit.TEST_CASE{"MacroTestCase", function()
            luaUnit.ASSERT_EQUAL(0, 0);
        end};
    };

    assert_equal(3, #luaUnit.TestRegistry.testsuites);
    assert_equal(0, #luaUnit.TestRegistry.testsuites[1].testcases);
    assert_equal(0, #luaUnit.TestRegistry.testsuites[2].testcases);
    assert_equal(1, #luaUnit.TestRegistry.testsuites[3].testcases);
end

function testFrameTest()
    local testList;
    ---------------------------------------------------
    -- initialize message system
    local testObserver = testRunner.TestObserver:new();
    local mockTestListener = testRunner.TestListener:new();
    mockTestListener.error_ = false;
    function mockTestListener:addError()
        mockTestListener.error_ = true;
    end
    function mockTestListener:addFailure()
        mockTestListener.error_ = true;
    end
    testObserver:addTestListener(mockTestListener);
    ---------------------------------------------------
    -- Make TestCase manually, then run it 
    mockTestListener.error_ = false;
    local testcase = luaUnit.TestCase:new("GetTestListTestCase");
    testcase.test = function()
        luaUnit.ASSERT_EQUAL(0, 0);
    end
    luaUnit.TestRegistry:addTestCase(testcase);

    testList = luaUnit.getTestList();
    assert_not_nil(testList);
    assert_equal(1, #testList);

    testRunner.runTestCase(testList[1].name_, testList[1], testObserver);
    assert_false(mockTestListener.error_);
    ---------------------------------------------------
    -- Make TestCase, using macro, then run it 
    mockTestListener.error_ = false;
    luaUnit.TEST_SUITE("TestFrameTestSuite")
    {
        luaUnit.TEST_CASE{"TestFrameTestCase", function()
            luaUnit.ASSERT_EQUAL(0, 0);
        end};
    };
    
    testList = luaUnit.getTestList();
    assert_not_nil(testList);
    assert_equal(2, #testList);

    testRunner.runTestCase(testList[1].name_, testList[1], testObserver);
    testRunner.runTestCase(testList[2].name_, testList[2], testObserver);
end

function testFixtureTest()
    local setUpExecuted = false;
    local testExecuted = false;
    local tearDownExecuted = false;
    luaUnit.TEST_FIXTURE("MockTestFixture")
    {
        setUp = function(self)
            setUpExecuted = true;
        end
        ;
        tearDown = function(self)
            tearDownExecuted = true;
        end
        ;
    };
    
    assert_equal(1, #luaUnit.TestRegistry.testsuites);
    assert_not_nil(_G["MockTestFixture"]);

    luaUnit.TEST_SUITE("TestFixtureTests")
    {
        luaUnit.TEST_CASE_EX{"EmptyTest", "MockTestFixture", function(self)
            testExecuted = true;
        end};
    };

    assert_equal(2, #luaUnit.TestRegistry.testsuites);
    assert_equal(0, #luaUnit.TestRegistry.testsuites[1].testcases);
    assert_equal(1, #luaUnit.TestRegistry.testsuites[2].testcases);
    
    local testObserver = testRunner.TestObserver:new();
    testRunner.runTestCase("TestFixtureTests::EmptyTest", luaUnit.TestRegistry.testsuites[2].testcases[1], testObserver);
    
    assert_true(setUpExecuted);
    assert_true(testExecuted);
    assert_true(tearDownExecuted);
end

--------------------------------------------------------------------------------------------------------------
module("LuaUnitAssertMacroTest", lunit.testcase, luaUnit.testmodule, package.seeall)
--------------------------------------------------------------------------------------------------------------
-- protect from run applicable functions as tests
TEST_SUITE = nil;
TEST_CASE = nil;
TEST_CASE_EX = nil;
TEST_FIXTURE = nil;

function boolAssertMacroTest()
    assert_pass(function() ASSERT(true) end);

    assert_pass(function() ASSERT(1) end);

    assert_pass(function() ASSERT(0 == 0) end);
    assert_pass(function() ASSERT(0 >= 0) end);
    assert_pass(function() ASSERT(0 <= 0) end);
    assert_pass(function() ASSERT(0 <= 1) end);
    assert_pass(function() ASSERT(1 > 0) end);
    assert_pass(function() ASSERT(-1 < 0) end);

    assert_pass(function() ASSERT(1 == 1) end);
    assert_pass(function() ASSERT(1 ~= 2) end);
    assert_pass(function() ASSERT(1 < 2) end);
    assert_pass(function() ASSERT(1 <= 1) end);
    assert_pass(function() ASSERT(1 <= 2) end);

    assert_pass(function() ASSERT(-1 == -1) end);
    assert_pass(function() ASSERT(1 ~= -1) end);
    
    assert_error(function() ASSERT(1 < 0) end);
    assert_error(function() ASSERT(1 == -1) end);
    assert_error(function() ASSERT(-1 ~= -1) end);
    assert_error(function() ASSERT(-1 < -2) end);
end

function assertEqualMacroTest()
    assert_pass(function() ASSERT_EQUAL(1, 1) end);
    assert_pass(function() ASSERT_EQUAL(0, 0) end);
    assert_pass(function() ASSERT_EQUAL(-1, -1) end);

    assert_error(function() ASSERT_EQUAL(1, 0) end);
    assert_error(function() ASSERT_EQUAL(-1, -2) end);
end

function assertNoEqualMacroTest()
    assert_error(function() ASSERT_NOT_EQUAL(1, 1) end);
    assert_error(function() ASSERT_NOT_EQUAL(0, 0) end);
    assert_error(function() ASSERT_NOT_EQUAL(-1, -1) end);

    assert_pass(function() ASSERT_NOT_EQUAL(1, 0) end);
    assert_pass(function() ASSERT_NOT_EQUAL(-1, -2) end);
end

function assertTrueTest()
    assert_pass(function() ASSERT_TRUE(true) end);
    assert_pass(function() ASSERT_TRUE(0 == 0) end);
    assert_pass(function() ASSERT_TRUE(-1 == -1) end);

    assert_error(function() ASSERT_TRUE(false) end);
    assert_error(function() ASSERT_TRUE(0 ~= 0) end);
    assert_error(function() ASSERT_TRUE(-1 ~= -1) end);
end

function assertFalseTest()
    assert_pass(function() ASSERT_FALSE(false) end);
    assert_pass(function() ASSERT_FALSE(0 ~= 0) end);
    assert_pass(function() ASSERT_FALSE(-1 ~= -1) end);

    assert_error(function() ASSERT_FALSE(true) end);
    assert_error(function() ASSERT_FALSE(0 == 0) end);
    assert_error(function() ASSERT_FALSE(-1 == -1) end);
end

function assertThrowTest()
    assert_pass(function() ASSERT_THROW(function() error("", 0) end) end);
    assert_error(function() ASSERT_THROW(function() end) end);
end

function assertNoThrowTest()
    assert_error(function() ASSERT_NO_THROW(function() error("", 0) end) end);
    assert_pass(function() ASSERT_NO_THROW(function() end) end);
end

function assertIsTypeTest()
    assert_pass(function() ASSERT_NIL(nil) end);
    assert_pass(function() ASSERT_BOOLEAN(true) end);
    assert_pass(function() ASSERT_NUMBER(1) end);
    assert_pass(function() ASSERT_STRING("a") end);
    assert_pass(function() ASSERT_TABLE({}) end);
    assert_pass(function() ASSERT_FUNCTION(function() end) end);

    assert_error(function() ASSERT_NIL(true) end);
    assert_error(function() ASSERT_BOOLEAN(nil) end);
    assert_error(function() ASSERT_NUMBER("a") end);
    assert_error(function() ASSERT_STRING(1) end);
    assert_error(function() ASSERT_TABLE(function() end) end);
    assert_error(function() ASSERT_FUNCTION({}) end);
end

function assertIsNotTypeTest()
    assert_error(function() ASSERT_NOT_NIL(nil) end);
    assert_error(function() ASSERT_NOT_BOOLEAN(true) end);
    assert_error(function() ASSERT_NOT_NUMBER(1) end);
    assert_error(function() ASSERT_NOT_STRING("a") end);
    assert_error(function() ASSERT_NOT_TABLE({}) end);
    assert_error(function() ASSERT_NOT_FUNCTION(function() end) end);

    assert_pass(function() ASSERT_NOT_NIL(true) end);
    assert_pass(function() ASSERT_NOT_BOOLEAN(nil) end);
    assert_pass(function() ASSERT_NOT_NUMBER("a") end);
    assert_pass(function() ASSERT_NOT_STRING(1) end);
    assert_pass(function() ASSERT_NOT_TABLE(function() end) end);
    assert_pass(function() ASSERT_NOT_FUNCTION({}) end);
end

function assertMultipleEqualTest()
    assert_pass(function() ASSERT_MULTIPLE_EQUAL(1, 1) end);
    assert_pass(function() ASSERT_MULTIPLE_EQUAL(1, 'a', 1, "a") end);
    
    assert_error(function() ASSERT_MULTIPLE_EQUAL(1) end);
    assert_error(function() ASSERT_MULTIPLE_EQUAL(1, 1, 1) end);
    assert_error(function() ASSERT_MULTIPLE_EQUAL(1, 0) end);
    assert_error(function() ASSERT_MULTIPLE_EQUAL(1, 'a', 0, "a") end);
end

function assertStringEqualTest()
    assert_pass(function() ASSERT_STRING_EQUAL('', '') end);
    assert_pass(function() ASSERT_STRING_EQUAL('a', 'a') end);
    assert_pass(function() ASSERT_STRING_EQUAL('abc', 'abc') end);
    assert_pass(function() ASSERT_STRING_EQUAL('aA12-=+[](){}:;,./?*', 'aA12-=+[](){}:;,./?*') end);
    assert_error(function() ASSERT_STRING_EQUAL(
        'a\nA\n1\n2\n-\n=\n+\n[\n]\n(\n)\n{\n}\n:\n;\n,\n.\n/\n?\n*\n',
        'a\nC\n1\n2\n-\n=\n+\n[\n]\n(\n)\n{\n}\n:\n;\n,\n.\n/\n?\n*\n') end);
end
