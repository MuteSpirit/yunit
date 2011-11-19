--[[ Lua Test Unit Engine ]]

local _M = {}
local _Mmt = {__index = _G}
setmetatable(_M, _Mmt)
local _G = _M

local ytrace = require "yunit.trace"

--[[////////////////////////////////////////////////////////////////////////////////////////////////////////]]
TestFixture = 
{
    new = function(self, o)
        local obj =  o or {}
        setmetatable(obj, self)
        self.__index = self
        return obj
    end;
    
    setUp =    function(self) end;
    tearDown = function(self) end;
}
--[[////////////////////////////////////////////////////////////////////////////////////////////////////////]]
TestCase = TestFixture:new
{
    new = function(self, name)
        local o = 
        {
            name_ = name,
            isIgnored_ = false,
            fileName_ = "unknown",
            lineNumber_ = 0,
        }
        setmetatable(o, self)
        self.__index = self
        return o
    end;

    name =       function(self) return self.name_; end;
    test =       function(self) return; end;
    fileName =   function(self) return self.fileName_; end;
    lineNumber = function(self) return self.lineNumber_; end;
    isIgnored =  function(self) return self.isIgnored_; end;
}

--[[
    Luaunit interface functions
--]]
function getTestContainerExtensions()
    return {'.t.lua'}
end

function loadTestContainer(filePath)
    -- get test container source code
    local sourceCode
    do
        local f, errMsg = io.open(filePath, 'rb')
        if not f then
            return f, errMsg
        end

        sourceCode = f:read('*a')
        f:close()
    end
    
    -- load test cases
    
    local testContainerName = filePath
   	local env = getTestEnv(testContainerName)
    local chunk, msg

    if 'Lua 5.2' == _VERSION then
        chunk, msg = load(sourceCode, '=' .. testContainerName, 't', env)
        if not chunk then
            return false, msg
        end
    else
        chunk, msg = loadstring(sourceCode, '=' .. testContainerName)
        if not chunk then
            return false, msg
        end
        setfenv(chunk, env)
    end

    local status
    status, msg = pcall(chunk)
    if not status then
        return false, msg
    end
	
	-- look for TestCases into loaded test container
	
	local testcases = collectPureTestCaseList(env)
    if not next(testcases) then
        return false, 'No one TestCase has been loaded'
    end
    
    for _, testcase in ipairs(testcases) do
        testcase.fileName_ = testContainerName;
		
        if 'function' == type(testcase.test) then
            testcase.lineNumber_ = debug.getinfo(testcase.test, 'S')['linedefined']
        else
            testcase.lineNumber_ = 0
        end
    end
    
    return makeTestCasesReadyForPublicUsage(testcases)
end

--[[
    Internal functions (used in module and in module tests)
--]]

local function wrapValue(v)
    if "string" == type(v) then
        return "'"..v.."'"
    end
    return tostring(v);
end

function registerAssertFucntionsInto(mt)
    mt.isTrue = function(actual)
        if not actual then
            error("true expected but was nil or false", 0)
        end
    end

    mt.isFalse = function(actual)
        if actual then
            error("nil or false expected but was true", 0)
        end
    end

    mt.areEq = function(expected, actual)
        local expectedType = type(expected) or 'nil'
        local actualType = type(actual) or 'nil';

        if actualType ~= expectedType then
            error("expected type is " .. expectedType .. " but was a ".. actualType, 0)
        end

	    if  actual ~= expected  then
		    local errorMsg = "\nexpected: "..wrapValue(expected).."\n"..
                             "actual  : "..wrapValue(actual).."\n";
		    error(errorMsg, 0);
	    end
    end

    mt.areNotEq = function(expected, actual)
	    if  actual == expected  then
		    local errorMsg = "expected that actual will not equal "..wrapValue(actual)
		    error(errorMsg, 0);
	    end
    end

    mt.noThrow = function(functionForRun, ...)
        local functype = type(functionForRun);
        if functype ~= "function" then
            error(string.format("expected a function as last argument but was a %s", functype), 0);
        end
        local ok, errmsg = pcall(functionForRun, ...);
        if not ok then
            error(string.format("no error expected but error was: '%s'", errmsg), 0)
        end
    end

    mt.willThrow = function(functionForRun, ...)
        local functype = type(functionForRun);
        if functype ~= "function" then
            error(string.format("expected a function as last argument but was a %s", functype), 0);
        end
        local ok, errmsg = pcall(functionForRun, ...);
        if ok then
            error("error expected but everything was OK", 0)
        end
    end

    local typenames = { "nil", "boolean", "number", "string", "table", "function", "thread", "userdata" }

    -- isTypename functions
    for _, typename in ipairs(typenames) do
        local assertTypename = "is" .. string.upper(string.sub(typename, 1 , 1)) .. string.sub (typename, 2);
        mt[assertTypename] = function(actual, explanatoryMessage)
            local actualType = type(actual);
            if actualType ~= typename then
                local msgPostfix = explanatoryMessage and ': "' .. explanatoryMessage .. '"' or ''
                error(typename.." expected but was a " .. actualType .. msgPostfix, 0)
            end
        end
    end
    mt.isBool = mt.isBoolean


    -- isNotTypename functions
    for _, typename in ipairs(typenames) do
        local assertTypename = "isNot" .. string.upper(string.sub(typename, 1 , 1)) .. string.sub (typename, 2);
        mt[assertTypename] = function(actual, explanatoryMessage)
            local actualType = type(actual);
            if actualType == typename then
                local msgPostfix = explanatoryMessage and ': "' .. explanatoryMessage .. '"' or ''
                error(typename .. " not expected but was one" .. msgPostfix, 0);
            end
        end
    end
    mt.isNotBool = mt.isNotBoolean
end

-- use common metatable to decrease memory usage
local testCaseMt = {}
registerAssertFucntionsInto(testCaseMt)
testCaseMt.__index = function(table, key) return rawget(table, key) or rawget(testCaseMt, key) or _M[key]; end

-------------------------------------------------------
function getTestEnv(moduleName)
-------------------------------------------------------
    local ns =
    {
        ['_NAME'] = moduleName,
        ['_PACKAGE'] = string.gsub(moduleName, '[^%.]*$', ''),
    }
    ns._M = ns
    setmetatable(ns, testCaseMt)
    
    return ns
end


-------------------------------------------------------
function collectPureTestCaseList(env)
-------------------------------------------------------
    local function isFixture(value)
        return "table" == type(value) and "function" == type(value.setUp) and "function" == type(value.tearDown)
    end

    local function isFixtureTestCase(name, value)
        return "function" == type(value) and "setUp" ~= name and "tearDown" ~= name
    end

    local testCaseList = {}
    
    for name, value in pairs(env) do
        
        if "function" == type(value) then -- this is testCase
            local testCase = TestCase:new(name)
            testCase.isIgnored_ = nil ~= string.find(name, "^_")
            testCase.test = value
            table.insert(testCaseList, testCase)
        elseif isFixture(value) then
            local fixture = value
            for i, v in pairs(fixture) do
                if  isFixtureTestCase(i, v) then
                    local testCase = TestCase:new(i)
                    testCase.isIgnored_ = nil ~= string.find(i, "^_")
                    testCase.test = v
                    testCase.setUp = fixture.setUp
                    testCase.tearDown = fixture.tearDown
                    table.insert(testCaseList, testCase)
                end
            end
        end
    end
    return testCaseList
end

local callTestCaseSetUp
local callTestCaseTest
local callTestCaseTearDown

-------------------------------------------------------
function makeTestCasesReadyForPublicUsage(testcases)
-------------------------------------------------------
    for _, test in ipairs(testcases) do
        test.originalSetUp = test.setUp
        test.setUp = callTestCaseSetUp

        test.originalTest = test.test
        test.test = callTestCaseTest

        test.originalTearDown = test.tearDown
        test.tearDown = callTestCaseTearDown
    end
    
    return testcases
end

local callTestCaseMethod

callTestCaseSetUp = function(testcase)
    return callTestCaseMethod(testcase, testcase.originalSetUp)
end

callTestCaseTest = function(testcase)
    return callTestCaseMethod(testcase, testcase.originalTest)
end

callTestCaseTearDown = function(testcase)
    return callTestCaseMethod(testcase, testcase.originalTearDown)
end

-------------------------------------------------------
callTestCaseMethod = function(testcase, testFunc)
-------------------------------------------------------
    local rc, stackTraceback, errorLevel
    if _VERSION == 'Lua 5.2' then
        rc, stackTraceback = xpcall(testFunc, ytrace.traceback, testcase);
        errorLevel = 3
    else
        local function callMethod()
            testFunc(testcase)
        end
        rc, stackTraceback = xpcall(callMethod, ytrace.traceback)
        errorLevel = 4
    end
    
    if stackTraceback then
        local errorObject = 
        {
            source = string.sub(stackTraceback.stack[errorLevel].source, 2), -- skip '=' in 'source' begin
            line = stackTraceback.stack[errorLevel].line,
            message = stackTraceback.error.message,
        }
        local isLuaunitAssertFailed = nil ~= string.find(stackTraceback.stack[errorLevel - 1].source, 'luaunit%.lua$')
        if not isLuaunitAssertFailed then
            errorObject.traceback = stackTraceback.stack
        end
        return rc, errorObject
    else
        return rc
    end
end

return _M
