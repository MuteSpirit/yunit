local _G = _G

--------------------------------------------------------------------------------------------------------------
module(...)
_G.setmetatable(_M, {__index = _G})
--------------------------------------------------------------------------------------------------------------

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

    local function isFunction(variable)
        return "function" == type(variable);
    end

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
--------------------------------------------------------------------
GlobalTestUnitEngineList = {}
--------------------------------------------------------------------

function loadTestUnitEngines(tueList)
    for _, tueName in ipairs(tueList) do
        if not package.loaded[tueName] then
            local tue, errMsg = require(tueName);
            
            if 'boolean' == type(tue) then
                io.stderr:write(tue .. '\t' .. errMsg);
            elseif tue and 'table' == type(tue) then
                local tcExtList = tue.getTestContainerExtensions();
                
                for _, ext in ipairs(tcExtList) do
                    GlobalTestUnitEngineList[ext] = tue; 
                end
            end
        end
    end
end

function loadTestContainers(filePathList)
    -- load test containers into test case lists inside Test Unit Engines
    for _, filePath in ipairs(filePathList) do
        local res, errMsg;
        for ext, tue in pairs(GlobalTestUnitEngineList) do
            if string.find(filePath, ext, -string.len(ext), true) then
                res, errMsg = tue.loadTestContainer(filePath);
                if not res then
                    io.stderr:write('Can\'t load test container "' .. filePath .. '". Error: "' .. errMsg .. '"\n');
                end
            end
        end
    end

    -- get from Test Unit Engines Test Case objects lists and copy them into GlobalTestUnitEngineList
    for _, tue in pairs(GlobalTestUnitEngineList) do    
        local testcases = tue.getTestList();
        
        for _, testcase in ipairs(testcases) do
            table.insert(GlobalTestCaseList, testcase);
        end
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
