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

TEST_SUITE(testModuleName)
{
    TEST_CASE{"testTextTestProgressListenerCreation", function(self)
        ASSERT_IS_NOT_NIL(testListeners.TextTestProgressListener:new());
    end
    };

    TEST_CASE_EX{"testTextTestProgressListenerCallAllFunctions", "ErrorObjectFixture", function(self)
        local ttpl = testListeners.TextTestProgressListener:new();
        
        function ttpl:outputMessage(message)
        end

        ttpl:startTests();

        ttpl:startTest(self.fakeTestCaseName, self.fakeTestName);
        ttpl:addSuccessful(self.fakeTestCaseName, self.fakeTestName);
        ttpl:endTest(self.fakeTestCaseName, self.fakeTestName);

        ttpl:startTest(self.fakeTestCaseName, self.fakeTestName);
        ttpl:addFailure(self.fakeTestCaseName, self.fakeErrorObject);
        ttpl:endTest(self.fakeTestCaseName, self.fakeTestName);

        ttpl:startTest(self.fakeTestCaseName, self.fakeTestName);
        ttpl:addError(self.fakeTestCaseName, self.fakeErrorObject);
        ttpl:endTest(self.fakeTestCaseName, self.fakeTestName);

        ttpl:startTest(self.fakeTestCaseName, self.fakeTestName);
        ttpl:addIgnore(self.fakeTestCaseName);
        ttpl:endTest(self.fakeTestCaseName, self.fakeTestName);
        
        ttpl:endTests();
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