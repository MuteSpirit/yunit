local table, string = table, string;
local setmetatable = setmetatable;
local getmetatable = getmetatable;
local tostring = tostring;
local error = error;
local type = type;
local ipairs = ipairs;
local pairs = pairs;
local pcall = pcall;
local xpcall = xpcall;
local error = error;
local next = next;
local debug_getinfo = debug.getinfo;

--~ local print = print; -- for debug
local _G = _G;

local luaExt = require('lua_ext');
------------------------------------------------------
--
-- Lua part of common test runner
--
--------------------------------------------------------------------------------------------------------------
module('testunit.luaunit');
--------------------------------------------------------------------------------------------------------------

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

-------------------------------------------------------
TestFuxture = {};
-------------------------------------------------------

function TestFuxture:new(o)
    local obj =  o or {};
    setmetatable(obj, self);
    self.__index = self;
    return obj;
end

function TestFuxture:setUp()
end

function TestFuxture:tearDown()
end

-------------------------------------------------------
TestCase = TestFuxture:new{};
-------------------------------------------------------

function TestCase:new(name)
    local o = 
    {
        name_ = name,
        isIgnored_ = false,
    };
    setmetatable(o, self);
    self.__index = self;
    return o;
end

function TestCase:name()
    return self.name_;
end

function TestCase:test()
end

-------------------------------------------------------
TestSuite = 
{
    testcases = {};
    name_ = "";
};
-------------------------------------------------------

function TestSuite:new(name)
    local o = 
    {
        testcases = {};
        ["name_"] = name or "";
    };
    setmetatable(o, self);
    self.__index = self;
    return o;
end

function TestSuite:addTestCase(testcase)
    table.insert(self.testcases, testcase);
end

function TestSuite:name()
    return self.name_;
end

-------------------------------------------------------
TestRegistry = 
{
    testsuites = {TestSuite:new("Default")};
};
-------------------------------------------------------
function TestRegistry:new()
    local o = 
    {
        testsuites = {TestSuite:new("Default")};
    };
    setmetatable(o, self);
    self.__index = self;
    return o;
end

-------------------------------------------------------
-- current TestRegistry. Possibility to set test registry in unit test, i.e. you may replace singleton object
local curTestRegistry = TestRegistry:new();
-------------------------------------------------------

function currentTestRegistry(value)
    if value then
        curTestRegistry = value;
    else
        return curTestRegistry;
    end
end

function TestRegistry:addTestCase(testcase)
    self.testsuites[1]:addTestCase(testcase);
end

function TestRegistry:addTestSuite(testsuite)
    table.insert(self.testsuites, testsuite);
end

function TestRegistry:reset()
    self.testsuites = {TestSuite:new("Default")};
end

-------------------------------------------------------
function callTestCaseMethod(testcase, testFunc)
-------------------------------------------------------
    local function callMethod()
        testFunc(testcase);
    end
    
    local function errorHandler(errorMsg)
        local errorObject = {};
        local errorInfo = debug_getinfo(4, "Sln");
        
        errorObject.source = errorInfo.short_src;
        -- TODO Sometimes short_src contains info such as '[C]:-1: ' at the begin of line. Need cut it.
        errorObject.func = errorInfo.name;
        errorObject.line = errorInfo.currentline;
        errorObject.message = errorMsg;
        
        return errorObject;
    end
    
    local statusCode, errorObject = xpcall(callMethod, errorHandler);
    return statusCode, errorObject;
end

-------------------------------------------------------
function getTestList()
-------------------------------------------------------
    local function callTestCaseSetUp(testcase)
        return callTestCaseMethod(testcase, testcase.originalSetUp)
    end

    local function callTestCaseTest(testcase)
        return callTestCaseMethod(testcase, testcase.originalTest)
    end

    local function callTestCaseTearDown(testcase)
        return callTestCaseMethod(testcase, testcase.originalTearDown)
    end
    
    local testList = {};
    for _, testsuite in ipairs(curTestRegistry.testsuites) do
        local testsuiteName = testsuite.name_;
        for _, testcase in ipairs(testsuite.testcases) do
            local testcaseName = testcase["name_"];
            local test = copyTable(testcase);
            
            test.originalSetUp = test.setUp;
            test.setUp = callTestCaseSetUp;

            test.originalTest = test.test;
            test.test = callTestCaseTest;

            test.originalTearDown = test.tearDown;
            test.tearDown = callTestCaseTearDown;
            
            test.name_ = testsuiteName.."::"..testcaseName;
            table.insert(testList, test);
        end
    end
    return testList;
end

-------------------------------------------------------
-- Assert macro
-------------------------------------------------------

function ASSERT(assertion)
    if not assertion then
        error("ASSERT: assertion failed", 0);
    end
end

