local _G = _G
local fs = require('yunit.filesystem')

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
    table.insert(self.testResultHandlers, handler)
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
function normalizeTestCaseInterface(test)
------------------------------------------------------
    if not isFunction(test.name) then
        test.name = 
            function(self)
                return self.name_ or 'unknown'
            end
    else

    end

    if not isFunction(test.isIgnored) then
        test.isIgnored = 
            function(self)
                return self.isIgnored_ or false
            end
    end

    if not isFunction(test.fileName) then
        test.fileName = 
            function(self)
                return self.fileName_ or 'unknown'
            end
    end

    if not isFunction(test.lineNumber) then
        test.lineNumber = 
            function(self)
                return self.lineNumber_ or 0
            end
    end
end

------------------------------------------------------
function operatorLess(test1, test2)
------------------------------------------------------
    local filename1, filename2 = test1:fileName(), test2:fileName()

	return filename1 < filename2 or (filename1 == filename2 and test1:lineNumber() < test2:lineNumber())
end

------------------------------------------------------
function runTestCase(testcase, testResultHandler)
------------------------------------------------------
    local errorObjectDefault = 
    {
        source = testcase:fileName() or 'unknown',
        func = '',
        line = testcase:lineNumber() or 0,
        message = '',
    }

    local errorObject = errorObjectDefault
    local testName = testcase:name() or 'unknown'
    local isTestIgnored = testcase:isIgnored() or false
    
    testResultHandler:onTestBegin(testName)

    if isTestIgnored then
        testResultHandler:onTestIgnore(testName, errorObjectDefault)    
    else
        local setUpSuccess
        if isFunction(testcase.setUp) then
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
            if isFunction(testcase.setUp) then
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
            if isFunction(testcase.tearDown) then
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
TestRunner = 
{
    resultHandlers_ = TestResultHandlerList:new(),
    ltues_ = {},
    fileExts_ = {},
    dirs_ = {},
    testcases_ = {},

    new = function(self, o)
        o = o or {
            resultHandlers_ = TestResultHandlerList:new(),
            ltues_ = {},
            fileExts_ = {},
            dirs_ = {},
            testcases_ = {},
        }
        setmetatable(o, self)
        self.__index = self
        return o
    end;
    
    addResultHandler = function(self, handler)
        self.resultHandlers_:addHandler(handler)
    end;
    
    loadLtue = function(self, ltueName)
        if self.ltues_[ltueName] then
            print('Test Unit Engine "' .. ltueName .. '" has been already loaded')
        else
            local ltue, errMsg = require(ltueName)
            
            if ltue and 'table' == type(ltue) then
                self.ltues_[ltueName] = ltue
                
                local exts = ltue.getTestContainerExtensions()
                
                for _, ext in ipairs(exts) do
                    self.fileExts_[ext] = ltue
                end
            else
                error('Could not load Language Test Unit Engine "' .. ltueName .. '": ' .. errMsg)
            end
        end
    end;
    
    lookTestsAt = function(self, dirPath)
        if not dirPath then
            error('invalid argument, directory path expected, but was ' .. type(dirPath))
        end
        table.insert(self.dirs_, dirPath)
    end;
    
    runAll = function(self)
        local function filterTestContainer(path, state)
        -- filter only test container files
            for ext, ltue in pairs(self.fileExts_) do
                if string.find(string.lower(path), string.lower(ext), -string.len(ext), true) then
                    state.ltue_ = ltue
                    return true
                end
            end
            return false
        end
        
        local function loadTestContainer(path, state)
            --- @todo Print number of tests, loaded from concrete test container (maybe use new API function numberOfTests of cppunit and luaunit
            -- ask LTUE to load found test container file
            local res, errMsg = state.ltue_.loadTestContainer(path);

            if not res then
                if errMsg then 
                    error('Could not load test container "' .. path .. '": \n\t"' .. errMsg .. '"')
                else
                    error('Could not load test container "' .. path .. '": There are not Test Unit Engine, support such test container')
                end
            else
                print('Test container "' .. path .. '" has been loaded');
            end
        end
        -- looking for and load test containers into self.dirs_
        for _, dirPath in ipairs(self.dirs_) do
            fs.applyOnFiles(dirPath, {
                filter = fs.multiFilter,
                handler = loadTestContainer,
                recursive = true,
                state = {filters = {fs.fileFilter, filterTestContainer},},
            })
        end
        -- get loaded unit tests
        for name, ltue in pairs(self.ltues_) do
            --- @todo rename 'getTestList' to 'getTests'
            local tests = ltue.getTestList()
            for _, test in pairs(tests) do
                normalizeTestCaseInterface(test)
                table.insert(self.testcases_, test)
            end
        end
        -- sort and run all tests
        table.sort(self.testcases_, operatorLess)
        
        self.resultHandlers_:onTestsBegin()
        for _, test in ipairs(self.testcases_) do
            runTestCase(test, self.resultHandlers_)
        end
        self.resultHandlers_:onTestsEnd()
    end;
}

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
                error('Cannot load "' .. tueName .. '" test container')
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
    local res, errMsg
    for _, filePath in ipairs(filePathList) do
        res = false
        errMsg = nil
        
        for ext, tue in pairs(GlobalTestUnitEngineList) do
            if string.find(string.lower(filePath), string.lower(ext), -string.len(ext), true) then
                res, errMsg = tue.loadTestContainer(filePath);
                break;
            end
        end
        if not res and errMsg then
            io.stderr:write('Could not load test container "' .. filePath .. '". Error: \n\t"' .. errMsg .. '"\n')
        elseif not res then
            io.stderr:write('Could not load test container "' .. filePath .. '". Error: \n\t"There are not Test Unit Engine, support such test container"\n');
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

function runAllTestCases(testResultHandler)
    testResultHandler = testResultHandler or TestResultHandlerList;

    for _, test in ipairs(GlobalTestCaseList) do
        normalizeTestCaseInterface(test)
    end
    
	table.sort(GlobalTestCaseList, operatorLess)
    
    testResultHandler:onTestsBegin();
    for _, test in ipairs(GlobalTestCaseList) do
        runTestCase(test, testResultHandler);
    end
    testResultHandler:onTestsEnd();
end
