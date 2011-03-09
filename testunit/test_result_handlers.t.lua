--- \class TextTestProgressHandler
--- \brief Derived from TestResultHandler. Output messages to standat output.
local luaUnit = require('testunit.luaunit');
local testResultHandlers = require('testunit.test_result_handlers');



local testResultHandlers = require('testunit.test_result_handlers');
--~ require('LuaXML');

local testModuleName = 'TestListenerTest';

errorObjectFixture = 
{
    setUp = function(self)
        fakeTestCaseName = testModuleName;
        fakeTestName = 'testObserverTest';
        fakeFailureMessage = "This is test message. It hasn't usefull information";
        fakeErrorObject = 
        {
            source = 'test_runner.t.lua';
            func = 'setUp';
            line = 113;
            message = fakeFailureMessage;
        }
    end
    ;
    
    tearDown = function(self)
        fakeTestCaseName = nil;
        fakeTestName = nil;
        fakeFailureMessage = nil;
        fakeErrorObject = nil;
    end
    ;
};

sciteTextTestProgressListenerFixture = 
{
    setUp = function(self)
        function testResultHandlers.SciteTextTestProgressHandler:unusedTestFunction()
        end
    end
    ;
    
    tearDown = function(self)
        testResultHandlers.SciteTextTestProgressHandler.unusedTestFunction = nil
    end
    ;
};

    function testTextTestProgressListenerCreation()
        isNotNil(testResultHandlers.TextTestProgressHandler:new());
    end

    function errorObjectFixture.testSciteErrorFormatterString()
        local ttpl = testResultHandlers.SciteTextTestProgressHandler:new();
      
        local desiredString = fakeErrorObject.source .. ":" .. tostring(fakeErrorObject.line) .. ": " .. fakeErrorObject.message
        areEq(desiredString, ttpl:sciteErrorLine(fakeErrorObject))
    end

    function errorObjectFixture.testErrorString()
        local ttpl = testResultHandlers.SciteTextTestProgressHandler:new();

        ttpl.outputMessage = function(self, msg) end
        ttpl:onTestError(fakeTestCaseName .. '2', fakeErrorObject)
        ttpl:onTestError(fakeTestCaseName .. '1', fakeErrorObject)
        funcName = ' (' ..  fakeErrorObject.func .. ')'
        local desiredString = '----Errors----\n' .. fakeTestCaseName .. "2" .. funcName .. "\n\t" .. ttpl:sciteErrorLine(fakeErrorObject) .. 
                                       "\n------------------------------------------------------------------------------------------------------\n" .. 
                                       fakeTestCaseName .. "1" .. funcName .. "\n\t" .. ttpl:sciteErrorLine(fakeErrorObject)
        areEq(desiredString, ttpl:totalErrorStr())
    end

    function errorObjectFixture.testFailureString()
        local ttpl = testResultHandlers.SciteTextTestProgressHandler:new();

        ttpl.outputMessage = function(self, msg) end
        ttpl:onTestFailure(fakeTestCaseName .. '2', fakeErrorObject)
        ttpl:onTestFailure(fakeTestCaseName .. '1', fakeErrorObject)
        
        funcName = ' (' ..  fakeErrorObject.func .. ')'
        local desiredString = '----Failures----\n' .. fakeTestCaseName .. "2" .. funcName .. "\n\t" .. ttpl:sciteErrorLine(fakeErrorObject) .. 
                                       "\n------------------------------------------------------------------------------------------------------\n" .. 
                                       fakeTestCaseName .. "1" .. funcName .. "\n\t" .. ttpl:sciteErrorLine(fakeErrorObject)
        
        areEq(desiredString, ttpl:totalFailureStr())
    end

    function errorObjectFixture.testIgnoreString()
        local ttpl = testResultHandlers.SciteTextTestProgressHandler:new();

        ttpl.outputMessage = function(self, msg) end
        ttpl:onTestIgnore(fakeTestCaseName .. '2', fakeErrorObject)
        ttpl:onTestIgnore(fakeTestCaseName .. '1', fakeErrorObject)
        
        local desiredString = '----Ignored----\n' .. ttpl:sciteErrorLine(fakeErrorObject) .. fakeTestCaseName .. "2\n" ..
                                       ttpl:sciteErrorLine(fakeErrorObject) .. fakeTestCaseName .. "1" 
        areEq(desiredString, ttpl:totalIgnoreStr())
    end

    function errorObjectFixture.testOutput()
        local ttpl = testResultHandlers.SciteTextTestProgressHandler:new();

        local function successfullOutput(self, msg) areEq('.', msg) end
        local function failedOutput(self, msg)        areEq('F', msg) end
        local function errorOutput(self, msg)         areEq('E', msg) end
        local function ignoredOutput(self, msg)      areEq('I', msg) end
        
        ttpl.outputMessage = function(self, msg) areEq('[', msg) end
        ttpl:onTestsBegin();

        ttpl.outputMessage = function(self, msg) areEq('Must not any output message', msg) end;
        ttpl:onTestBegin(fakeTestCaseName, fakeTestName);
        
        ttpl.outputMessage = successfullOutput;
        ttpl:onTestSuccessfull(fakeTestCaseName, fakeTestName);
        
        ttpl.outputMessage = function(self, msg) areEq('Must not any output message', msg) end;
        ttpl:onTestEnd(fakeTestCaseName, fakeTestName);

        ttpl.outputMessage = function(self, msg) areEq('Must not any output message', msg) end;
        ttpl:onTestBegin(fakeTestCaseName, fakeTestName);
        
        ttpl.outputMessage = failedOutput;
        ttpl:onTestFailure(fakeTestCaseName, fakeErrorObject);
        
        ttpl.outputMessage = function(self, msg) areEq('Must not any output message', msg) end;
        ttpl:onTestEnd(fakeTestCaseName, fakeTestName);

        ttpl.outputMessage = function(self, msg) areEq('Must not any output message', msg) end;
        ttpl:onTestBegin(fakeTestCaseName, fakeTestName);
        
        ttpl.outputMessage = errorOutput;
        ttpl:onTestError(fakeTestCaseName, fakeErrorObject);
        
        ttpl.outputMessage = function(self, msg) areEq('Must not any output message', msg) end;
        ttpl:onTestEnd(fakeTestCaseName, fakeTestName);

        ttpl.outputMessage = function(self, msg) areEq('Must not any output message', msg) end;
        ttpl:onTestBegin(fakeTestCaseName, fakeTestName);
        
        ttpl.outputMessage = ignoredOutput;
        ttpl:onTestIgnore(fakeTestCaseName, fakeErrorObject);
        
        ttpl.outputMessage = function(self, msg) areEq('Must not any output message', msg) end;
        ttpl:onTestEnd(fakeTestCaseName, fakeTestName);
        
        ttpl.outputMessage = function(self, msg) end;
        ttpl:onTestsEnd();
    end

    function errorObjectFixture.emptyEndTestsTest()
        local ttpl = testResultHandlers.SciteTextTestProgressHandler:new();
        function ttpl:outputMessage(msg) 
            areEq(']\n' .. self:totalResultsStr(), msg);
        end
        ttpl:onTestsEnd();
    end

    function errorObjectFixture.filledEndTestsTest()
        local ttpl = testResultHandlers.SciteTextTestProgressHandler:new();
        
        ttpl.outputMessage = function(self, msg) end;
        ttpl:onTestFailure(fakeTestCaseName, fakeErrorObject);
        ttpl:onTestError(fakeTestCaseName, fakeErrorObject);
        
        function ttpl:outputMessage(msg) 
            areEq(']\n' .. self:totalResultsStr() .. '\n' .. self:totalFailureStr() .. '\n' .. self:totalErrorStr(), msg);
        end
        ttpl:onTestsEnd();
    end

    function sciteTextTestProgressListenerFixture.derivationTextTestListenerTest()
        local ttpl = testResultHandlers.TextTestProgressHandler:new();
        isNil(ttpl.unusedTestFunction)
        isNotNil(ttpl.outputMessage)
        local sttpl = testResultHandlers.SciteTextTestProgressHandler:new();
        isNotNil(sttpl.unusedTestFunction)
        isNotNil(sttpl.outputMessage)
    end
    
    --~ function errorObjectFixture.testXmlListenerSimulateTestRunning()
    --~     local ttpl = testResultHandlers.XmlListenerAlaCppUnitXmlOutputter:new();
    --~     
    --~     function ttpl:outputMessage(message)
    --~     end

    --~     ttpl:onTestsBegin();

    --~     areEq(0, #ttpl.reportContent.FailedTests);
    --~     ttpl:onTestBegin(fakeTestCaseName, fakeTestName);
    --~     ttpl:onTestSuccessfull(fakeTestCaseName, fakeTestName);
    --~     ttpl:onTestEnd(fakeTestCaseName, fakeTestName);
    --~     areEq(0, #ttpl.reportContent.FailedTests);
    --~     
    --~     areEq(0, #ttpl.reportContent.FailedTests);
    --~     ttpl:onTestBegin(fakeTestCaseName, fakeTestName);
    --~     ttpl:onTestFailure(fakeTestCaseName, fakeErrorObject);
    --~     ttpl:onTestEnd(fakeTestCaseName, fakeTestName);
    --~     areEq(1, #ttpl.reportContent.FailedTests);

    --~     ttpl:onTestBegin(fakeTestCaseName, fakeTestName);
    --~     ttpl:onTestError(fakeTestCaseName, fakeErrorObject);
    --~     ttpl:onTestEnd(fakeTestCaseName, fakeTestName);

    --~    ttpl:onTestBegin(fakeTestCaseName, fakeTestName);
    --~     ttpl:onTestIgnore(fakeTestCaseName);
    --~     ttpl:onTestEnd(fakeTestCaseName, fakeTestName);
    --~  
    --~     areEq(1, #ttpl.reportContent.SuccessfulTests);
    --~     areEq(1, #ttpl.reportContent.ErrorTests);
    --~     areEq(1, #ttpl.reportContent.IgnoredTests);
    --~     
    --~     ttpl:onTestsEnd();
    --~     
    --~ end
    --~ };