function ASSERT_TRUE(actual)
    local actualtype = type(actual)
    if actualtype ~= "boolean" then
        error("ASSERT_TRUE: true expected but was a "..actualtype, 0)
    end
    if actual ~= true then
        error("ASSERT_TRUE: true expected but was false", 0)
    end
end

function ASSERT_FALSE(actual)
    local actualtype = type(actual)
    if actualtype ~= "boolean" then
        error("ASSERT_FALSE: false expected but was a "..actualtype, 0)
    end
    if actual ~= false then
        error("ASSERT_FALSE: false expected but was true", 0)
    end
end

function ASSERT_THROW(functionForRun, ...)
    local functype = type(functionForRun);
    if functype ~= "function" then
        error(string.format("ASSERT_THROW: expected a function as last argument but was a %s", functype), 0);
    end
    local ok, errmsg = pcall(functionForRun, ...);
    if ok then
        error(string.format("ASSERT_THROW: no error expected but error was: '%s'", errmsg), 0)
    end
end

function ASSERT_NO_THROW(functionForRun, ...)
    local functype = type(functionForRun);
    if functype ~= "function" then
        error(string.format("ASSERT_NO_THROW: expected a function as last argument but was a %s", functype), 0);
    end
    local ok, errmsg = pcall(functionForRun, ...);
    if not ok then
        error("ASSERT_NO_THROW: error expected but it is absent", 0)
    end
end

local function wrapValue(v)
    if "string" == type(v) then
        return "'"..v.."'"
    end
    return tostring(v);
end

function ASSERT_EQUAL(expected, actual)
	if  actual ~= expected  then
		local errorMsg = "\nexpected: "..wrapValue(expected).."\n"..
                         "actual  : "..wrapValue(actual).."\n";
		error(errorMsg, 0);
	end
end

function ASSERT_NOT_EQUAL(expected, actual)
	if  actual == expected  then
		local errorMsg = "\nnot expected: "..wrapValue(expected).."\n"..
                         "actual  : "..wrapValue(actual).."\n";
		error(errorMsg, 0);
	end
end

function ASSERT_MULTIPLE_EQUAL(...)
    local values = {...};
    local valuesSize = table.maxn(values);
    local valuesHalfSize = valuesSize / 2;
    if 0 ~= (valuesSize % 2) then
        error("ASSERT_MULTIPLE_EQUAL: expected even number of arguments for comparison, but was "..valuesSize, 0);
    end
    
    local actual, expected;
    local notEquale = {};
    for i = 1, valuesHalfSize do
        expected, actual = values[i], values[i + valuesHalfSize];
        if actual ~= expected  then
            table.insert(notEquale, {expected, actual});
        end
    end
    
    if next(notEquale) then  -- Equivalent of:  if not table.isEmpty(notEquale) then
        local message = "ASSERT_MULTIPLE_EQUAL: some values are not equal: ";
        for _, v in ipairs(notEquale) do
            actual, expected = v[2], v[1];
            message = message .. expected .. " != " .. actual .. ", ";  -- TODO Sign '!=' is legal for C++, but not for Lua
        end
        error(message, 0);
    end
end

local lineIterRe = '[\r\n]+$';

--------------------------------------------------------------------------------------------------------------
local function lineIterFunc(invState)
--------------------------------------------------------------------------------------------------------------
    if invState.pos > invState.len then
        return nil
    end
    
    local line
    local begPos, endPos = string.find(invState.text, '[^\r\n]*\r*\n', invState.pos)
    -- end of invState.text is reached
    if not begPos then
        begPos, endPos = invState.pos, invState.len
    end
    
    line = string.sub(invState.text, begPos, endPos)
    invState.pos = endPos + 1
    
    return line, endPos
end

--------------------------------------------------------------------------------------------------------------
local function lineIter(text, pos)
--------------------------------------------------------------------------------------------------------------
    return lineIterFunc, {text = text, pos = pos or 0, len = string.len(text)};
end

--------------------------------------------------------------------------------------------------------------
local function textToLines(text)
--------------------------------------------------------------------------------------------------------------
    -- преобразование в текст осуществляется с обрезанием символов перевода каретки и перевода строки
    -- в результате преобразования получается таблица с ключевыми полями - номерами строк, полями значений -
    -- соответствующими строками из исходного текста
    local lines = {};
    local n = 1;
    for line in lineIter(text) do
        lines[n] = string.gsub(line, lineIterRe, '');
        n = n + 1;
    end
    return lines;
end

