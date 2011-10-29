--[[ Lua Test Unit Engine ]]

local _M = {}
local _Mmt = {__index = _G}
setmetatable(_M, _Mmt)
local _G = _M

--[[////////////////////////////////////////////////////////////////////////////////////////////////////////]]
TestFixture = 
{
    new = function(self, o)
        local obj =  o or {}
        setmetatable(obj, self)
        self.__index = self
        return obj
    end;
    
    setUp = function(self)
    end;

    tearDown = function(self)
    end;
}
--[[////////////////////////////////////////////////////////////////////////////////////////////////////////]]
TestCase = TestFixture:new
{
    new = function(self, name)
        local o = 
        {
            name_ = name,
            isIgnored_ = false,
        }
        setmetatable(o, self)
        self.__index = self
        return o
    end;

    name = function(self)
        return self.name_
    end;

    test = function(self)
    end;
    
    fileName = function(self)
        return 'unknown'
    end;
    
    lineNumber = function(self)
        return 0
    end;
    
    isIgnored = function(self)
        return self.isIgnored_
    end;
}

-------------------------------------------------------
-- Assert macro
-------------------------------------------------------

local function wrapValue(v)
    if "string" == type(v) then
        return "'"..v.."'"
    end
    return tostring(v);
end

function isTrue(actual)
    if not actual then
        error("true expected but was nil or false", 0)
    end
end

function isFalse(actual)
    if actual then
        error("nil or false expected but was true", 0)
    end
end

function areEq(expected, actual)
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

function areNotEq(expected, actual)
	if  actual == expected  then
		local errorMsg = "expected that actual will not equal "..wrapValue(actual)
		error(errorMsg, 0);
	end
end

function noThrow(functionForRun, ...)
    local functype = type(functionForRun);
    if functype ~= "function" then
        error(string.format("expected a function as last argument but was a %s", functype), 0);
    end
    local ok, errmsg = pcall(functionForRun, ...);
    if not ok then
        error(string.format("no error expected but error was: '%s'", errmsg), 0)
    end
end

function willThrow(functionForRun, ...)
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
    _M[assertTypename] = function(actual, explanatoryMessage)
        local actualType = type(actual);
        if actualType ~= typename then
            error(typename.." expected but was a " .. actualType .. ': ' .. explanatoryMessage .. '"', 0)
        end
    end
end
_M.isBool = _M.isBoolean


-- isNotTypename functions
for _, typename in ipairs(typenames) do
    local assertTypename = "isNot" .. string.upper(string.sub(typename, 1 , 1)) .. string.sub (typename, 2);
    _M[assertTypename] = function(actual, explanatoryMessage)
        local actualType = type(actual);
        if actualType == typename then
            error(typename .. " not expected but was one" .. ': "' .. explanatoryMessage .. '"', 0);
        end
    end
end
_M.isNotBool = _M.isNotBoolean



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

-- use common metatable to decrease memory usage
local testCaseMt = {__index = _M}

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

local function callTestCaseSetUp(testcase)
    return callTestCaseMethod(testcase, testcase.originalSetUp)
end

local function callTestCaseTest(testcase)
    return callTestCaseMethod(testcase, testcase.originalTest)
end

local function callTestCaseTearDown(testcase)
    return callTestCaseMethod(testcase, testcase.originalTearDown)
end

-------------------------------------------------------
function makeTestCasesReadyForPublicUsage(testcases)
-------------------------------------------------------
    local testList = {}
    
    for _, testcase in ipairs(testcases) do
        local testcaseName = testcase.name_
        local test = copyTable(testcase)
        
        test.originalSetUp = test.setUp
        test.setUp = callTestCaseSetUp

        test.originalTest = test.test
        test.test = callTestCaseTest

        test.originalTearDown = test.tearDown
        test.tearDown = callTestCaseTearDown
        
        test.name_ = testcase.fileName_ .. "::" .. testcaseName
        test.name = function(self) return self.name_ end
        
        test.isIgnored = function(self) return self.isIgnored_ end
        test.fileName = function(self) return self.fileName_ end
        test.lineNumber = function(self) return self.lineNumber_ end
        
        table.insert(testList, test)
    end
    
    return testList;
end

-------------------------------------------------------
function callTestCaseMethod(testcase, testFunc)
-------------------------------------------------------
    local function callMethod()
        testFunc(testcase);
    end
    
    local function errorHandler(errorMsg)
        local errorObject = {}
        local errorInfo = debug.getinfo(4, "Sln")
        
        errorObject.source = errorInfo.short_src
        --- @todo Sometimes short_src contains info such as '[C]:-1: ' at the begin of line. Need cut it.
        errorObject.func = errorInfo.name
        errorObject.line = errorInfo.currentline

        local isLuaunitAssertFailed = nil ~= string.find(debug.getinfo(3, "S").short_src, 'luaunit.lua')
        if isLuaunitAssertFailed then
            errorObject.message = errorMsg
        else
            errorObject.message = debug.traceback(errorMsg, 3)
        end
        
        return errorObject;
    end
    
    local statusCode, errorObject = xpcall(callMethod, errorHandler);
    return statusCode, errorObject;
end

-------------------------------------------------------
function copyTable(object)
-------------------------------------------------------
    local clone = {};
    for k, v in pairs(object) do
        -- variant of k is table will not handle
        if "table" ~= v then
            clone[k] = v;
        else
            clone[k] = copyTable(v);
        end
    end
    
    local mt = getmetatable(object);
    if mt then
        setmetatable(clone, mt);
    end
    
    return clone;
end

return _M
