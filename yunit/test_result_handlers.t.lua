--- \class TextTestProgressHandler
--- \brief Derived from TestResultHandler. Output messages to standat output.
local luaUnit = require "yunit.luaunit"
local testResultHandlers = require "yunit.test_result_handlers"

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
        self.fakeErrorObjectWithTraceback = 
        {
            source = 'test_runner.t.lua';
            func = 'setUp';
            line = 113;
            message = fakeFailureMessage;
            stack = 
            {
                [1] = {
                    source = '=[C]',
                    line = -1,
                    funcname = "function 'error'",
                },
                [2] = {
                    source = "@/home/mutespirit/ws/yunit/yunit/../yunit/luaunit.lua",
                    line = 125,
                    funcname = "function 'isTrue'",
                },
                [3] = {
                    source = "=/home/mutespirit/ws/yunit/yunit/luaunit.t.lua",
                    line = 338,
                    funcname = "function </home/mutespirit/ws/yunit/yunit/luaunit.t.lua:337>",
                },
                [4] = {
                    source = '=[C]',
                    line = -1,
                    funcname = "function 'xpcall'",
                },
                [5] = {
                    source = "@/home/mutespirit/ws/yunit/yunit/../yunit/luaunit.lua",
                    line = 306,
                    funcname = "function </home/mutespirit/ws/yunit/yunit/../yunit/luaunit.lua:302>",
                },
                [6] = {
                    source = "@/home/mutespirit/ws/yunit/yunit/../yunit/test_runner.lua",
                    line = 163,
                    funcname = "function 'runTestCase'",
                },
                [7] = {
                    source = "@/home/mutespirit/ws/yunit/yunit/../yunit/test_runner.lua",
                    line = 288,
                    funcname = "function 'handler'",
                },
            };
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
        function testResultHandlers.SciteTextTestProgressHandler:XmlTestResultHandler()
        end
    end
    ;
    
    tearDown = function(self)
        testResultHandlers.SciteTextTestProgressHandler.XmlTestResultHandler = nil
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
	local desiredString = '----Errors----\n'
	                   .. fakeErrorObject.source .. '::' .. fakeTestCaseName .. "2" .. funcName .. '\n'
	                   .. '\t' .. ttpl:sciteErrorLine(fakeErrorObject)
	                   .. "\n------------------------------------------------------------------------------------------------------\n"
	                   .. fakeErrorObject.source .. '::' .. fakeTestCaseName .. "1" .. funcName .. '\n'
	                   .. '\t' .. ttpl:sciteErrorLine(fakeErrorObject)
	                   .. "\n------------------------------------------------------------------------------------------------------\n"
	areEq(desiredString, ttpl:totalErrorStr())
end

function errorObjectFixture.testFailureString()
	local ttpl = testResultHandlers.SciteTextTestProgressHandler:new();

	ttpl.outputMessage = function(self, msg) end
	ttpl:onTestFailure(fakeTestCaseName .. '2', fakeErrorObject)
	ttpl:onTestFailure(fakeTestCaseName .. '1', fakeErrorObject)
	
	funcName = ' (' ..  fakeErrorObject.func .. ')'
	local desiredString = '----Failures----\n'
	                   .. fakeErrorObject.source .. '::' .. fakeTestCaseName .. "2" .. funcName .. '\n'
	                   .. '\t' .. ttpl:sciteErrorLine(fakeErrorObject)
	                   .. "\n------------------------------------------------------------------------------------------------------\n"
	                   .. fakeErrorObject.source .. '::' .. fakeTestCaseName .. "1" .. funcName .. '\n'
	                   .. '\t' .. ttpl:sciteErrorLine(fakeErrorObject)
	                   .. "\n------------------------------------------------------------------------------------------------------\n"
	
	areEq(desiredString, ttpl:totalFailureStr())
end

function errorObjectFixture.testIgnoreString()
	local ttpl = testResultHandlers.SciteTextTestProgressHandler:new();

	ttpl.outputMessage = function(self, msg) end
	ttpl:onTestIgnore(fakeTestCaseName .. '2', fakeErrorObject)
	ttpl:onTestIgnore(fakeTestCaseName .. '1', fakeErrorObject)
	
	local desiredString = '----Ignored----\n'
	                    .. ttpl:sciteErrorLine(fakeErrorObject) .. fakeTestCaseName .. "2\n"
	                    .. ttpl:sciteErrorLine(fakeErrorObject) .. fakeTestCaseName .. "1" 
	                    
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
	isNil(ttpl.XmlTestResultHandler)
	isNotNil(ttpl.outputMessage)
	local sttpl = testResultHandlers.SciteTextTestProgressHandler:new();
	isNotNil(sttpl.XmlTestResultHandler)
	isNotNil(sttpl.outputMessage)
end

function errorObjectFixture.testXmlListenerSimulateTestRunning()
    local ttpl = testResultHandlers.XmlTestResultHandler:new()
    
    function ttpl:outputMessage(message)
    end

    ttpl:onTestsBegin()

    areEq(0, #ttpl.tableWithSuccesses)
    ttpl:onTestBegin(fakeTestCaseName, fakeTestName)
    ttpl:onTestSuccessfull(fakeTestCaseName)
    ttpl:onTestEnd(fakeTestCaseName, fakeTestName)
    areEq(1, #ttpl.tableWithSuccesses)
    
    areEq(0, #ttpl.tableWithFailures)
    ttpl:onTestBegin(fakeTestCaseName, fakeTestName)
    ttpl:onTestFailure(fakeTestCaseName, fakeErrorObject)
    ttpl:onTestEnd(fakeTestCaseName, fakeTestName)
    isNotNil(next(ttpl.tableWithFailures))

    areEq(0, #ttpl.tableWithErrors)
    ttpl:onTestBegin(fakeTestCaseName, fakeTestName)
    ttpl:onTestError(fakeTestCaseName, fakeErrorObject)
    ttpl:onTestEnd(fakeTestCaseName, fakeTestName)
   isNotNil(next(ttpl.tableWithErrors))

    areEq(0, #ttpl.tableWithIgnores)
    ttpl:onTestBegin(fakeTestCaseName, fakeTestName)
    ttpl:onTestIgnore(fakeTestCaseName)
    ttpl:onTestEnd(fakeTestCaseName, fakeTestName)
    isNotNil(next(ttpl.tableWithIgnores))
    
    ttpl:onTestsEnd()
end

function errorObjectFixture.fixed_failed_test_result_handler_return_ok()
	local testResHandler = testResultHandlers.FixFailed:new()

    testResHandler:onTestSuccessfull(fakeTestCaseName)
	isTrue(testResHandler:passed())
	
    testResHandler:onTestIgnore(fakeTestCaseName)
	isTrue(testResHandler:passed())
end

function errorObjectFixture.fixed_failed_test_result_handler_return_not_ok_on_tests_absent()
	local testResHandler = testResultHandlers.FixFailed:new()
	isFalse(testResHandler:passed())
end

function errorObjectFixture.fixed_failed_test_result_handler_return_not_ok_on_test_error()
	local testResHandler = testResultHandlers.FixFailed:new()
    testResHandler:onTestError(fakeTestCaseName, fakeErrorObject)
	isFalse(testResHandler:passed())
end

function errorObjectFixture.fixed_failed_test_result_handler_return_not_ok_on_test_failed()
	local testResHandler = testResultHandlers.FixFailed:new()
    testResHandler:onTestFailure(fakeTestCaseName, fakeErrorObject)
	isFalse(testResHandler:passed())
end

function errorObjectFixture.fixed_failed_test_result_handler_return_not_ok_on_last_successfull_test()
	local fixFailedTestRes = testResultHandlers.FixFailed:new()
    fixFailedTestRes:onTestFailure(fakeTestCaseName, fakeErrorObject)
    fixFailedTestRes:onTestSuccessfull(fakeTestCaseName)
	isFalse(fixFailedTestRes:passed())
end