function ASSERT_STRING_EQUAL(expected, actual)
    local expectedType = type(expected);
    if 'string' ~= expectedType then
        error("ASSERT_STRING_EQUAL: 'expected' must have 'string' type, but was '"..expectedType.."'", 0);
    end
    local actualType = type(actual);
    if 'string' ~= actualType then
        error("ASSERT_STRING_EQUAL: 'actual' must have 'string' type, but was '"..actualType.."'", 0);
    end
    if expected == actual then 
        return;
    end
    
    local expectedLines = textToLines(expected);
    local expectedNumLines = table.maxn(expectedLines);
    
    local actualLines = textToLines(actual);
    local actualNumLines = table.maxn(actualLines);
    
    local messageLines = {};
    
    table.insert(messageLines, 'ASSERT_STRING_EQUAL: some parts of strings are not equal, for example, \n');
    
    if expectedNumLines == actualNumLines then
    -- show differences one to one for lines
        
        for i = 1, expectedNumLines do
            local linExp, lineAct = expectedLines[i], actualLines[i];
            if not string.find(linExp, lineAct, 1, true) then
                table.insert(messageLines, 'line '..tostring(i)..' of '..expectedNumLines..':\n"'..linExp..'"\n"'..lineAct..'"\n\n');
            end
        end
    else -- show only first pair of difference lines 
        for i = 1, expectedNumLines do
            local linExp, lineAct = expectedLines[i], actualLines[i];
            if not string.find(linExp, lineAct, 1, true) then
                table.insert(messageLines, 'line '..tostring(i)..' of '..expectedNumLines..':\n"'..linExp..'"\n"'..lineAct..'"\n');
                break;
            end
        end
        table.insert(messageLines, '...\nString may have other changes, because they have different number of lines\n');
    end
    
    error(table.concat(messageLines), 0);
end

local typenames = { "nil", "boolean", "number", "string", "table", "function", "thread", "userdata" }

-- ASSERT_TYPENAME functions
for _, typename in ipairs(typenames) do
    local assertTypename = "ASSERT_IS_"..string.upper(typename);
    _M[assertTypename] = function(actual)
        local actualType = type(actual);
        if actualType ~= typename then
          error( assertTypename .. ": " .. typename.." expected but was a " .. actualType, 0)
        end
    end
end

-- ASSERT_NOT_TYPENAME functions
for _, typename in ipairs(typenames) do
    local assertTypename = "ASSERT_IS_NOT_"..string.upper(typename);
    _M[assertTypename] = function(actual)
        local actualType = type(actual);
        if actualType == typename then
          error(assertTypename .. ": " .. typename.." not expected but was one", 0);
        end
    end
end

-------------------------------------------------------
-- Macro for test writing
-------------------------------------------------------

-- last created TestSuite. It used for correct adding TestCase objects to corresponding TestSuite
local curSuite;

function currentSuite(value)
    if value then
        curSuite = value;
    else
        return curSuite;
    end
end

-------------------------------------------------------
function TEST_FIXTURE(name)
-------------------------------------------------------
    return function(fixtureObject)
        _G[name] = TestFuxture:new(fixtureObject);
    end
end

-------------------------------------------------------
function TEST_SUITE(name)
-------------------------------------------------------
    local testsuite = TestSuite:new(name)
    curTestRegistry:addTestSuite(testsuite);
    curSuite = testsuite;   -- curSuite is needed for knoledge of testcases about current TestSuite
    return function() end
end

-------------------------------------------------------
function TEST_CASE(funcArg)
-------------------------------------------------------
    local name = funcArg[1];
    local testcaseFunc = funcArg[#funcArg];
    
    local testcase = TestCase:new(name);
    testcase.test = testcaseFunc;
    
    curSuite:addTestCase(testcase);
    return nil;
end


local function search(k, plist)
    for _, parent in ipairs(plist) do
        local v = parent[k];
        if v then return v end
    end
    return nil;
end

-------------------------------------------------------
function TEST_CASE_EX(args)
-------------------------------------------------------
    local name = args[1];
    local testcaseFunc = args[#args];
    
    local testcase = TestCase:new(name);
    testcase.test = testcaseFunc;
    
    curSuite:addTestCase(testcase);
    
    local parents = {};
    for i = 2, #args - 1 do
        local fixtureName = args[i];
        if "string" == type(fixtureName) and _G[fixtureName] then
            table.insert(parents, _G[fixtureName]);
        end
    end
    table.insert(parents, TestCase);
    
    setmetatable(testcase, {__index = function(t, k)
        return search(k, parents)
    end});
    
    testcase.__index = testcase;
    
    return nil;
end

-------------------------------------------------------
function testmodule(moduleTable)
-------------------------------------------------------
    if "table" == type(moduleTable) and "string" == type(moduleTable._NAME) then
        moduleTable.TEST_SUITE = TEST_SUITE;
        moduleTable.TEST_CASE = TEST_CASE;
        moduleTable.TEST_CASE_EX = TEST_CASE_EX;
        moduleTable.TEST_FIXTURE = TEST_FIXTURE;
        moduleTable.ASSERT = ASSERT;

        -- set functions with name ASSERT_*
        for k, v in pairs(_M) do
            if "string" == type(k) and 
               string.find(k, "ASSERT_") and "function" == type(v) then
                moduleTable[k] = v;
            end
        end
    end
end
