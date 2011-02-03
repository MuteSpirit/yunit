--- \class TextTestProgressListener
--- \brief Derived from TestListener. Output messages to standat output.
local luaUnit = require('testunit.luaunit');
local testListeners = require('testunit.test_listeners');



local testListeners = require('testunit.test_listeners');
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
        function testListeners.SciteTextTestProgressListener:unusedTestFunction()
        end
    end
    ;
    
    tearDown = function(self)
        testListeners.SciteTextTestProgressListener.unusedTestFunction = nil
    end
    ;
};

    function testTextTestProgressListenerCreation()
        isNotNil(testListeners.TextTestProgressListener:new());
    end

    function errorObjectFixture.testSciteErrorFormatterString()
        local ttpl = testListeners.SciteTextTestProgressListener:new();
      
        local desiredString = fakeErrorObject.source .. ":" .. tostring(fakeErrorObject.line) .. ": " .. fakeErrorObject.message
        areEq(desiredString, ttpl:sciteErrorLine(fakeErrorObject))
    end

    function errorObjectFixture.testErrorString()
        local ttpl = testListeners.SciteTextTestProgressListener:new();

        ttpl.outputMessage = function(self, msg) end
        ttpl:addError(fakeTestCaseName .. '2', fakeErrorObject)
        ttpl:addError(fakeTestCaseName .. '1', fakeErrorObject)
        funcName = ' (' ..  fakeErrorObject.func .. ')'
        local desiredString = '----Errors----\n' .. fakeTestCaseName .. "2" .. funcName .. "\n\t" .. ttpl:sciteErrorLine(fakeErrorObject) .. 
                                       "\n------------------------------------------------------------------------------------------------------\n" .. 
                                       fakeTestCaseName .. "1" .. funcName .. "\n\t" .. ttpl:sciteErrorLine(fakeErrorObject)
        areEq(desiredString, ttpl:totalErrorStr())
    end

    function errorObjectFixture.testFailureString()
        local ttpl = testListeners.SciteTextTestProgressListener:new();

        ttpl.outputMessage = function(self, msg) end
        ttpl:addFailure(fakeTestCaseName .. '2', fakeErrorObject)
        ttpl:addFailure(fakeTestCaseName .. '1', fakeErrorObject)
        
        funcName = ' (' ..  fakeErrorObject.func .. ')'
        local desiredString = '----Failures----\n' .. fakeTestCaseName .. "2" .. funcName .. "\n\t" .. ttpl:sciteErrorLine(fakeErrorObject) .. 
                                       "\n------------------------------------------------------------------------------------------------------\n" .. 
                                       fakeTestCaseName .. "1" .. funcName .. "\n\t" .. ttpl:sciteErrorLine(fakeErrorObject)
        
        areEq(desiredString, ttpl:totalFailureStr())
    end

    function errorObjectFixture.testIgnoreString()
        local ttpl = testListeners.SciteTextTestProgressListener:new();

        ttpl.outputMessage = function(self, msg) end
        ttpl:addIgnore(fakeTestCaseName .. '2', fakeErrorObject)
        ttpl:addIgnore(fakeTestCaseName .. '1', fakeErrorObject)
        
        local desiredString = '----Ignored----\n' .. ttpl:sciteErrorLine(fakeErrorObject) .. fakeTestCaseName .. "2\n" ..
                                       ttpl:sciteErrorLine(fakeErrorObject) .. fakeTestCaseName .. "1" 
        areEq(desiredString, ttpl:totalIgnoreStr())
    end

    function errorObjectFixture.testOutput()
        local ttpl = testListeners.SciteTextTestProgressListener:new();

        local function successfullOutput(self, msg) areEq('.', msg) end
        local function failedOutput(self, msg)        areEq('F', msg) end
        local function errorOutput(self, msg)         areEq('E', msg) end
        local function ignoredOutput(self, msg)      areEq('I', msg) end
        
        ttpl.outputMessage = function(self, msg) areEq('[', msg) end
        ttpl:startTests();

        ttpl.outputMessage = function(self, msg) areEq('Must not any output message', msg) end;
        ttpl:startTest(fakeTestCaseName, fakeTestName);
        
        ttpl.outputMessage = successfullOutput;
        ttpl:addSuccessful(fakeTestCaseName, fakeTestName);
        
        ttpl.outputMessage = function(self, msg) areEq('Must not any output message', msg) end;
        ttpl:endTest(fakeTestCaseName, fakeTestName);

        ttpl.outputMessage = function(self, msg) areEq('Must not any output message', msg) end;
        ttpl:startTest(fakeTestCaseName, fakeTestName);
        
        ttpl.outputMessage = failedOutput;
        ttpl:addFailure(fakeTestCaseName, fakeErrorObject);
        
        ttpl.outputMessage = function(self, msg) areEq('Must not any output message', msg) end;
        ttpl:endTest(fakeTestCaseName, fakeTestName);

        ttpl.outputMessage = function(self, msg) areEq('Must not any output message', msg) end;
        ttpl:startTest(fakeTestCaseName, fakeTestName);
        
        ttpl.outputMessage = errorOutput;
        ttpl:addError(fakeTestCaseName, fakeErrorObject);
        
        ttpl.outputMessage = function(self, msg) areEq('Must not any output message', msg) end;
        ttpl:endTest(fakeTestCaseName, fakeTestName);

        ttpl.outputMessage = function(self, msg) areEq('Must not any output message', msg) end;
        ttpl:startTest(fakeTestCaseName, fakeTestName);
        
        ttpl.outputMessage = ignoredOutput;
        ttpl:addIgnore(fakeTestCaseName, fakeErrorObject);
        
        ttpl.outputMessage = function(self, msg) areEq('Must not any output message', msg) end;
        ttpl:endTest(fakeTestCaseName, fakeTestName);
        
        ttpl.outputMessage = function(self, msg) end;
        ttpl:endTests();
    end

    function errorObjectFixture.emptyEndTestsTest()
        local ttpl = testListeners.SciteTextTestProgressListener:new();
        function ttpl:outputMessage(msg) 
            areEq(']\n' .. self:totalResultsStr(), msg);
        end
        ttpl:endTests();
    end

    function errorObjectFixture.filledEndTestsTest()
        local ttpl = testListeners.SciteTextTestProgressListener:new();
        
        ttpl.outputMessage = function(self, msg) end;
        ttpl:addFailure(fakeTestCaseName, fakeErrorObject);
        ttpl:addError(fakeTestCaseName, fakeErrorObject);
        
        function ttpl:outputMessage(msg) 
            areEq(']\n' .. self:totalResultsStr() .. '\n' .. self:totalFailureStr() .. '\n' .. self:totalErrorStr(), msg);
        end
        ttpl:endTests();
    end

    function sciteTextTestProgressListenerFixture.derivationTextTestListenerTest()
        local ttpl = testListeners.TextTestProgressListener:new();
        isNil(ttpl.unusedTestFunction)
        isNotNil(ttpl.outputMessage)
        local sttpl = testListeners.SciteTextTestProgressListener:new();
        isNotNil(sttpl.unusedTestFunction)
        isNotNil(sttpl.outputMessage)
    end
    
    --~ function errorObjectFixture.testXmlListenerSimulateTestRunning()
    --~     local ttpl = testListeners.XmlListenerAlaCppUnitXmlOutputter:new();
    --~     
    --~     function ttpl:outputMessage(message)
    --~     end

    --~     ttpl:startTests();

    --~     areEq(0, #ttpl.reportContent.FailedTests);
    --~     ttpl:startTest(fakeTestCaseName, fakeTestName);
    --~     ttpl:addSuccessful(fakeTestCaseName, fakeTestName);
    --~     ttpl:endTest(fakeTestCaseName, fakeTestName);
    --~     areEq(0, #ttpl.reportContent.FailedTests);
    --~     
    --~     areEq(0, #ttpl.reportContent.FailedTests);
    --~     ttpl:startTest(fakeTestCaseName, fakeTestName);
    --~     ttpl:addFailure(fakeTestCaseName, fakeErrorObject);
    --~     ttpl:endTest(fakeTestCaseName, fakeTestName);
    --~     areEq(1, #ttpl.reportContent.FailedTests);

    --~     ttpl:startTest(fakeTestCaseName, fakeTestName);
    --~     ttpl:addError(fakeTestCaseName, fakeErrorObject);
    --~     ttpl:endTest(fakeTestCaseName, fakeTestName);

    --~    ttpl:startTest(fakeTestCaseName, fakeTestName);
    --~     ttpl:addIgnore(fakeTestCaseName);
    --~     ttpl:endTest(fakeTestCaseName, fakeTestName);
    --~  
    --~     areEq(1, #ttpl.reportContent.SuccessfulTests);
    --~     areEq(1, #ttpl.reportContent.ErrorTests);
    --~     areEq(1, #ttpl.reportContent.IgnoredTests);
    --~     
    --~     ttpl:endTests();
    --~     
    --~ end
    --~ };
