local _G = _G

--------------------------------------------------------------------------------------------------------------
module(...)
_G.setmetatable(_M, {__index = _G})
--------------------------------------------------------------------------------------------------------------

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

function fakeFunction()
end

------------------------------------------------------
TestListener = {
    addSuccessful = function(testCaseName) end;
    addFailure = function(testCaseName, errorObject) end;
    addError = function(testCaseName, errorObject) end;
    addIgnore = function(testCaseName, errorObject) end;
    startTest = function(testCaseName) end;
    endTest = function(testCaseName) end;
    startTests = function() end;
    endTests = function() end;
    outputMessage = function(message) end;
};

function TestListener:new(o)
    o = o or {};
    setmetatable(o, self);
    self.__index = self;
    return o;
end

------------------------------------------------------
TestObserver = 
{
    testListeners = {}
};
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
    self:callListenersFunction('addSuccessful', testCaseName);
end

function TestObserver:addFailure(testCaseName, errorObject)
    self:callListenersFunction('addFailure', testCaseName, errorObject);
end

function TestObserver:addError(testCaseName, errorObject)
    self:callListenersFunction('addError', testCaseName, errorObject);
end

function TestObserver:addIgnore(testCaseName, errorObject)
    self:callListenersFunction('addIgnore', testCaseName, errorObject);
end

function TestObserver:startTest(testCaseName)
    self:callListenersFunction('startTest', testCaseName);
end

function TestObserver:endTest(testCaseName)
    self:callListenersFunction('endTest', testCaseName);
end

function TestObserver:startTests()
    self:callListenersFunction('startTests');
end

function TestObserver:endTests()
    self:callListenersFunction('endTests');
end

------------------------------------------------------
function runTestCase(testcase, testResult)
------------------------------------------------------
    local errorObjectDefault =
    {
        source = "";
        func = "";
        line = 0;
        message = "";
    };
    local status, errorObject = true, errorObjectDefault;
    local testName = testcase.name_ or 'unknownTestCase';

    testResult:startTest(testName);

    if not testcase.isIgnored_ then
        if testcase.setUp and isFunction(testcase.setUp) then
            status, errorObject = testcase:setUp();
        else
            status, errorObject = true, errorObjectDefault;
        end

        if status then
            -- testcase object must have test()
            status, errorObject = testcase:test();

            if not status then
                errorObject.func = ''
                testResult:addFailure(testName, errorObject or errorObjectDefault);
            else
                testResult:addSuccessful(testName);
            end

            if testcase.tearDown and isFunction(testcase.tearDown) then
                status, errorObject = testcase:tearDown();
            else
                status, errorObject = true, errorObjectDefault;
            end

            if not status then -- if tearDown failed
                errorObject.func = 'tearDown'
                testResult:addError(testName, errorObject or errorObjectDefault);
            end
        else -- if setUp failed
            errorObject.func = 'setUp'
            testResult:addError(testName, errorObject or errorObjectDefault);
        end
    else
        errorObject.line = testcase.lineNumber_
        errorObject.source = testcase.fileName_
        testResult:addIgnore(testName, errorObject);
    end

    testResult:endTest(testName);
end

------------------------------------------------------
GlobalTestCaseList = {};

------------------------------------------------------
function isWin()
    local envVar = os.getenv('WINDIR') or os.getenv('HOME') or os.getenv('PWD');
    return nil ~= string.match(envVar, '^%w:');
end

function isUnix()
    local envVar = os.getenv('WINDIR') or os.getenv('HOME') or os.getenv('PWD');
    return nil ~= string.match(envVar, '^/');
end

function loadLuaContainer(filePath)
    local sourceCode;
    
    local hFile, errMsg = io.open(filePath, 'r');
    if not hFile then
        return hFile, errMsg;
    end
    sourceCode = hFile:read('*a');
    hFile:close();
    
--~     local filenameWithExt = string.match(filePath, '[^/\\]+$');
    local res, msg = luaUnit.loadTestChunk(sourceCode, filePath);
    if not res then
        return res, msg;
    end
    
    return true;
end

function loadCppContainer(filePath)
    -- we must only load library to current process for initialization global objects and
    -- filling test register
    package.loadlib(filePath, "");
end

function isLuaTestContainer(filePath)
    return nil ~= string.find(filePath, "%.t%.lua$")
end

function isCppTestContainer(filePath)
    if isWin() then
        return nil ~= string.find(filePath, "%.t%.dll$");
    elseif isUnix() then
        return nil ~= string.find(filePath, "%.t%.so$");
    end
end

function initializeTestUnits()
    if not package.loaded["testunit.luaunit"] then
        luaUnit = require("testunit.luaunit");
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

function loadTestContainers(filePathList)
    initializeTestUnits();
    local luaTestsArePresent, cppTestsArePresent = false, false;

    for _, filePath in ipairs(filePathList) do
        if isLuaTestContainer(filePath) then
            loadLuaContainer(filePath);
            luaTestsArePresent = true;
        elseif isCppTestContainer(filePath) then
            loadCppContainer(filePath);
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
function copyAllLuaTestCasesToGlobalTestList()
    local luaUnit = require("testunit.luaunit");
    local testcases = luaUnit.getTestList();
    for _, testcase in ipairs(testcases) do
        table.insert(GlobalTestCaseList, testcase);
    end
end

function copyAllCppTestCasesToGlobalTestList()
    local cppUnit = require("cppunit");
    local testcases = cppUnit.getTestList();
    for _, testcase in ipairs(testcases) do
        table.insert(GlobalTestCaseList, testcase);
    end
end

function runAllTestCases(testResult)
    testResult = testResult or TestObserver;
    
    testResult:startTests();
    for _, test in ipairs(GlobalTestCaseList) do
        runTestCase(test, testResult);
    end
    testResult:endTests();
end
