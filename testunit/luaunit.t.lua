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

local luaUnit = require("testunit.luaunit");

module("luaunit.t", luaUnit.testmodule, package.seeall);

local testRunner = require("testunit.test_runner");
local luaExt = require("lua_ext")
local fs = require("filesystem")



TEST_FIXTURE("assertsAtSetUpFixture")
{
    setUp = function(self)
        ASSERT_TRUE(true)
    end
    ;
    tearDown = function(self)
    end
    ;
};

TEST_FIXTURE("assertsAtTearDownFixture")
{
    setUp = function(self)
    end
    ;
    tearDown = function(self)
        ASSERT_TRUE(true)
    end
    ;
};

-- This fixture save (at setUp) and restore (at tearDown) currentSuite variable at luaunit module for possibility TEST_* macro testing
TEST_FIXTURE("LuaUnitSelfTestFixture")
{
    setUp = function(self)
        self.testRegistry = luaUnit.TestRegistry:new();
        self.currentTestRegistry = luaUnit.currentTestRegistry();
        luaUnit.currentTestRegistry(self.testRegistry);
        
        self.currentSuite = luaUnit.currentSuite();
    end
    ;
    tearDown = function(self)
        luaUnit.currentSuite(self.currentSuite);
        luaUnit.currentTestRegistry(self.currentTestRegistry);
        self.currentSuite = nil;
        self.testRegistry = nil;
    end
    ;
};


TEST_SUITE("AppliedFunctionTestSuite")
{
    TEST_CASE{"copyTableTest", function(self)
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
        ASSERT_EQUAL(object.a_, clone.a_);
        ASSERT_EQUAL(object.get(), clone.get());
        object.set(1); clone.set(1);
        ASSERT_EQUAL(object.get(), clone.get());
        ASSERT_EQUAL(object.b_, clone.b_);
        ASSERT_EQUAL(getmetatable(object), getmetatable(clone));
    end
    };
};

TEST_SUITE("TestCaseTest")
{
    TEST_CASE{"createTestCaseTest", function(self)
        local testcase = luaUnit.TestCase:new("OnlyCreatedTestCase");
        ASSERT_IS_NOT_NIL(testcase);
        ASSERT_IS_NOT_NIL(testcase.setUp);
        ASSERT_EQUAL("function", type(testcase.setUp));
        ASSERT_IS_NOT_NIL(testcase.test);
        ASSERT_EQUAL("function", type(testcase.test));
        ASSERT_IS_NOT_NIL(testcase.tearDown);
        ASSERT_EQUAL("function", type(testcase.tearDown));
    end
    };

    TEST_CASE{"runSimpleTestCaseTest", function(self)
        local testcase = luaUnit.TestCase:new("runSimpleTestCase");
        testcase.test = function()
            luaUnit.ASSERT_EQUAL(0, 0);
        end
        ASSERT_NO_THROW(testcase.setUp);
        ASSERT_NO_THROW(testcase.test);
        ASSERT_NO_THROW(testcase.tearDown);
    end
    };
};

