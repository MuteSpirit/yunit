local _G = _G

--------------------------------------------------------------------------------------------------------------
module(...)
_G.setmetatable(_M, {__index = _G})
--------------------------------------------------------------------------------------------------------------

TestResultHandler = {
    onTestSuccessfull = function(testCaseName) end;
    onTestFailure = function(testCaseName, errorObject) end;
    onTestError = function(testCaseName, errorObject) end;
    onTestIgnore = function(testCaseName, errorObject) end;
    onTestBegin = function(testCaseName) end;
    onTestEnd = function(testCaseName) end;
    onTestsBegin = function() end;
    onTestsEnd = function() end;
    outputMessage = function(message) end;
};

function TestResultHandler:new(o)
    o = o or {};
    setmetatable(o, self);
    self.__index = self;
    return o;
end

------------------------------------------------------
TestResultHandlerList = TestResultHandler:new{
    testResultHandlers = {}
};
------------------------------------------------------

function TestResultHandlerList:new(o)
    o = o or {testResultHandlers = {}};
    setmetatable(o, self);
    self.__index = self;
    return o;
end

function TestResultHandlerList:addHandler(handler)
    self.testResultHandlers[#self.testResultHandlers + 1] = handler;
end

function TestResultHandlerList:callHandlersMethod(functionName, ...)
    for _, handler in ipairs(self.testResultHandlers) do
        handler[functionName](handler, ...);
    end
end

function TestResultHandlerList:onTestSuccessfull(testCaseName)
    self:callHandlersMethod('onTestSuccessfull', testCaseName);
end

function TestResultHandlerList:onTestFailure(testCaseName, errorObject)
    self:callHandlersMethod('onTestFailure', testCaseName, errorObject);
end

function TestResultHandlerList:onTestError(testCaseName, errorObject)
    self:callHandlersMethod('onTestError', testCaseName, errorObject);
end

function TestResultHandlerList:onTestIgnore(testCaseName, errorObject)
    self:callHandlersMethod('onTestIgnore', testCaseName, errorObject);
end

function TestResultHandlerList:onTestBegin(testCaseName)
    self:callHandlersMethod('onTestBegin', testCaseName);
end

function TestResultHandlerList:onTestEnd(testCaseName)
    self:callHandlersMethod('onTestEnd', testCaseName);
end

function TestResultHandlerList:onTestsBegin()
    self:callHandlersMethod('onTestsBegin');
end

function TestResultHandlerList:onTestsEnd()
    self:callHandlersMethod('onTestsEnd');
end

------------------------------------------------------
function runTestCase(testcase, testResultHandler)
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

    testResultHandler:onTestBegin(testName);

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
                testResultHandler:onTestFailure(testName, errorObject or errorObjectDefault);
            else
                testResultHandler:onTestSuccessfull(testName);
            end

            if testcase.tearDown and isFunction(testcase.tearDown) then
                status, errorObject = testcase:tearDown();
            else
                status, errorObject = true, errorObjectDefault;
            end

            if not status then -- if tearDown failed
                errorObject.func = 'tearDown'
                testResultHandler:onTestError(testName, errorObject or errorObjectDefault);
            end
        else -- if setUp failed
            errorObject.func = 'setUp'
            testResultHandler:onTestError(testName, errorObject or errorObjectDefault);
        end
    else
        errorObject.line = testcase.lineNumber_
        errorObject.source = testcase.fileName_
        testResultHandler:onTestIgnore(testName, errorObject);
    end

    testResultHandler:onTestEnd(testName);
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
                break;
            end
        end
        if not res and errMsg then
            io.stderr:write('Can\'t load test container "' .. filePath .. '". Error: "' .. errMsg .. '"\n');
        elseif not res then
            io.stderr:write('Can\'t load test container "' .. filePath .. '". Error: "There are not Test Unit Engine, support such test container"\n');
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

function operatorLess(test1, test2)
	return test1.fileName_ < test2.fileName_ or (test1.fileName_ == test2.fileName_ and test1.lineNumber_ < test2.lineNumber_)
end

function runAllTestCases(testResultHandler)
    testResultHandler = testResultHandler or TestResultHandlerList;

	table.sort(GlobalTestCaseList, operatorLess)
    
    testResultHandler:onTestsBegin();
    for _, test in ipairs(GlobalTestCaseList) do
        runTestCase(test, testResultHandler);
    end
    testResultHandler:onTestsEnd();
end
