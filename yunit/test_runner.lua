local _M = {}
local _Mmt = {__index = _G}
setmetatable(_M, _Mmt)
local _G = _M

local fs = require "yunit.filesystem"
local ytrace = require "yunit.trace"
local mine = require "yunit.mine"

TestResultHandler = 
{
    onTestSuccessfull = function(testCaseName) end;
    onTestFailure = function(testCaseName, errorObject) end;
    onTestError = function(testCaseName, errorObject) end;
    onTestIgnore = function(testCaseName, errorObject) end;
    onTestBegin = function(testCaseName) end;
    onTestEnd = function(testCaseName) end;
    onTestsBegin = function() end;
    onTestsEnd = function() end;
    outputMessage = function(message) end;

    new = function(self, o)
        o = o or {};
        setmetatable(o, self);
        self.__index = self;
        return o;
    end;
}

------------------------------------------------------
TestResultHandlerList = TestResultHandler:new{
    new = function(self, o)
        o = o or {
            testResultHandlers = {}
        };
        setmetatable(o, self);
        self.__index = self;
        return o;
    end;

    addHandler = function(self, handler)
        table.insert(self.testResultHandlers, handler)
    end;

    callHandlersMethod = function(self, functionName, ...)
        for _, handler in ipairs(self.testResultHandlers) do
            handler[functionName](handler, ...);
        end
    end;

    onTestSuccessfull = function(self, testCaseName)
        self:callHandlersMethod('onTestSuccessfull', testCaseName);
    end;

    onTestFailure = function(self, testCaseName, errorObject)
        self:callHandlersMethod('onTestFailure', testCaseName, errorObject);
    end;

    onTestError = function(self, testCaseName, errorObject)
        self:callHandlersMethod('onTestError', testCaseName, errorObject);
    end;

    onTestIgnore = function(self, testCaseName, errorObject)
        self:callHandlersMethod('onTestIgnore', testCaseName, errorObject);
    end;

    onTestBegin = function(self, testCaseName)
        self:callHandlersMethod('onTestBegin', testCaseName);
    end;

    onTestEnd = function(self, testCaseName)
        self:callHandlersMethod('onTestEnd', testCaseName);
    end;

    onTestsBegin = function(self)
        self:callHandlersMethod('onTestsBegin');
    end;

    onTestsEnd = function(self)
        self:callHandlersMethod('onTestsEnd');
    end;
}

