--- \fn copyTable(object, clone)
--- \brief Make full copy of table
--- \param[in] object Sample for cloning
--- \return Cloned object of original object

--- \class TestFixture
--- \brief Class, whtich has setUp and tearDown function. It is base for TestCase class.

--- \class TestCase
--- \brief Single Test. TestCase object contain test code and namely it is executed.

--- \class TestSuite
--- \brief Class, whitch has name and contains TestCase objects. One level at tree of tests.

--- \class TestRegistry
--- \brief Contain all TestSuites from loaded Lua test scripts (*.t.lua) and C++ test drivers (*.t.dll)

--- \fn TestRegistry:reset()
--- \brief return TestRegistry to the default state

--- \fn getTestList()
--- \brief Return collection of objects with TestCase interface ("name_", setUp, test, tearDown). Names of TestCases contains TestSuite and TestCase name, separated by '::'
--- \return List of TestCases-like objects 

--- \fn callTestCaseMethod(testcase, testFunc)
--- \brief Call method of TestCase object and get advanced info in case of mistaken execution
--- \param[in] testcase TestCase object
--- \param[in] testFunc 'test', 'setUp' or 'tearDown' function of 'testcase'
--- \return status code of 'testFunc' execution and ErrorObject with additional info



local testRunner = require("yunit.test_runner");
local luaExt = require("lua_ext")
local fs = require("filesystem")
local luaUnit = require('yunit.luaunit');
local testResultHandlers = require('yunit.test_result_handlers');

assertsAtSetUpFixture = 
{
    setUp = function(self)
        isTrue(true)
    end
    ;
    tearDown = function(self)
    end
    ;
};

assertsAtTearDownFixture = 
{
    setUp = function(self)
    end
    ;
    tearDown = function(self)
        isTrue(true)
    end
    ;
};

-- This fixture save (at setUp) and restore (at tearDown) currentSuite variable at luaunit module for possibility assert macro testing
luaUnitSelfTestFixture = 
{
    setUp = function(self)
        testRegistry = luaUnit.TestRegistry:new();
        currentTestRegistry = luaUnit.currentTestRegistry();
        luaUnit.currentTestRegistry(testRegistry);
        
        currentSuite = luaUnit.currentSuite();
    end
    ;
    tearDown = function(self)
        luaUnit.currentSuite(currentSuite);
        luaUnit.currentTestRegistry(currentTestRegistry);
        currentSuite = nil;
        testRegistry = nil;
    end
    ;
};

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
	areEq(object.a_, clone.a_);
	areEq(object.get(), clone.get());
	object.set(1); clone.set(1);
	areEq(object.get(), clone.get());
	areEq(object.b_, clone.b_);
	areEq(getmetatable(object), getmetatable(clone));
end

function createTestCaseTest()
	local testcase = luaUnit.TestCase:new("OnlyCreatedTestCase");
	isNotNil(testcase);
	isNotNil(testcase.setUp);
	areEq("function", type(testcase.setUp));
	isNotNil(testcase.test);
	areEq("function", type(testcase.test));
	isNotNil(testcase.tearDown);
	areEq("function", type(testcase.tearDown));
end

function runSimpleTestCaseTest()
	local testcase = luaUnit.TestCase:new("runSimpleTestCase");
	testcase.test = function()
		luaUnit.areEq(0, 0);
	end
	noThrow(testcase.setUp);
	noThrow(testcase.test);
	noThrow(testcase.tearDown);
end
    
