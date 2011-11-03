local _M = {}
local _Mmt = {__index = _G}
setmetatable(_M, _Mmt)
local _G = _M

local fs = require "yunit.filesystem"

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

    new = function(self, o)
        o = o or {};
        setmetatable(o, self);
        self.__index = self;
        return o;
    end;
}

------------------------------------------------------
TestResultHandlerList = TestResultHandler:new{
    testResultHandlers = {};

    new = function(self, o)
        o = o or {testResultHandlers = {}};
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
        local function findOutTestContainer(path, state)
            for ext, ltue in pairs(self.fileExts_) do
                if string.find(string.lower(path), string.lower(ext), -string.len(ext), true) then
                    state.ltue_ = ltue
                    return true
                end
            end
            return false
        end
        
        local function loadAndRunTests(testContainerPath, state)
            local tests, errMsg = state.ltue_.loadTestContainer(testContainerPath);

            if 'boolean' == type(tests) then
                table.insert(state.notLoadedTestContainers, {path = testContainerPath, msg = errMsg})
                return
            end
                
            table.insert(state.loadedTestContainers, {path = testContainerPath, testNum = #tests})
                            
            for _, test in ipairs(tests) do
                normalizeTestCaseInterface(test)
            end
            -- we have to call table.sort after normalize tests interface, 
            -- because 'operatorLess' require concrete interface
            table.sort(tests, operatorLess)
            
            lfs.chdir(fs.dirname(testContainerPath))
            
            for _, test in ipairs(tests) do
                runTestCase(test, self.resultHandlers_)
            end
        end
        
        self.resultHandlers_:onTestsBegin()
        
        local savedWorkingDir = lfs.currentdir()
        
        -- looking for and load test containers into self.dirs_
        local loadTestsState = 
        {
            filters = {fs.fileFilter, findOutTestContainer},
            loadedTestContainers = {},
            notLoadedTestContainers = {},
        }
        
        for _, dirPath in ipairs(self.dirs_) do
            fs.applyOnFiles(dirPath, 
                    {
                        filter = fs.multiFilter,
                        handler = loadAndRunTests,
                        recursive = true,
                        state = loadTestsState,
                    }
                )
        end
        
        lfs.chdir(savedWorkingDir);
        
        self.resultHandlers_:onTestsEnd()
        
        do -- display info about used test containers
            print('')
            
            local numOfNotLoaded = #loadTestsState.notLoadedTestContainers
            if numOfNotLoaded > 0 then
                print('Could not load ' .. numOfNotLoaded .. ' test containers:')
                
                for _, errData in ipairs(loadTestsState.notLoadedTestContainers) do
                    print('"' .. errData.path .. '": \r\n\t' .. errData.msg)
                end
            end

            local numOfLoaded = #loadTestsState.loadedTestContainers
            print('There were ' .. numOfLoaded .. ' test containers loaded:')
            for _, tcData in ipairs(loadTestsState.loadedTestContainers) do
                local msg = '"' .. tcData.path .. '" (' .. tcData.testNum
                if tcData.testNum == 0 or tcData.testNum > 1 then
                    print(msg .. ' tests)')
                else
                    print(msg .. ' test)')
                end
            end
        end
    end;
    
    runTestsOf = function(self, testContainerPath)
        if not self.fileExts_ then
            error('LTUE not loaded')
        end
        local usedLtue
        for ext, ltue in pairs(self.fileExts_) do
            if string.find(string.lower(testContainerPath), string.lower(ext), -string.len(ext), true) then
                usedLtue = ltue
                break
            end
        end
        if not usedLtue then
            return
        end

        self.resultHandlers_:onTestsBegin()
        
        local tests, errMsg = usedLtue.loadTestContainer(testContainerPath);

        if 'boolean' == type(tests) then
            self.resultHandlers_:onTestsEnd()
            print('Could not load test container "' .. testContainerPath .. '": ' .. errMsg)
            return
        end

        local savedWorkingDir = lfs.currentdir()
        
        for _, test in ipairs(tests) do
            normalizeTestCaseInterface(test)
        end
        -- we have to call table.sort after normalize tests interface, 
        -- because 'operatorLess' require concrete interface
        table.sort(tests, operatorLess)

        lfs.chdir(fs.dirname(testContainerPath))
        
        for _, test in ipairs(tests) do
            runTestCase(test, self.resultHandlers_)
        end
        
        self.resultHandlers_:onTestsEnd()
    end;
}

return _M