TEST_SUITE("LuaUnitTestRegistryTest")
{
    TEST_CASE_EX{"addingTestCasesToTestRegistryTest", "LuaUnitSelfTestFixture", function(self)
        ASSERT_EQUAL(1, #self.testRegistry.testsuites);
        ASSERT_EQUAL("Default", self.testRegistry.testsuites[1].name_);
        ASSERT_EQUAL(0, #self.testRegistry.testsuites[1].testcases);
        
        self.testRegistry:addTestCase(luaUnit.TestCase:new("TestCaseForDefaultTestSuite"));
        ASSERT_EQUAL(1, #self.testRegistry.testsuites);
        ASSERT_EQUAL(1, #self.testRegistry.testsuites[1].testcases);
        
        local testsuite = luaUnit.TestSuite:new("NotDefaultTestSuite");
        self.testRegistry:addTestSuite(testsuite);
        ASSERT_EQUAL(2, #self.testRegistry.testsuites);
        ASSERT_EQUAL(1, #self.testRegistry.testsuites[1].testcases);
        ASSERT_EQUAL(0, #self.testRegistry.testsuites[2].testcases);

        self.testRegistry:addTestCase(luaUnit.TestCase:new("OtherTestCaseForDefaultTestSuite"));
        ASSERT_EQUAL(2, #self.testRegistry.testsuites);
        ASSERT_EQUAL(2, #self.testRegistry.testsuites[1].testcases);
        ASSERT_EQUAL(0, #self.testRegistry.testsuites[2].testcases);
        
        testsuite:addTestCase(luaUnit.TestCase:new("TestCase1"));
        ASSERT_EQUAL(2, #self.testRegistry.testsuites);
        ASSERT_EQUAL(2, #self.testRegistry.testsuites[1].testcases);
        ASSERT_EQUAL(1, #self.testRegistry.testsuites[2].testcases);
        
        self.testRegistry:reset();
        ASSERT_EQUAL(1, #self.testRegistry.testsuites);
        ASSERT_EQUAL("Default", self.testRegistry.testsuites[1].name_);
        ASSERT_EQUAL(0, #self.testRegistry.testsuites[1].testcases);
    end
    };

    TEST_CASE_EX{"getTestListTest", "LuaUnitSelfTestFixture", function(self)
        local testList = luaUnit.getTestList();
        ASSERT_IS_NOT_NIL(testList);
        ASSERT_EQUAL(0, #testList);
        
        -- add one TestCase
        local testcaseName = "GetTestListTestCase";
        local testcase = luaUnit.TestCase:new(testcaseName);
        testcase.test = function()
            luaUnit.ASSERT_EQUAL(0, 0);
        end
        self.testRegistry:addTestCase(testcase);

        testList = luaUnit.getTestList();
        ASSERT_IS_NOT_NIL(testList);
        ASSERT_EQUAL(1, #testList);
    end
    };

    TEST_CASE_EX{"protectTestCaseMethodCallTest", "LuaUnitSelfTestFixture", function(self)
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
        ASSERT_FALSE(statusCode);
        
        ASSERT_IS_NOT_NIL(string.find(errorObject.source, 'luaunit%.t%.lua$'))
        ASSERT_EQUAL("testFunc", errorObject.func);
        
        ASSERT_IS_NOT_NIL(errorObject.line);
        ASSERT_IS_NUMBER(errorObject.line);
        ASSERT_NOT_EQUAL(0, errorObject.line);
        
        ASSERT_IS_NOT_NIL(errorObject.message);
        ASSERT_IS_STRING(errorObject.message);
    end
    };

    TEST_CASE_EX{"macroTest", "LuaUnitSelfTestFixture", function(self)
        luaUnit.TEST_SUITE("EmptyMacroTestSuite")
        {
        };
        
        ASSERT_EQUAL(2, #self.testRegistry.testsuites);
        ASSERT_EQUAL(0, #self.testRegistry.testsuites[2].testcases);

        luaUnit.TEST_SUITE("MacroTestSuiteWithOneTestCase")
        {
            luaUnit.TEST_CASE{"MacroTestCase", function()
                luaUnit.ASSERT_EQUAL(0, 0);
            end
            };
        };

        ASSERT_EQUAL(3, #self.testRegistry.testsuites);
        ASSERT_EQUAL(0, #self.testRegistry.testsuites[1].testcases);
        ASSERT_EQUAL(0, #self.testRegistry.testsuites[2].testcases);
        ASSERT_EQUAL(1, #self.testRegistry.testsuites[3].testcases);
    end
    };

    TEST_CASE_EX{"testFrameTest", "LuaUnitSelfTestFixture", function(self)
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
        
        self.testRegistry:addTestCase(testcase);

        local testList = luaUnit.getTestList();
        ASSERT_IS_NOT_NIL(testList);
        ASSERT_EQUAL(1, #testList);

        testRunner.runTestCase(testList[1].name_, testList[1], testObserver);
        ASSERT_FALSE(mockTestListener.error_);

        mockTestListener.error_ = false;
        luaUnit.TEST_SUITE("TestFrameTestSuite")
        {
            luaUnit.TEST_CASE{"TestFrameTestCase", function()
                luaUnit.ASSERT_EQUAL(0, 0);
            end
            };
        };
        
        testList = luaUnit.getTestList();
        ASSERT_IS_NOT_NIL(testList);
        ASSERT_EQUAL(2, #testList);
    end
    };

    TEST_CASE_EX{"testFixtureTest", "LuaUnitSelfTestFixture", function(self)
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
        
        ASSERT_EQUAL(1, #self.testRegistry.testsuites);
        ASSERT_IS_NOT_NIL(_G["MockTestFixture"]);

        luaUnit.TEST_SUITE("TestFixtureTests")
        {
            luaUnit.TEST_CASE_EX{"EmptyTest", "MockTestFixture", function(self)
                testExecuted = true;
            end
            };
        };

        ASSERT_EQUAL(2, #self.testRegistry.testsuites);
        ASSERT_EQUAL(0, #self.testRegistry.testsuites[1].testcases);
        ASSERT_EQUAL(1, #self.testRegistry.testsuites[2].testcases);
        
        local testList = luaUnit.getTestList();
        ASSERT_EQUAL(1, #testList);
        
        local testObserver = testRunner.TestObserver:new();
        testRunner.runTestCase("TestFixtureTests::EmptyTest", testList[1], testObserver);
        
        ASSERT_TRUE(setUpExecuted);
        ASSERT_TRUE(testExecuted);
        ASSERT_TRUE(tearDownExecuted);
    end
    };
};

TEST_SUITE("LuaUnitAssertMacroTest")
{
    TEST_CASE{"boolAssertMacroTest", function(self)
        ASSERT(true);

        ASSERT(1);

        ASSERT(0 == 0);
        ASSERT(0 >= 0);
        ASSERT(0 <= 0);
        ASSERT(0 <= 1);
        ASSERT(1 > 0);
        ASSERT(-1 < 0);

        ASSERT(1 == 1);
        ASSERT(1 ~= 2);
        ASSERT(1 < 2);
        ASSERT(1 <= 1);
        ASSERT(1 <= 2);

        ASSERT(-1 == -1);
        ASSERT(1 ~= -1);
        
        ASSERT_THROW(function() ASSERT(1 < 0) end);
        ASSERT_THROW(function() ASSERT(1 == -1) end);
        ASSERT_THROW(function() ASSERT(-1 ~= -1) end);
        ASSERT_THROW(function() ASSERT(-1 < -2) end);
    end
    };

    TEST_CASE{"assertEqualMacroTest", function(self)
        ASSERT_EQUAL(1, 1);
        ASSERT_EQUAL(0, 0);
        ASSERT_EQUAL(-1, -1);

        ASSERT_THROW(function() ASSERT_EQUAL(1, 0) end);
        ASSERT_THROW(function() ASSERT_EQUAL(-1, -2) end);
    end
    };

    TEST_CASE{"assertNoEqualMacroTest", function(self)
        ASSERT_THROW(function() ASSERT_NOT_EQUAL(1, 1) end);
        ASSERT_THROW(function() ASSERT_NOT_EQUAL(0, 0) end);
        ASSERT_THROW(function() ASSERT_NOT_EQUAL(-1, -1) end);

        ASSERT_NOT_EQUAL(1, 0);
        ASSERT_NOT_EQUAL(-1, -2);
    end
    };

    TEST_CASE{"assertTrueTest", function(self)
        ASSERT_TRUE(true);
        ASSERT_TRUE(0 == 0);
        ASSERT_TRUE(-1 == -1);

        ASSERT_THROW(function() ASSERT_TRUE(false) end);
        ASSERT_THROW(function() ASSERT_TRUE(0 ~= 0) end);
        ASSERT_THROW(function() ASSERT_TRUE(-1 ~= -1) end);
    end
    };

    TEST_CASE{"assertFalseTest", function(self)
        ASSERT_FALSE(false);
        ASSERT_FALSE(0 ~= 0);
        ASSERT_FALSE(-1 ~= -1);

        ASSERT_THROW(function() ASSERT_FALSE(true) end);
        ASSERT_THROW(function() ASSERT_FALSE(0 == 0) end);
        ASSERT_THROW(function() ASSERT_FALSE(-1 == -1) end);
    end
    };

    TEST_CASE{"assertThrowTest", function(self)
        ASSERT_THROW(function() error("", 0) end);
        ASSERT_THROW(function() ASSERT_THROW(function() end) end);
    end
    };

    TEST_CASE{"assertNoThrowTest", function(self)
        ASSERT_THROW(function() ASSERT_NO_THROW(function() error("", 0) end) end);
        ASSERT_NO_THROW(function() end);
    end
    };

    TEST_CASE{"assertIsTypeTest", function(self)
        ASSERT_IS_NIL(nil);
        ASSERT_IS_BOOLEAN(true);
        ASSERT_IS_NUMBER(1);
        ASSERT_IS_STRING("a");
        ASSERT_IS_TABLE({});
        ASSERT_IS_FUNCTION(function() end);

        ASSERT_THROW(function() ASSERT_IS_NIL(true) end);
        ASSERT_THROW(function() ASSERT_IS_BOOLEAN(nil) end);
        ASSERT_THROW(function() ASSERT_IS_NUMBER("a") end);
        ASSERT_THROW(function() ASSERT_IS_STRING(1) end);
        ASSERT_THROW(function() ASSERT_IS_TABLE(function() end) end);
        ASSERT_THROW(function() ASSERT_IS_FUNCTION({}) end);
    end
    };

    TEST_CASE{"assertIsNotTypeTest", function(self)
        ASSERT_THROW(function() ASSERT_IS_NOT_NIL(nil) end);
        ASSERT_THROW(function() ASSERT_IS_NOT_BOOLEAN(true) end);
        ASSERT_THROW(function() ASSERT_IS_NOT_NUMBER(1) end);
        ASSERT_THROW(function() ASSERT_IS_NOT_STRING("a") end);
        ASSERT_THROW(function() ASSERT_IS_NOT_TABLE({}) end);
        ASSERT_THROW(function() ASSERT_IS_NOT_FUNCTION(function() end) end);

        ASSERT_IS_NOT_NIL(true);
        ASSERT_IS_NOT_BOOLEAN(nil);
        ASSERT_IS_NOT_NUMBER("a");
        ASSERT_IS_NOT_STRING(1);
        ASSERT_IS_NOT_TABLE(function() end);
        ASSERT_IS_NOT_FUNCTION({});
    end
    };

    TEST_CASE{"assertMultipleEqualTest", function(self)
        ASSERT_MULTIPLE_EQUAL(1, 1);
        ASSERT_MULTIPLE_EQUAL(1, 'a', 1, "a");
        
        ASSERT_THROW(function() ASSERT_MULTIPLE_EQUAL(1) end);
        ASSERT_THROW(function() ASSERT_MULTIPLE_EQUAL(1, 1, 1) end);
        ASSERT_THROW(function() ASSERT_MULTIPLE_EQUAL(1, 0) end);
        ASSERT_THROW(function() ASSERT_MULTIPLE_EQUAL(1, 'a', 0, "a") end);
    end
    };

    TEST_CASE{"assertStringEqualTest", function(self)
        ASSERT_STRING_EQUAL('', '');
        ASSERT_STRING_EQUAL('a', 'a');
        ASSERT_STRING_EQUAL('abc', 'abc');
        ASSERT_STRING_EQUAL('aA12-=+[](){}:;,./?*', 'aA12-=+[](){}:;,./?*');
        ASSERT_THROW(function() ASSERT_STRING_EQUAL(
            'a\nA\n1\n2\n-\n=\n+\n[\n]\n(\n)\n{\n}\n:\n;\n,\n.\n/\n?\n*\n',
            'a\nC\n1\n2\n-\n=\n+\n[\n]\n(\n)\n{\n}\n:\n;\n,\n.\n/\n?\n*\n') end);
    end
    };
    
    TEST_CASE_EX{"assertsAtSetUp", "assertsAtSetUpFixture", function(self)
    end
    };
    
    TEST_CASE_EX{"assertsAtTearDown", "assertsAtTearDownFixture", function(self)
    end
    };
};


TEST_SUITE("NewSyntaxTests")
{
    TEST_CASE{"getTestEnvTest", function(self)
        local testContainerName = 'testunit.luaunit'
        local testChunk = luaUnit.getTestEnv(testContainerName)
        
        local mt = getmetatable(testChunk)
        ASSERT_IS_NOT_NIL(mt)
        ASSERT_IS_NOT_NIL(mt.__index)
        ASSERT_IS_NOT_NIL(testChunk._G)
        
        ASSERT_IS_NOT_NIL(testChunk._M)
        ASSERT_EQUAL(testChunk, testChunk._M)
        
        ASSERT_EQUAL(testContainerName, testChunk._NAME)
        
        ASSERT_IS_NOT_NIL(testChunk.isTrue)
        ASSERT_IS_NOT_NIL(testChunk.isFalse)
        ASSERT_IS_NOT_NIL(testChunk.areEq)
        ASSERT_IS_NOT_NIL(testChunk.areNotEq)
        ASSERT_IS_NOT_NIL(testChunk.noThrow)
        ASSERT_IS_NOT_NIL(testChunk.willThrow)

        ASSERT_IS_NOT_NIL(testChunk.isFunction)
        ASSERT_IS_NOT_NIL(testChunk.isTable)
        ASSERT_IS_NOT_NIL(testChunk.isNumber)
        ASSERT_IS_NOT_NIL(testChunk.isString)
        ASSERT_IS_NOT_NIL(testChunk.isBoolean)
        ASSERT_IS_NOT_NIL(testChunk.isNil)

        ASSERT_IS_NOT_NIL(testChunk.isNotFunction)
        ASSERT_IS_NOT_NIL(testChunk.isNotTable)
        ASSERT_IS_NOT_NIL(testChunk.isNotNumber)
        ASSERT_IS_NOT_NIL(testChunk.isNotString)
        ASSERT_IS_NOT_NIL(testChunk.isNotBoolean)
        ASSERT_IS_NOT_NIL(testChunk.isNotNil)
    end
    };
    
    TEST_CASE{"runTestChunkWithinSpecificEnvironmentTest", function(self)
        local testContainerName = 'testunit.luaunit'
        local test = [[function testCase() end 
                                local function notTestCase() end
                                isTrue(type(true) == "boolean")]]
        
        local env = luaUnit.getTestEnv(testContainerName)
        local res, msg = luaUnit.executeTestChunk(test, env, testContainerName)
        ASSERT_EQUAL(nil, msg)
        ASSERT_EQUAL(true, res)

        ASSERT_IS_NOT_NIL(env.testCase)
        ASSERT_IS_FUNCTION(env.testCase)

        ASSERT_IS_NIL(env.notTestCase)
    end
    };

    TEST_CASE{"executeTestChunkTest", function(self)
        local testContainerName = 'testunit.luaunit'
        local test = [[fixture =
                                {
                                    setUp = function()
                                    end,

                                    tearDown = function()
                                    end
                                }
                                function testCase() end 
                                function fixture.fixtureTestCase() end 
                                local function notTestCase() end
                                function _ignoredTest() end
                                ]]
        
        local env = luaUnit.getTestEnv(testContainerName)
        local res, msg = luaUnit.executeTestChunk(test, env, testContainerName)
        ASSERT_EQUAL(true, res)
        ASSERT_IS_NIL(msg)

        ASSERT_IS_NOT_NIL(env.testCase)
        ASSERT_IS_FUNCTION(env.testCase)

        ASSERT_IS_NOT_NIL(env._ignoredTest)
        ASSERT_IS_FUNCTION(env._ignoredTest)

        ASSERT_IS_NOT_NIL(env.fixture)
        ASSERT_IS_TABLE(env.fixture)

        ASSERT_IS_NOT_NIL(env.fixture.setUp)
        ASSERT_IS_FUNCTION(env.fixture.setUp)

        ASSERT_IS_NOT_NIL(env.fixture.tearDown)
        ASSERT_IS_FUNCTION(env.fixture.tearDown)

        ASSERT_IS_NOT_NIL(env.fixture.fixtureTestCase)
        ASSERT_IS_FUNCTION(env.fixture.fixtureTestCase)

        ASSERT_IS_NIL(env.notTestCase)
    end
    };
    
    TEST_CASE{"testFilteringOfTestCases", function(self)
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
        
        local testContainerName = 'testunit.luaunit'
        local testList = luaUnit.collectPureTestCaseList(env)
        
        ASSERT_TRUE(table.isEqual(expectedTestList, testList))
    end
    };
    
    TEST_CASE_EX{"loadTestChunk", "LuaUnitSelfTestFixture", function(self)
        local luaTestContainerSourceCode = 
            [[fixture =
                {
                    setUp = function()
                    end,

                    tearDown = function()
                    end
                }
                function testCase() end 
                function fixture.fixtureTestCase() end 
                local function notTestCase() end
                function _ignoredTest() end
                ]]
        local luaTestContainerName = 'load_lua_container.t'

        ASSERT_EQUAL(1, #self.testRegistry.testsuites)
        ASSERT_EQUAL(0, #self.testRegistry.testsuites[1].testcases)
        
        local status, msg = luaUnit.loadTestChunk(luaTestContainerSourceCode, luaTestContainerName)
        ASSERT_EQUAL(nil, msg)
        ASSERT_TRUE(status)
        
        ASSERT_EQUAL(2, #self.testRegistry.testsuites)
        ASSERT_EQUAL(0, #self.testRegistry.testsuites[1].testcases)
        
        ASSERT_EQUAL(luaTestContainerName, self.testRegistry.testsuites[2].name_)
        ASSERT_EQUAL(3, #self.testRegistry.testsuites[2].testcases)
    end
    };
};
