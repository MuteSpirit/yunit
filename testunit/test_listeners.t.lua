--- \class TextTestProgressListener
--- \brief Derived from TestListener. Output messages to standat output.

local luaUnit = require('testunit.luaunit');
local testListeners = require('testunit.test_listeners');

module('test_listeners.t', luaUnit.testmodule, package.seeall);

--~ require('LuaXML');

local _G = _G;
local print = print;

local testModuleName = 'TestListenerTest';

TEST_FIXTURE("ErrorObjectFixture")
{
    setUp = function(self)
        self.fakeTestCaseName = testModuleName;
        self.fakeTestName = 'testObserverTest';
        self.fakeFailureMessage = "This is test message. It hasn't usefull information";
        self.fakeErrorObject = 
        {
            source = 'test_runner.t.lua';
            func = 'testTextTestProgressListenerCallAllFunctions';
            line = 113;
            message = self.fakeFailureMessage;
        }
    end
    ;
    
    tearDown = function(self)
        self.fakeTestCaseName = nil;
        self.fakeTestName = nil;
        self.fakeFailureMessage = nil;
        self.fakeErrorObject = nil;
    end
    ;
};

TEST_FIXTURE("SciteTextTestProgressListenerFixture")
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


TEST_SUITE(testModuleName)
{
    TEST_CASE{"testTextTestProgressListenerCreation", function(self)
        ASSERT_IS_NOT_NIL(testListeners.TextTestProgressListener:new());
    end
    };
};