------------------------------------------------------
LoadTestContainerHandler = 
{
--- @todo remove onLoadBegin method 
    onLoadBegin =       function(self, info) end; -- usual 'info' is {path = testContainerPath}
    onLtueNotFound =    function(self, info) end; -- usual 'info' is {path = testContainerPath}
    onLtueFound =       function(self, info) end; -- usual 'info' is {path = testContainerPath, ltue = ltue}
    onLoadSuccess =     function(self, info) end; -- usual 'info' is {path = testContainerPath, numOfTests = #tests}
    onLoadError =       function(self, info) end; -- usual 'info' is {path = testContainerPath, message}
    onLoadEnd =         function(self) end;

    new = function(self)
        local o = {};
        setmetatable(o, self);
        self.__index = self;
        return o;
    end;
}

LoadTestContainerHandlerList = 
{
    new = function(self)
        local o = {
            handlers_ = {}
        };
        setmetatable(o, self);
        self.__index = self;
        return o;
    end;
    
    add = function(self, handler)
        table.insert(self.handlers_, handler)
    end;

    callHandlersMethod = function(self, functionName, ...)
        for _, handler in ipairs(self.handlers_) do
            handler[functionName](handler, ...);
        end
    end;

    onLoadBegin =    function(self, info) self:callHandlersMethod('onLoadBegin', info) end;
    onLtueNotFound = function(self, info) self:callHandlersMethod('onLtueNotFound', info) end;
    onLtueFound =    function(self, info) self:callHandlersMethod('onLtueFound', info) end;
    onLoadSuccess =  function(self, info) self:callHandlersMethod('onLoadSuccess', info) end;
    onLoadError =    function(self, info) self:callHandlersMethod('onLoadError', info) end;
    onLoadEnd =      function(self, info) self:callHandlersMethod('onLoadEnd', info) end;
}
------------------------------------------------------

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

    local oneTestExecutionTimeLimitInSec = 7
    mine.setTimer(oneTestExecutionTimeLimitInSec)
    
    if isTestIgnored then
        testResultHandler:onTestIgnore(testName, errorObjectDefault)    
    else
        local setUpSuccess
        if isFunction(testcase.setUp) then
            setUpSuccess, errorObject = testcase:setUp()
        else
            -- testcase may has not 'setUp' method, but must be run
            setUpSuccess, errorObject = true, errorObjectDefault
        end

        if not setUpSuccess then
            errorObject = errorObject or errorObjectDefault
            errorObject.func = 'setUp'
            testResultHandler:onTestError(testName, errorObject);
        else
            local testSuccess
            if isFunction(testcase.test) then
                testSuccess, errorObject = testcase:test()
            else
                testSuccess, errorObject = false, errorObjectDefault
                errorObject.message = 'Test has not "test" method'
            end

            if not testSuccess then
                errorObject = errorObject or errorObjectDefault
                errorObject.func = ''
                testResultHandler:onTestFailure(testName, errorObject);
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
                errorObject = errorObject or errorObjectDefault
                errorObject.func = 'tearDown'
                testResultHandler:onTestError(testName, errorObject);
            end
        end
    end
    
    mine.turnoff()

    testResultHandler:onTestEnd(testName);
end

------------------------------------------------------
TestRunner = 
{
    new = function(self, o)
        o = o or {
            resultHandlers_ = TestResultHandlerList:new(),
            loadHandlers_ = LoadTestContainerHandlerList:new(),
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

    addLoadtHandler = function(self, handler)
        self.loadHandlers_:add(handler)
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
    
    findLtueForTestContainer = function(self, path)
        for ext, ltue in pairs(self.fileExts_) do
            if string.find(string.lower(path), string.lower(ext), -string.len(ext), true) then
                return ltue
            end
        end
        return nil
    end;
    
    runTestsOfTestContainer = function(self, path)
        path = fs.absPath(path)
        self.loadHandlers_:onLoadBegin{path = path}

        local ltue = self:findLtueForTestContainer(path)
        if not ltue then
            self.loadHandlers_:onLtueNotFound{path = path}
            return
        end
        self.loadHandlers_:onLtueFound{path = path, ltue = ltue}
        
        local testContainerDir = fs.dirname(path)
        -- We change current directory, because
        -- 1. we may load DLL, which are depend on other DLLs, situated in test container folder
        -- 2. we may load test containers, which do some initial code on loading and assume, 
        --    that working directory is test container folder
        lfs.chdir(testContainerDir)

        -- sometimes LTUE cannot load test container (they contain syntax errors, crashed during initializing and so on)
        -- so we must protect than procedure call.
        -- we use code, compatible with Lua 5.1 and Lua 5.2 to decrease number of testable configuration
        local function callLoadTestContainer()
            return ltue.loadTestContainer(path)
        end
        local xpcallRes, callRes, errMsg = xpcall(callLoadTestContainer, ytrace.traceback)
        
        if not xpcallRes then
            local stackTraceback = callRes
            self.loadHandlers_:onLoadError{path = path, message = stackTraceback.error.message}
            return
        end
        
        if not callRes or 'boolean' == type(callRes) then
            self.loadHandlers_:onLoadError{path = path, message = errMsg}
            return
        end
 
        local tests = callRes           
        self.loadHandlers_:onLoadSuccess{path = path, numOfTests = #tests}
                        
        for _, test in ipairs(tests) do
            normalizeTestCaseInterface(test)
        end
        -- we have to call table.sort after normalize tests interface, 
        -- because 'operatorLess' require concrete interface of TestCase objects
        table.sort(tests, operatorLess)
        
        -- We change current directory, because
        -- during test execution they usually assume, that working directory is test container folder
        lfs.chdir(testContainerDir)
        
        for _, test in ipairs(tests) do
            runTestCase(test, self.resultHandlers_)
        end
    end;

    runTestsOf = function(self, testContainerPath)
        local previousWorkingDir = lfs.currentdir()

        self.resultHandlers_:onTestsBegin()
        self:runTestsOfTestContainer(testContainerPath)
        self.resultHandlers_:onTestsEnd()
        self.loadHandlers_:onLoadEnd()

        lfs.chdir(previousWorkingDir)
    end;
    
    runAll = function(self)
        local function filterTestContainer(path, state)
            return nil ~= self:findLtueForTestContainer(path)
        end
        local function loadAndRunTests(testContainerPath, state)
            self:runTestsOfTestContainer(testContainerPath)
        end

        local previousWorkingDir = lfs.currentdir()

        self.resultHandlers_:onTestsBegin()
        
        for _, dirPath in ipairs(self.dirs_) do
            fs.applyOnFiles(dirPath, 
                    {
                        filter = fs.multiFilter,
                        handler = loadAndRunTests,
                        recursive = true,
                        state = { filters = {fs.fileFilter, filterTestContainer},},
                    }
                )
        end
        
        self.resultHandlers_:onTestsEnd()
        self.loadHandlers_:onLoadEnd()

        lfs.chdir(previousWorkingDir)
    end;
}

return _M
