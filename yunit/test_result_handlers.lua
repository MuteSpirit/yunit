local _G = _G

--------------------------------------------------------------------------------------------------------------
module(...)
_G.setmetatable(_M, {__index = _G})
--------------------------------------------------------------------------------------------------------------

local testRunner = require("yunit.test_runner");

------------------------------------------------------
TextTestProgressHandler = testRunner.TestResultHandler:new{
        tableWithSuccesses = {},
        tableWithIgnores = {},
        tableWithErrors = {},
        tableWithFailures = {},
    };
------------------------------------------------------

function TextTestProgressHandler:new()
    local o =
    {
        tableWithSuccesses = {},
        tableWithIgnores = {},
        tableWithErrors = {},
        tableWithFailures = {},
    };
    setmetatable(o, self);
    self.__index = self;
    return o;
end

function TextTestProgressHandler:sciteErrorLine(errorObject)
    if string.find(errorObject.message, ':[%d]+:') or '[C]' == errorObject.source then
        return errorObject.message;
    else
        return errorObject.source .. ":" .. tostring(errorObject.line) .. ": " .. errorObject.message .. "\n"
    end
end

function TextTestProgressHandler:msvcErrorLine(errorObject)
    if string.find(errorObject.message, '%([%d]+%)') or '[C]' == errorObject.source then
        return errorObject.message;
    else
        return errorObject.source .. "(" .. tostring(errorObject.line) .. ") : " .. errorObject.message
    end
end

TextTestProgressHandler.editorSpecifiedErrorLine = TextTestProgressHandler.msvcErrorLine;

function TextTestProgressHandler:resetCounters()
    self.tableWithSuccesses = {}
    self.tableWithIgnores = {}
    self.tableWithErrors = {}
    self.tableWithFailures = {}
end

function TextTestProgressHandler:totalTestNum()
    return #self.tableWithSuccesses + #self.tableWithIgnores + #self.tableWithErrors + #self.tableWithFailures;
end