TEST_SUITE("SciteTextTestProgressListenerTestSuite")
{
    TEST_CASE_EX{"testSciteErrorFormatterString", "ErrorObjectFixture", function(self)
        local ttpl = testListeners.SciteTextTestProgressListener:new();
      
        local desiredString = self.fakeErrorObject.source .. ":" .. tostring(self.fakeErrorObject.line) .. ": " .. self.fakeErrorObject.message
        ASSERT_EQUAL(desiredString, ttpl:sciteErrorLine(self.fakeErrorObject))
    end
    };

    TEST_CASE_EX{"testErrorString", "ErrorObjectFixture", function(self)
        local ttpl = testListeners.SciteTextTestProgressListener:new();

        ttpl.outputMessage = function(self, msg) end
        ttpl:addError(self.fakeTestCaseName .. '2', self.fakeErrorObject)
        ttpl:addError(self.fakeTestCaseName .. '1', self.fakeErrorObject)
        
        local desiredString = self.fakeTestCaseName .. "2\n\t" .. ttpl:sciteErrorLine(self.fakeErrorObject) .. 
                                       "\n------------------------------------------------------------------------------------------------------\n" .. 
                                       self.fakeTestCaseName .. "1\n\t" .. ttpl:sciteErrorLine(self.fakeErrorObject)
        ASSERT_EQUAL(desiredString, ttpl:totalErrorStr())
    end
    };

    TEST_CASE_EX{"testFailureString", "ErrorObjectFixture", function(self)
        local ttpl = testListeners.SciteTextTestProgressListener:new();

        ttpl.outputMessage = function(self, msg) end
        ttpl:addFailure(self.fakeTestCaseName .. '2', self.fakeErrorObject)
        ttpl:addFailure(self.fakeTestCaseName .. '1', self.fakeErrorObject)
        
        local desiredString = self.fakeTestCaseName .. "2\n\t" .. ttpl:sciteErrorLine(self.fakeErrorObject) .. 
                                       "\n------------------------------------------------------------------------------------------------------\n" .. 
                                       self.fakeTestCaseName .. "1\n\t" .. ttpl:sciteErrorLine(self.fakeErrorObject)
        
        ASSERT_EQUAL(desiredString, ttpl:totalFailureStr())
    end
    };

    TEST_CASE_EX{"testOutput", "ErrorObjectFixture", function(self)
        local ttpl = testListeners.SciteTextTestProgressListener:new();

        local function successfullOutput(self, msg) ASSERT_EQUAL('.', msg) end
        local function failedOutput(self, msg)        ASSERT_EQUAL('F', msg) end
        local function errorOutput(self, msg)         ASSERT_EQUAL('E', msg) end
        local function ignoredOutput(self, msg)      ASSERT_EQUAL('I', msg) end
        
        ttpl.outputMessage = function(self, msg) ASSERT_EQUAL('[', msg) end
        ttpl:startTests();

        ttpl.outputMessage = function(self, msg) ASSERT_EQUAL('Must not any output message', msg) end;
        ttpl:startTest(self.fakeTestCaseName, self.fakeTestName);
        
        ttpl.outputMessage = successfullOutput;
        ttpl:addSuccessful(self.fakeTestCaseName, self.fakeTestName);
        
        ttpl.outputMessage = function(self, msg) ASSERT_EQUAL('Must not any output message', msg) end;
        ttpl:endTest(self.fakeTestCaseName, self.fakeTestName);

        ttpl.outputMessage = function(self, msg) ASSERT_EQUAL('Must not any output message', msg) end;
        ttpl:startTest(self.fakeTestCaseName, self.fakeTestName);
        
        ttpl.outputMessage = failedOutput;
        ttpl:addFailure(self.fakeTestCaseName, self.fakeErrorObject);
        
        ttpl.outputMessage = function(self, msg) ASSERT_EQUAL('Must not any output message', msg) end;
        ttpl:endTest(self.fakeTestCaseName, self.fakeTestName);

        ttpl.outputMessage = function(self, msg) ASSERT_EQUAL('Must not any output message', msg) end;
        ttpl:startTest(self.fakeTestCaseName, self.fakeTestName);
        
        ttpl.outputMessage = errorOutput;
        ttpl:addError(self.fakeTestCaseName, self.fakeErrorObject);
        
        ttpl.outputMessage = function(self, msg) ASSERT_EQUAL('Must not any output message', msg) end;
        ttpl:endTest(self.fakeTestCaseName, self.fakeTestName);

        ttpl.outputMessage = function(self, msg) ASSERT_EQUAL('Must not any output message', msg) end;
        ttpl:startTest(self.fakeTestCaseName, self.fakeTestName);
        
        ttpl.outputMessage = ignoredOutput;
        ttpl:addIgnore(self.fakeTestCaseName);
        
        ttpl.outputMessage = function(self, msg) ASSERT_EQUAL('Must not any output message', msg) end;
        ttpl:endTest(self.fakeTestCaseName, self.fakeTestName);
        
        ttpl.outputMessage = function(self, msg) end;
        ttpl:endTests();
    end
    };

    TEST_CASE_EX{"emptyEndTestsTest", "ErrorObjectFixture", function(self)
        local ttpl = testListeners.SciteTextTestProgressListener:new();
        function ttpl:outputMessage(msg) 
            ASSERT_EQUAL(']\n' .. self:totalResultsStr(), msg);
        end
        ttpl:endTests();
    end
    };

    TEST_CASE_EX{"filledEndTestsTest", "ErrorObjectFixture", function(self)
        local ttpl = testListeners.SciteTextTestProgressListener:new();
        
        ttpl.outputMessage = function(self, msg) end;
        ttpl:addFailure(self.fakeTestCaseName, self.fakeErrorObject);
        ttpl:addError(self.fakeTestCaseName, self.fakeErrorObject);
        
        function ttpl:outputMessage(msg) 
            ASSERT_EQUAL(']\n' .. self:totalResultsStr() .. '\n' .. self:totalFailureStr() .. '\n' .. self:totalErrorStr(), msg);
        end
        ttpl:endTests();
    end
    };

    TEST_CASE_EX{"derivationTextTestListenerTest", "SciteTextTestProgressListenerFixture", function(self)
        local ttpl = testListeners.TextTestProgressListener:new();
        ASSERT_IS_NIL(ttpl.unusedTestFunction)
        ASSERT_IS_NOT_NIL(ttpl.outputMessage)
        local sttpl = testListeners.SciteTextTestProgressListener:new();
        ASSERT_IS_NOT_NIL(sttpl.unusedTestFunction)
        ASSERT_IS_NOT_NIL(sttpl.outputMessage)
    end
    };
    
    --~ TEST_CASE_EX{"testXmlListenerSimulateTestRunning", "ErrorObjectFixture", function(self)
    --~     local ttpl = testListeners.XmlListenerAlaCppUnitXmlOutputter:new();
    --~     
    --~     function ttpl:outputMessage(message)
    --~     end

    --~     ttpl:startTests();

    --~     ASSERT_EQUAL(0, #ttpl.reportContent.FailedTests);
    --~     ttpl:startTest(self.fakeTestCaseName, self.fakeTestName);
    --~     ttpl:addSuccessful(self.fakeTestCaseName, self.fakeTestName);
    --~     ttpl:endTest(self.fakeTestCaseName, self.fakeTestName);
    --~     ASSERT_EQUAL(0, #ttpl.reportContent.FailedTests);
    --~     
    --~     ASSERT_EQUAL(0, #ttpl.reportContent.FailedTests);
    --~     ttpl:startTest(self.fakeTestCaseName, self.fakeTestName);
    --~     ttpl:addFailure(self.fakeTestCaseName, self.fakeErrorObject);
    --~     ttpl:endTest(self.fakeTestCaseName, self.fakeTestName);
    --~     ASSERT_EQUAL(1, #ttpl.reportContent.FailedTests);

    --~     ttpl:startTest(self.fakeTestCaseName, self.fakeTestName);
    --~     ttpl:addError(self.fakeTestCaseName, self.fakeErrorObject);
    --~     ttpl:endTest(self.fakeTestCaseName, self.fakeTestName);

    --~    ttpl:startTest(self.fakeTestCaseName, self.fakeTestName);
    --~     ttpl:addIgnore(self.fakeTestCaseName);
    --~     ttpl:endTest(self.fakeTestCaseName, self.fakeTestName);
    --~  
    --~     ASSERT_EQUAL(1, #ttpl.reportContent.SuccessfulTests);
    --~     ASSERT_EQUAL(1, #ttpl.reportContent.ErrorTests);
    --~     ASSERT_EQUAL(1, #ttpl.reportContent.IgnoredTests);
    --~     
    --~     ttpl:endTests();
    --~     
    --~ end
    --~ };
};