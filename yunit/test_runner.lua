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

local function isFunction(variable)
    return "function" == type(variable);
end

------------------------------------------------------
function runTestCase(testcase, testResultHandler)
------------------------------------------------------
    local errorObjectDefault = 
    {
        source = 'unknown',
        func = '',
        line = 0,
        message = '',
    }

    local errorObject
    local testName
    local isTestIgnored
    
    -- Define API, used by 'testcase'
    local testUseApiForVersionLessOrEqual_0_3_7 = (nil ~= testcase.name_) and (nil ~= testcase.isIgnored_) and (nil ~= testcase.lineNumber_) and (nil ~= testcase.fileName_)
    local testUseApiForVersionMoreOrEqual_0_3_8 = isFunction(testcase.name) and isFunction(testcase.isIgnored) and isFunction(testcase.lineNumber) and isFunction(testcase.fileName)
    
    if testUseApiForVersionLessOrEqual_0_3_7 then
        testName = testcase.name_
        isTestIgnored = testcase.isIgnored_
        errorObjectDefault.source = testcase.fileName_
        errorObjectDefault.line = testcase.lineNumber_
    elseif testUseApiForVersionMoreOrEqual_0_3_8 then
        testName = testcase:name() or 'unknown'
        isTestIgnored = testcase:isIgnored() or false
        errorObjectDefault.source = testcase:fileName() or errorObjectDefault.source
        errorObjectDefault.line = testcase:lineNumber() or errorObjectDefault.line
    else
        testName = 'unknown'
        errorObject = errorObjectDefault
        errorObject.message = 'Test has unknown API or has API mixed from different versions'
        
        testResultHandler:onTestBegin(testName)
        testResultHandler:onTestError(testName, errorObject)
        testResultHandler:onTestEnd(testName)
        return
    end
    
    testResultHandler:onTestBegin(testName)

    if isTestIgnored then
        testResultHandler:onTestIgnore(testName, errorObjectDefault)    
    else
        local setUpSuccess
        if testcase.setUp and isFunction(testcase.setUp) then
            setUpSuccess, errorObject = testcase:setUp();
        else
            -- testcase may has not 'setUp' method, but must be run
            setUpSuccess, errorObject = true, errorObjectDefault
        end

        if not setUpSuccess then
            errorObject.func = 'setUp'
            testResultHandler:onTestError(testName, errorObject or errorObjectDefault);
        else
            local testSuccess
            if testcase.setUp and isFunction(testcase.setUp) then
                testSuccess, errorObject = testcase:test()
            else
                testSuccess, errorObject = false, errorObjectDefault
                errorObject.message = 'Test has not "test" method'
            end

            if not testSuccess then
                errorObject.func = ''
                testResultHandler:onTestFailure(testName, errorObject or errorObjectDefault);
            else
                testResultHandler:onTestSuccessfull(testName);
            end

            local tearDownSuccess
            if testcase.tearDown and isFunction(testcase.tearDown) then
                tearDownSuccess, errorObject = testcase:tearDown();
            else
            -- testcase may has not 'tearDown' method, but must be run
                tearDownSuccess, errorObject = true, errorObjectDefault;
            end

            if not tearDownSuccess then
                errorObject.func = 'tearDown'
                testResultHandler:onTestError(testName, errorObject or errorObjectDefault);
            end
        end
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
        else
            io.stdout:write('Test container "' .. filePath .. '" has been loaded\n');
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
    local filename1 = isFunction(test1.fileName) and test1:fileName() or test1.fileName_
    local filename2 = isFunction(test2.fileName) and test2:fileName() or test2.fileName_
    local lineNumber1 = isFunction(test1.lineNumber) and test1:lineNumber() or test1.lineNumber_
    local lineNumber2 = isFunction(test2.lineNumber) and test2:lineNumber() or test2.lineNumber_
	return filename1 < filename2 or (filename1 == filename2 and lineNumber1 < lineNumber2)
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