function TextTestProgressHandler:totalResultsStr()
    local message = "Execution of tests has been completed:\n";

    message = message.."\t\t\tFailed:\t\t"..tostring(#self.tableWithFailures);
    if #self.tableWithFailures > 0 then
        message = message.."\t(0_-) BUGS !!!";
    end
    message = message.."\n";

    message = message.."\t\t\tErrors:\t\t"..tostring(#self.tableWithErrors);
    if #self.tableWithErrors > 0 then
        message = message.."\t(0_0) ???";
    end
    message = message.."\n";

    message = message.."\t\t\tIgnored:\t\t"..tostring(#self.tableWithIgnores);
    if #self.tableWithIgnores > 0 then
        message = message.."\to(^_^)o ?";
    end
    message = message.."\n";

    message = message.."\t\t\tSuccessful:\t" .. tostring(#self.tableWithSuccesses) .. "\n";

    message = message.."\t\t\tTotal:\t\t" .. tostring(self:totalTestNum()) .. "\n";

    return message;
end

function TextTestProgressHandler:outputMessage(message)
    io.write(message);
end

function TextTestProgressHandler:onTestSuccessfull(testCaseName)
    table.insert(self.tableWithSuccesses, {testCaseName});
    self:outputMessage('.');
end

function TextTestProgressHandler:onTestFailure(testCaseName, errorObject)
    table.insert(self.tableWithFailures, {testCaseName, errorObject});
    self:outputMessage('F');
end

function TextTestProgressHandler:onTestError(testCaseName, errorObject)
    table.insert(self.tableWithErrors, {testCaseName, errorObject});
    self:outputMessage('E');
end

function TextTestProgressHandler:onTestIgnore(testCaseName, errorObject)
    table.insert(self.tableWithIgnores, {testCaseName, errorObject});
    self:outputMessage("I");
end

function TextTestProgressHandler:onTestsBegin()
    self:resetCounters();
    self:outputMessage('[');
end

function TextTestProgressHandler:onTestsEnd()
    local res = {']', self:totalResultsStr()}
    
    local str = self:totalFailureStr()
    if string.len(str) > 0 then 
        table.insert(res, str)
    end
    
    local str = self:totalErrorStr()
    if string.len(str) > 0 then 
        table.insert(res, str)
    end

    local str = self:totalIgnoreStr()
    if string.len(str) > 0 then 
        table.insert(res, str)
    end

    self:outputMessage(table.concat(res, '\n'));
end

function TextTestProgressHandler:totalErrorStr()
    local res = {}
    local testName, errorObject

    local prefix = ''
    if #self.tableWithErrors > 0 then
        prefix = '----Errors----\n'
    end

    for _, record in ipairs(self.tableWithErrors) do
        testName, errorObject = unpack(record)
        
        local funcName = ''
        if string.len(errorObject.func) > 0 then
            funcName = ' (' ..  errorObject.func .. ')'
        end
        
        table.insert(res, testName .. funcName .. '\n\t' .. self:editorSpecifiedErrorLine(errorObject))
    end;
    
    return prefix .. table.concat(res, '\n------------------------------------------------------------------------------------------------------\n')
end

function TextTestProgressHandler:totalFailureStr()
    local res = {}
    local testName, errorObject

    local prefix = ''
    if #self.tableWithFailures > 0 then
        prefix = '----Failures----\n'
    end
    
    for _, record in ipairs(self.tableWithFailures) do
        testName, errorObject = unpack(record)

        local funcName = ''
        if string.len(errorObject.func) > 0 then
            funcName = ' (' ..  errorObject.func .. ')'
        end
        
        table.insert(res, testName .. funcName .. '\n\t' .. self:editorSpecifiedErrorLine(errorObject))
    end;
    
    return prefix .. table.concat(res, '\n------------------------------------------------------------------------------------------------------\n')
end

function TextTestProgressHandler:totalIgnoreStr()
    local res = {}
    local testName

    local prefix = ''
    if #self.tableWithIgnores > 0 then
        prefix = '----Ignored----\n'
    end
    
    for _, record in ipairs(self.tableWithIgnores) do
        testName, errorObject = unpack(record)
        table.insert(res, self:editorSpecifiedErrorLine(errorObject) ..  testName)
    end;
    
    return prefix .. table.concat(res, '\n')
end


------------------------------------------------------
SciteTextTestProgressHandler = TextTestProgressHandler:new()
------------------------------------------------------

SciteTextTestProgressHandler.editorSpecifiedErrorLine = TextTestProgressHandler.sciteErrorLine

local defaultXmlReportPath = 'report.xml'

------------------------------------------------------
XmlTestResultHandler = testRunner.TestResultHandler:new{
        tableWithSuccesses = {},
        tableWithIgnores = {},
        tableWithErrors = {},
        tableWithFailures = {},
        reportPath = defaultXmlReportPath,
	testCount = 0,
    };

------------------------------------------------------
function XmlTestResultHandler:new()
    local o =
    {
        tableWithSuccesses = {},
        tableWithIgnores = {},
        tableWithErrors = {},
        tableWithFailures = {},
        reportPath = defaultXmlReportPath,
	testCount = 0,
    };
    setmetatable(o, self);
    self.__index = self;
    return o;
end

function XmlTestResultHandler:outputMessage(message)
    io.write(message);
end

function XmlTestResultHandler:onTestSuccessfull(testCaseName)
    self.testCount = self.testCount + 1
    self.tableWithSuccesses[self.testCount] = {testCaseName}
end

function XmlTestResultHandler:onTestFailure(testCaseName, errorObject)
    self.testCount = self.testCount + 1
    self.tableWithFailures[self.testCount] = {testCaseName, errorObject}
end

function XmlTestResultHandler:onTestError(testCaseName, errorObject)
    self.testCount = self.testCount + 1
    self.tableWithErrors[self.testCount] = {testCaseName, errorObject}
end

function XmlTestResultHandler:onTestIgnore(testCaseName, errorObject)
    self.testCount = self.testCount + 1
    self.tableWithIgnores[self.testCount] = {testCaseName, errorObject}
end

function XmlTestResultHandler:onTestsBegin()
    self.tableWithSuccesses = {}
    self.tableWithIgnores = {}
    self.tableWithErrors = {}
    self.tableWithFailures = {}
    self.testCount = 0
end

function XmlTestResultHandler:onTestsEnd()
    self:outputMessage('Make XML report "' .. self.reportPath .. '"...');

    local f, errMsg = io.open(self.reportPath, 'w')
    if not f then
        self:outputMessage('Cannot create xml report file "' .. self.reportPath .. '": ' .. errMsg .. '\r\n', 0)
        return
    end

    local repLines = {}
    table.insert(repLines, '<?xml version="1.0"?>')
    table.insert(repLines, '<!-- File has been generated by XmlTestResultHandler -->')
    table.insert(repLines, '')
    table.insert(repLines, '<TestRun>')

    local testCaseName, errorObject
    
    table.insert(repLines, '\t<FailedTests>');
	for i, res in pairs(self.tableWithFailures) do
		testCaseName, errorObject = res[1], res[2]
		table.insert(repLines, '\t\t<Test id=' .. tostring(i) .. '>')
		table.insert(repLines, '\t\t\t<Name>' .. testCaseName .. '</Name>')
		table.insert(repLines, '\t\t\t<FailureType>' .. 'Assertion' .. '</FailureType>')
		table.insert(repLines, '\t\t\t<Location>')
		table.insert(repLines, '\t\t\t<File>' .. errorObject.source .. '</File>')
		table.insert(repLines, '\t\t\t<Line>' .. errorObject.line .. '</Line>')
		table.insert(repLines, '\t\t\t</Location>')
		table.insert(repLines, '\t\t\t<Message>' .. errorObject.message .. '</Message>')
		table.insert(repLines, '\t\t</Test>')
	end
    table.insert(repLines, '\t</FailedTests>');

    table.insert(repLines, '\t<ErrorTests>');
	for i, res in pairs(self.tableWithErrors) do
		testCaseName, errorObject = res[1], res[2]
		table.insert(repLines, '\t\t<Test id=' .. i .. '>')
		table.insert(repLines, '\t\t\t<Name>' .. testCaseName .. '</Name>')
		table.insert(repLines, '\t\t\t<FailureType>' .. 'Error' .. '</FailureType>')
		table.insert(repLines, '\t\t\t<Location>')
		table.insert(repLines, '\t\t\t<File>' .. errorObject.source .. '</File>')
		table.insert(repLines, '\t\t\t<Line>' .. errorObject.line .. '</Line>')
		table.insert(repLines, '\t\t\t</Location>')
		table.insert(repLines, '\t\t\t<Message>' .. errorObject.message .. '</Message>')
		table.insert(repLines, '\t\t</Test>')
	end
    table.insert(repLines, '\t</ErrorTests>');

    table.insert(repLines, '\t<IgnoredTests>');
	for i, res in pairs(self.tableWithIgnores) do
		testCaseName, errorObject = res[1], nil
		table.insert(repLines, '\t\t<Test id=' .. i .. '>')
		table.insert(repLines, '\t\t\t<Name>' .. testCaseName .. '</Name>')
		table.insert(repLines, '\t\t</Test>')
	end
    table.insert(repLines, '\t</IgnoredTests>');

    table.insert(repLines, '\t<SuccessfulTests>');
	for i, res in pairs(self.tableWithSuccesses) do
		testCaseName, errorObject = res[1], nil
		table.insert(repLines, '\t\t<Test id=' .. i .. '>')
		table.insert(repLines, '\t\t\t<Name>' .. testCaseName .. '</Name>')
		table.insert(repLines, '\t\t</Test>')
	end
    table.insert(repLines, '\t</SuccessfulTests>');

    table.insert(repLines, '\t<Statistics>')
    table.insert(repLines, '\t\t<Tests>' .. self.testCount .. '<Tests/>')
    table.insert(repLines, '\t\t<FailuresTotal>' .. #self.tableWithFailures + #self.tableWithErrors .. '</FailuresTotal>')
    table.insert(repLines, '\t\t<Errors>' .. #self.tableWithErrors .. '</Errors>')
    table.insert(repLines, '\t\t<Ignores>' .. #self.tableWithIgnores .. '</Ignores>')
    table.insert(repLines, '\t\t<Failures>' .. #self.tableWithFailures .. '</Failures>')
    table.insert(repLines, '\t</Statistics>')

    table.insert(repLines, '</TestRun>');
    f:write(table.concat(repLines, '\r\n'));
    f:close();

    self:outputMessage(' done\r\n');
end

FixFailed = testRunner.TestResultHandler:new{
    thereIsFailureTest_ = false,
    thereIsAlmostOneTest_ = false,
}

------------------------------------------------------
function FixFailed:new()
    local o =
    {
        thereIsFailureTest_ = false,
        thereIsAlmostOneTest_ = false,
    };
    setmetatable(o, self);
    self.__index = self;
    return o;
end

function FixFailed:passed()
    return self.thereIsAlmostOneTest_ and not self.thereIsFailureTest_
end

function FixFailed:onTestSuccessfull(testCaseName)
    self.thereIsAlmostOneTest_ = true
end

function FixFailed:onTestFailure(testCaseName, errorObject)
    self.thereIsAlmostOneTest_ = true
    self.thereIsFailureTest_ = true
end

function FixFailed:onTestError(testCaseName, errorObject)
    self.thereIsAlmostOneTest_ = true
    self.thereIsFailureTest_ = true
end