function luaUnitSelfTestFixture.addingTestCasesToTestRegistryTest()
    areEq(0, #testRegistry.testsuites);
    
    local testsuite = luaUnit.TestSuite:new("NotDefaultTestSuite");
    testRegistry:addTestSuite(testsuite);
    areEq(1, #testRegistry.testsuites);
    areEq(0, #testRegistry.testsuites[1].testcases);

    testsuite:addTestCase(luaUnit.TestCase:new("TestCase1"));
    areEq(1, #testRegistry.testsuites);
    areEq(1, #testRegistry.testsuites[1].testcases);
    
    testRegistry:reset();
    areEq(0, #testRegistry.testsuites);
end

function luaUnitSelfTestFixture.getTestListTest()
    local testList = luaUnit.getTestList();
    isNotNil(testList);
    areEq(0, #testList);
    
    -- add one TestCase
    local testcaseName = "GetTestListTestCase";
    local testcase = luaUnit.TestCase:new(testcaseName);
    testcase.test = function()
        luaUnit.areEq(0, 0);
    end

    testList = luaUnit.getTestList();
    isNotNil(testList);
    areEq(0, #testList);
    
    local testsuite = luaUnit.TestSuite:new("GetTestListTestSuite");
    testsuite:addTestCase(testcase);
    testRegistry:addTestSuite(testsuite);
    
    testList = luaUnit.getTestList();
    isNotNil(testList);
    areEq(1, #testList);
end

function luaUnitSelfTestFixture.protectTestCaseMethodCallTest()
	-- we try to call create simple TestCAse and call 'setUp', 'test', 'tearDown' in protected mode
	-- in the result we must receive object with such data:
	-- - file name of script  with error
	-- - line number of failed ASSERT
	-- - text message from that ASSERT
	
	local testcase = luaUnit.TestCase:new("TestCaseForProtectCall");
	testcase.test = function()
		-- must except error
		luaUnit.areNotEq(0, 0);
	end
	
	local statusCode, errorObject = luaUnit.callTestCaseMethod(testcase, testcase.test);
	isFalse(statusCode)
	isNotNil(errorObject)

	areEq('luaunit.t.lua', errorObject.source)
	areEq("testFunc", errorObject.func);
	
	isNotNil(errorObject.line);
	isNumber(errorObject.line);
	areNotEq(0, errorObject.line);
	
	isNotNil(errorObject.message);
	isString(errorObject.message);
end

function luaUnitSelfTestFixture.testFrame()
    ---------------------------------------------------
    -- initialize message system
    local testObserver = testRunner.TestResultHandlerList:new();
    local mockTestListener = testRunner.TestResultHandler:new();
    mockTestListener.error_ = false;
    function mockTestListener:onTestError()
        mockTestListener.error_ = true;
    end
    function mockTestListener:onTestFailure()
        mockTestListener.error_ = true;
    end
    testObserver:addHandler(mockTestListener);
    ---------------------------------------------------
    -- Make TestCase manually, then run it 
    mockTestListener.error_ = false;
    local testcase = luaUnit.TestCase:new("testFrameTestCase");
    testcase.test = function()
        luaUnit.areEq(0, 0);
    end
    
    local testsuite = luaUnit.TestSuite:new("testFrameTestSuite");
    testsuite:addTestCase(testcase);
    testRegistry:addTestSuite(testsuite);
    
    local testList = luaUnit.getTestList();
    isNotNil(testList);
    areEq(1, #testList);

    testRunner.runTestCase(testList[1], testObserver);
    isFalse(mockTestListener.error_);
end

    
function getTestEnvTest()
    local testContainerName = 'yunit.luaunit'
    local testChunk = luaUnit.getTestEnv(testContainerName)
    
    local mt = getmetatable(testChunk)
    isNotNil(mt)
    isNotNil(mt.__index)
    isNotNil(testChunk._G)
    
    isNotNil(testChunk._M)
    areEq(testChunk, testChunk._M)
    
    areEq(testContainerName, testChunk._NAME)
    
    isNotNil(testChunk.isTrue)
    isNotNil(testChunk.isFalse)
    isNotNil(testChunk.areEq)
    isNotNil(testChunk.areNotEq)
    isNotNil(testChunk.noThrow)
    isNotNil(testChunk.willThrow)

    isNotNil(testChunk.isFunction)
    isNotNil(testChunk.isTable)
    isNotNil(testChunk.isNumber)
    isNotNil(testChunk.isString)
    isNotNil(testChunk.isBool)
    isNotNil(testChunk.isBoolean)
    isNotNil(testChunk.isNil)

    isNotNil(testChunk.isNotFunction)
    isNotNil(testChunk.isNotTable)
    isNotNil(testChunk.isNotNumber)
    isNotNil(testChunk.isNotString)
    isNotNil(testChunk.isNotBool)
    isNotNil(testChunk.isNotBoolean)
    isNotNil(testChunk.isNotNil)
end

function collectTestcasesFromSimpleTestCaseEnvironment()
    local env = 
    {
        testCase = function() end,
        _ignoredTest = function() end,
        fixture =
        {
            setUp = function() end,
            tearDown = function() end,
            fixtureTestCase = function() end,
        }
    }
    
    local expectedTestList = 
    {
        {
            name_ = '_ignoredTest',
            isIgnored_ = true,
            test = env._ignoredTest,
        },
        {
            name_ = 'testCase',
            isIgnored_ = false,
            test = env.testCase,
        },
        {
            name_ = 'fixtureTestCase',
            setUp = env.fixture.setUp,
            isIgnored_ = false,
            test = env.fixture.fixtureTestCase,
            tearDown = env.fixture.tearDown,
        },
    }
    
    local testContainerName = 'yunit.luaunit'
    local testList = luaUnit.collectPureTestCaseList(env)
    
    isTrue(table.isEqual(expectedTestList, testList))
end

function loadTestCases()
    local luaTestContainerName = 'lua_test_container.t'
    local sourceCode = 
        [[fixture =										-- 1
            {													-- 2
                setUp = function()							-- 3
                end,											-- 4
															-- 5
                tearDown = function()						-- 6
                end												-- 7
            }													-- 8
            function testCase() end 						-- 9
            function fixture.fixtureTestCase() end 		-- 10
            local function notTestCase() end				-- 11
            function _ignoredTest() end					-- 12
            ]]
	local testcases = luaUnit.loadTestCases(sourceCode, luaTestContainerName)

	isTable(testcases)
    areEq(3, #testcases)

    areEq(12, testcases[1].lineNumber_)
    areEq('_ignoredTest', testcases[1].name_)
    isTrue(testcases[1].isIgnored_)
	
    areEq(10, testcases[2].lineNumber_)
    areEq('fixtureTestCase', testcases[2].name_)
    isFalse(testcases[2].isIgnored_)
	
    areEq(9, testcases[3].lineNumber_)
    areEq('testCase', testcases[3].name_)
    isFalse(testcases[3].isIgnored_)
end

function isLuaTestContainerTest()
    local extList = luaUnit.getTestContainerExtensions()
    areEq(1, #extList);
    areEq(".t.lua", extList[1]);
end

function isTrueTest()
    isTrue(true);

    isTrue(0 == 0);
    isTrue(0 >= 0);
    isTrue(0 <= 0);
    isTrue(0 <= 1);
    isTrue(1 > 0);
    isTrue(-1 < 0);

    isTrue(1 == 1);
    isTrue(1 ~= 2);
    isTrue(1 < 2);
    isTrue(1 <= 1);
    isTrue(1 <= 2);

    isTrue(-1 == -1);
    isTrue(1 ~= -1);
end

function isTrueFailTest()
    willThrow(function() isTrue(false) end);
    willThrow(function() isTrue(1 < 0) end);
    willThrow(function() isTrue(1 == -1) end);
    willThrow(function() isTrue(-1 ~= -1) end);
    willThrow(function() isTrue(-1 < -2) end);
end

function isFalseTest()
    isFalse(false);
    isFalse(0 ~= 0);
    isFalse(-1 ~= -1);
end

function isFalseFailTest()
    willThrow(function() isFalse(true) end);
    willThrow(function() isFalse(0 == 0) end);
    willThrow(function() isFalse(-1 == -1) end);
end

function areEqTest()
    noThrow(function() areEq(1, 1) end);
    noThrow(function() areEq(0, 0) end);
    noThrow(function() areEq(-1, -1) end);
    noThrow(function() areEq(nil, nil) end);

    noThrow(function() areEq('', '') end);
    noThrow(function() areEq('a', 'a') end);
    noThrow(function() areEq('abc', 'abc') end);
    noThrow(function() areEq('\t\n\r\b', '\t\n\r\b') end);
    noThrow(function() areEq('aA12-=+[](){}: end);,./?*', 'aA12-=+[](){}: end);,./?*') end);
end

function areEqFailTest()
    willThrow(function() areEq(-1, 'asd') end);
    willThrow(function() areEq(1, nil) end);
    willThrow(function() areEq(false, nil) end);
    willThrow(function() areEq(true, 1) end);
    willThrow(function() areEq(true, 'true') end);

    willThrow(function() areEq(1, 0) end);
    willThrow(function() areEq(-1, -2) end);
    willThrow(function() areEq({}, {}) end);
  
    willThrow(function() areEq(
        '\ta\nA\n1\n2\n-\n=\n+\n[\n]\n(\n)\n{\n}\n:\n;\n,\n.\n/\n?\n*\n',
        '\ta\nC\n1\n2\n-\n=\n+\n[\n]\n(\n)\n{\n}\n:\n;\n,\n.\n/\n?\n*\n') end);
end

function areNotEqTest()
    noThrow(function() areNotEq(1, 0) end);
    noThrow(function() areNotEq(-1, -2) end);
    noThrow(function() areNotEq('', 1) end);
    noThrow(function() areNotEq(nil, false) end);
    noThrow(function() areNotEq(true, 'true') end);
    noThrow(function() areNotEq({}, {}) end);
end

function areNotEqFailTest()
    willThrow(function() areNotEq(1, 1) end);
    willThrow(function() areNotEq(0, 0) end);
    willThrow(function() areNotEq(-1, -1) end);

    willThrow(function() areNotEq(nil, nil) end);
    willThrow(function() areNotEq('', '') end);
end

function willThrowTest()
    willThrow(function() error("", 0) end);
    willThrow(function() willThrow(function() end) end);
end

function noThrowTest()
    willThrow(function() noThrow(function() error("", 0) end) end);
    noThrow(function() end);
end

function isTypenameTest()
    noThrow(function() isNil(nil) end);
    noThrow(function() isBoolean(true) end);
    noThrow(function() isBool(true) end);
    noThrow(function() isNumber(1) end);
    noThrow(function() isString("a") end);
    noThrow(function() isTable({}) end);
    noThrow(function() isFunction(function() end) end);

    willThrow(function() isNil(true) end);
    willThrow(function() isBoolean(nil) end);
    willThrow(function() isBool(nil) end);
    willThrow(function() isNumber("a") end);
    willThrow(function() isString(1) end);
    willThrow(function() isTable(function() end) end);
    willThrow(function() isFunction({}) end);
end

function isNotTypenameTest()
    willThrow(function() isNotNil(nil) end);
    willThrow(function() isNotBoolean(true) end);
    willThrow(function() isNotBool(true) end);
    willThrow(function() isNotNumber(1) end);
    willThrow(function() isNotString("a") end);
    willThrow(function() isNotTable({}) end);
    willThrow(function() isNotFunction(function() end) end);

    noThrow(function() isNotNil(true) end);
    noThrow(function() isNotBoolean(nil) end);
    noThrow(function() isNotBool(nil) end);
    noThrow(function() isNotNumber("a") end);
    noThrow(function() isNotString(1) end);
    noThrow(function() isNotTable(function() end) end);
    noThrow(function() isNotFunction({}) end);
end

function assertsAtSetUpFixture.assertsAtSetUp()
end

function assertsAtTearDownFixture.assertsAtTearDown()
end