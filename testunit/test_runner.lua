-- Global function
-- ! They must be moved to some dependence package

------------------------------------------------------
local function isFunction(variable)
------------------------------------------------------
    return "function" == type(variable);
end

------------------------------------------------------
local function isString(variable)
------------------------------------------------------
    return "string" == type(variable);
end

------------------------------------------------------
local function isTable(variable)
------------------------------------------------------
    return "table" == type(variable);
end


local setmetatable, ipairs, tostring, pcall, require, dofile = setmetatable, ipairs, tostring, pcall, require, dofile;
local debug_traceback = debug.traceback;
local table, io, string, package, os = table, io, string, package, os;

-- for debug
local print = print;

--------------------------------------------------------------------------------------------------------------
module('afl.test_runner');
--------------------------------------------------------------------------------------------------------------

function fakeFunction()
end

------------------------------------------------------
TestListener = {};
------------------------------------------------------

function TestListener:new(o)
    o = o or {};
    setmetatable(o, self);
    self.__index = self;
    return o;
end

-- ??? Why succefsul or other test result doesn't indicate the end of tests
function TestListener:addSuccessful(testCaseName)
end

function TestListener:addFailure(testCaseName, errorObject)
end

function TestListener:addError(testCaseName, errorObject)
end

function TestListener:addIgnore(testCaseName, errorObject)
end

function TestListener:startTest(testCaseName)
end

function TestListener:endTest(testCaseName)
end

function TestListener:startTests()
end

function TestListener:endTests()
end

function TestListener:outputMessage(message)
end


------------------------------------------------------
TestObserver = {testListeners = {}};
------------------------------------------------------

function TestObserver:new(o)
    o = o or {testListeners = {}};
    setmetatable(o, self);
    self.__index = self;
    return o;
end

