local testRunner = require "yunit.test_runner"
local luaUnit = require "yunit.luaunit"
local aux = require "yunit.aux_test_func"
local fs = require "yunit.filesystem"
local lfs = require "yunit.lfs"

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

useTmpDir = 
{
    setUp = function(self)
        self.currentDir_ = lfs.currentdir()
        self.tmpDir_ = fs.tmpDirName()
        isTrue(lfs.mkdir(self.tmpDir_))
    end
    ;
    tearDown = function(self)
        isTrue(lfs.chdir(self.currentDir_))
        local status, msg = fs.rmdir(self.tmpDir_)
        areEq(nil, msg)
        isTrue(status)
    end
    ;
}

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
		areEq(0, 0);
	end
	noThrow(testcase.setUp);
	noThrow(testcase.test);
	noThrow(testcase.tearDown);
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
    isNotNil(testChunk.isBoolean)
    isNotNil(testChunk.isBool)
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

function useTmpDir.loadLuaContainer(self)
    lfs.chdir(self.tmpDir_)
    local luaTestContainerPath = 'lua_test_container.t.lua'
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
    aux.createTextFileWithContent(luaTestContainerPath, sourceCode)

	local testcases = luaUnit.loadTestContainer(luaTestContainerPath)

	isTable(testcases)
    areEq(3, #testcases)

    areEq(12, testcases[1]:lineNumber())
    areEq('_ignoredTest', testcases[1]:name())
    areEq(luaTestContainerPath, testcases[1]:fileName())
    isTrue(testcases[1]:isIgnored())
	
    areEq(10, testcases[2]:lineNumber())
    areEq('fixtureTestCase', testcases[2]:name())
    areEq(luaTestContainerPath, testcases[2]:fileName())
    isFalse(testcases[2]:isIgnored())
	
    areEq(9, testcases[3]:lineNumber())
    areEq('testCase', testcases[3]:name())
    areEq(luaTestContainerPath, testcases[3]:fileName())
    isFalse(testcases[3]:isIgnored())
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

function try_to_load_abscent_test_container()
    local rc, msg = luaUnit.loadTestContainer('path/with/denied:symbol.txt')
    isFalse(rc)
    isNotNil(msg)
    areNotEq(0, string.len(msg))
end