function TestObserver:addTestListener(listener)
    self.testListeners[#self.testListeners + 1] = listener;
end

function TestObserver:callListenersFunction(functionName, ...)
    for _, listener in ipairs(self.testListeners) do
        listener[functionName](listener, ...);
    end
end

function TestObserver:addSuccessful(testCaseName)
    self:callListenersFunction("addSuccessful", testCaseName);
end

function TestObserver:addFailure(testCaseName, errorObject)
    self:callListenersFunction("addFailure", testCaseName, errorObject);
end

function TestObserver:addError(testCaseName, errorObject)
    self:callListenersFunction("addError", testCaseName, errorObject);
end

function TestObserver:addIgnore(testCaseName)
    self:callListenersFunction("addIgnore", testCaseName);
end

function TestObserver:startTest(testCaseName)
    self:callListenersFunction("startTest", testCaseName);
end

function TestObserver:endTest(testCaseName)
    self:callListenersFunction("endTest", testCaseName);
end

function TestObserver:startTests()
    self:callListenersFunction("startTests");
end

function TestObserver:endTests()
    self:callListenersFunction("endTests");
end

------------------------------------------------------
function isTestFunction(functionName)
------------------------------------------------------
    local exception = {"TEST_FIXTURE", "TEST_SUITE", "TEST_CASE", "TEST_CASE_EX", };
    for _, v in ipairs(exception) do
        if v == functionName then
            return false;
        end
    end
    functionName = string.lower(functionName);
    if string.find(functionName, "^test") or string.find(functionName, "test$") then
        return true;
    end
    return false;
end

------------------------------------------------------
function runTestCase(testCaseName, testcase, testResult)
------------------------------------------------------
    local errorObjectDefault =
    {
        source = "";
        func = "";
        line = 0;
        message = "";
    };
    local statusCode, errorObject = true, errorObjectDefault;

    testResult:startTest(testCaseName);

    if not testcase.isIgnored_ then
        if testcase.setUp and isFunction(testcase.setUp) then
            _, statusCode, errorObject = pcall(testcase.setUp, testcase);
        else
            statusCode, errorObject = true, errorObjectDefault;
        end

        if statusCode then
            _, statusCode, errorObject = pcall(testcase.test, testcase);

            if not statusCode then
                testResult:addFailure(testCaseName, errorObject or errorObjectDefault);
            else
                testResult:addSuccessful(testCaseName);
            end

            if testcase.tearDown and isFunction(testcase.tearDown) then
                _, statusCode, errorObject = pcall(testcase.tearDown, testcase);
            else
                statusCode, errorObject = true, errorObjectDefault;
            end

            if not statusCode then
                testResult:addError(testCaseName, errorObject or errorObjectDefault);
            end
        else
            testResult:addError(testCaseName, errorObject or errorObjectDefault);
        end
    else
        testResult:addIgnore(testCaseName);
    end

    testResult:endTest(testCaseName);
end

------------------------------------------------------
GlobalTestCaseList = {};

TestCaseRecord = {};
------------------------------------------------------

function TestCaseRecord:new(name, object)
    local o = {
            ["name_"] = name,
            ["test"] = object,
        };
    setmetatable(o, self);
    self.__index = self;
    return o;
end

function TestCaseRecord:name()
    return self.name;
end

function TestCaseRecord:run(testResult)
    runTestCase(self.name_, self.test, testResult);
end

function isWin()
    local envVar = os.getenv('WINDIR') or os.getenv('HOME') or os.getenv('PWD');
    return nil ~= string.match(envVar, '^%w:');
end

function isUnix()
    local envVar = os.getenv('WINDIR') or os.getenv('HOME') or os.getenv('PWD');
    return nil ~= string.match(envVar, '^/');
end

function loadLuaDriver(filePath)
    dofile(filePath);
end

function loadCppDriver(filePath)
    -- we must only load library to current process for initialization global objects and
    -- filling test register
    package.loadlib(filePath, "");
end

function isLuaTestDriver(filePath)
    return nil ~= string.find(filePath, "%.t%.lua$")
end

function isCppTestDriver(filePath)
    if isWin() then
        return nil ~= string.find(filePath, "%.t%.dll$");
    elseif isUnix() then
        return nil ~= string.find(filePath, "%.t%.so$");
    end
end

function initializeTestUnits()
    if not package.loaded["afl.lua_unit"] then
        luaUnit = require("afl.lua_unit");
    end

    if not package.loaded["cppunit"] then
        if isWin() then
            package.cpath = "../_bin/?.dll;"..package.cpath;
        elseif isUnix() then
            package.cpath = "../_bin/?.so;"..package.cpath;
        end
        cppUnit = require("cppunit");
    end
end

function loadTestDrivers(filePathList)
    initializeTestUnits();
    local luaTestsArePresent, cppTestsArePresent = false, false;

    for _, filePath in ipairs(filePathList) do
        if isLuaTestDriver(filePath) then
            loadLuaDriver(filePath);
            luaTestsArePresent = true;
        elseif isCppTestDriver(filePath) then
            loadCppDriver(filePath);
            cppTestsArePresent = true;
        end
    end

    if luaTestsArePresent then
        copyAllLuaTestCasesToGlobalTestList();
    end

    if cppTestsArePresent then
        copyAllCppTestCasesToGlobalTestList();
    end
end

------------------------------------------------------
local function addTestCaseToGlobalList(name, object)
    table.insert(GlobalTestCaseList, TestCaseRecord:new(name, object));
end

function copyAllLuaTestCasesToGlobalTestList()
    local luaUnit = require("afl.lua_unit");
    local testcases = luaUnit.getTestList();
    for _, testcase in ipairs(testcases) do
        addTestCaseToGlobalList(testcase.name_, testcase);
    end
end

function copyAllCppTestCasesToGlobalTestList()
    local cppUnit = require("cppunit");
    local testcases = cppUnit.getTestList();
    for _, testcase in ipairs(testcases) do
        addTestCaseToGlobalList(testcase.name_, testcase);
    end
end

function runAllTestCases(testObserver)
    testObserver = testObserver or TestObserver;
    testObserver:startTests();
    for _, testRecord in ipairs(GlobalTestCaseList) do
        testRecord:run(testObserver);
    end
    testObserver:endTests();
end
