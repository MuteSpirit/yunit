local setmetatable, ipairs, pairs, tostring, pcall, require, dofile, error, unpack = setmetatable, ipairs, pairs, tostring, pcall, require, dofile, error, unpack;
local debug_traceback = debug.traceback;
local table, io, string, package, os = table, io, string, package, os;

local testRunner = require("testunit.test_runner");

--~ require("LuaXML");
--~ local xml = xml;
--------------------------------------------------------------------------------------------------------------
module('testunit.test_listeners');
--------------------------------------------------------------------------------------------------------------


------------------------------------------------------
TextTestProgressListener = testRunner.TestListener:new{
        tableWithSuccesses = {},
        tableWithIgnores = {},
        tableWithErrors = {},
        tableWithFailures = {},
    };
------------------------------------------------------

function TextTestProgressListener:new()
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

function TextTestProgressListener:sciteErrorLine(errorObject)
    if string.find(errorObject.message, ':[%d]+:') or '[C]' == errorObject.source then
        return errorObject.message;
    else
        return errorObject.source .. ":" .. tostring(errorObject.line) .. ": " .. errorObject.message;
    end
end

function TextTestProgressListener:msvcErrorLine(errorObject)
    if string.find(errorObject.message, '%([%d]+%)') or '[C]' == errorObject.source then
        return errorObject.message;
    else
        return errorObject.source .. "(" .. tostring(errorObject.line) .. ") : " .. errorObject.message
    end
end

TextTestProgressListener.editorSpecifiedErrorLine = TextTestProgressListener.msvcErrorLine;

function TextTestProgressListener:resetCounters()
    self.tableWithSuccesses = {}
    self.tableWithIgnores = {}
    self.tableWithErrors = {}
    self.tableWithFailures = {}
end

function TextTestProgressListener:totalTestNum()
    return #self.tableWithSuccesses + #self.tableWithIgnores + #self.tableWithErrors + #self.tableWithFailures;
end

function TextTestProgressListener:totalResultsStr()
    local message = "Execution of tests has been completed:\n";

    message = message.."\t\t\tFailed:      "..tostring(#self.tableWithFailures);
    if #self.tableWithFailures > 0 then
        message = message.."\t(0_-) BUGS !!!";
    end
    message = message.."\n";

    message = message.."\t\t\tErrors:       "..tostring(#self.tableWithErrors);
    if #self.tableWithErrors > 0 then
        message = message.."\t(0_0) ???";
    end
    message = message.."\n";

    message = message.."\t\t\tIgnored:     "..tostring(#self.tableWithIgnores);
    if #self.tableWithIgnores > 0 then
        message = message.."\to(^_^)o ?";
    end
    message = message.."\n";

    message = message.."\t\t\tSuccessful:  "..tostring(#self.tableWithSuccesses).."\n";

    message = message.."\t\t\tTotal:       "..tostring(self:totalTestNum()).."\n";

    return message;
end

function TextTestProgressListener:outputMessage(message)
    io.write(message);
    io.output():flush();
end

function TextTestProgressListener:addSuccessful(testCaseName)
    table.insert(self.tableWithSuccesses, {testCaseName});
    self:outputMessage('.');
end

function TextTestProgressListener:addFailure(testCaseName, errorObject)
    table.insert(self.tableWithFailures, {testCaseName, errorObject});
    self:outputMessage('F');
end

function TextTestProgressListener:addError(testCaseName, errorObject)
    table.insert(self.tableWithErrors, {testCaseName, errorObject});
    self:outputMessage('E');
end

function TextTestProgressListener:addIgnore(testCaseName)
    table.insert(self.tableWithIgnores, {testCaseName});
    self:outputMessage("I");
end

function TextTestProgressListener:startTest(testCaseName)
end

function TextTestProgressListener:endTest(testCaseName)
end

function TextTestProgressListener:startTests()
    self:resetCounters();
    self:outputMessage('[');
end

function TextTestProgressListener:endTests()
    local res = {']', self:totalResultsStr()}
    
    local str = self:totalFailureStr()
    if string.len(str) > 0 then 
        table.insert(res, str)
    end
    
    local str = self:totalErrorStr()
    if string.len(str) > 0 then 
        table.insert(res, str)
    end

    self:outputMessage(table.concat(res, '\n'));
end

function TextTestProgressListener:totalErrorStr()
    local res = {}
    local testName, errorObject
    for _, record in pairs(self.tableWithErrors) do
        testName, errorObject = unpack(record)
        table.insert(res, testName .. '\n\t' .. self:editorSpecifiedErrorLine(errorObject))
    end;
    
    return table.concat(res, '\n------------------------------------------------------------------------------------------------------\n')
end

function TextTestProgressListener:totalFailureStr()
    local res = {}
    local testName, errorObject
    for _, record in pairs(self.tableWithFailures) do
        testName, errorObject = unpack(record)
        table.insert(res, testName .. '\n\t' .. self:editorSpecifiedErrorLine(errorObject))
    end;
    
    return table.concat(res, '\n------------------------------------------------------------------------------------------------------\n')
end



------------------------------------------------------
SciteTextTestProgressListener = TextTestProgressListener:new()
------------------------------------------------------

SciteTextTestProgressListener.editorSpecifiedErrorLine = TextTestProgressListener.sciteErrorLine--~ local defaultXmlReportPath = 'report.xml';

--~ ------------------------------------------------------
--~ XmlListenerAlaCppUnitXmlOutputter = testRunner.TestListener:new{
--~         reportContent =
--~         {
--~             FailedTests = {},
--~             SuccessfulTests = {},
--~             ErrorTests = {},
--~             IgnoredTests = {},
--~             Statistics = {},
--~         },
--~         testCount = 0,
--~         xmlFilePath = defaultXmlReportPath,
--~     };
--~ ------------------------------------------------------

--~ function XmlListenerAlaCppUnitXmlOutputter:new(o)
--~     o = o or {
--~         reportContent =
--~         {
--~             FailedTests = {},
--~             SuccessfulTests = {},
--~             ErrorTests = {},
--~             IgnoredTests = {},
--~             Statistics = {},
--~         },
--~         testCount = 0,
--~         xmlFilePath = defaultXmlReportPath,
--~     };
--~     setmetatable(o, self);
--~     self.__index = self;
--~     return o;
--~ end

--~ function XmlListenerAlaCppUnitXmlOutputter:xmlPath(newPath)
--~     self.xmlFilePath = newPath;
--~ end

--~ function XmlListenerAlaCppUnitXmlOutputter:succesfullTestInfo(testCaseName)
--~     return {
--~         id = self.testCount,
--~         Name = {testCaseName},
--~     };
--~ end

--~ function XmlListenerAlaCppUnitXmlOutputter:notSuccesfullTestInfo(testCaseName, errorObject)
--~     return {
--~         id = self.testCount,
--~         Name = {testCaseName},
--~         FailureType = {'Assertion'},
--~         Location =
--~             {
--~                 File = {errorObject.source},
--~                 Line = {errorObject.line},
--~             },
--~         Message = {errorObject.message},
--~     };
--~ end

--~ function XmlListenerAlaCppUnitXmlOutputter:addSuccessful(testCaseName)
--~     self.testCount = self.testCount + 1;
--~     table.insert(self.reportContent.SuccessfulTests, xml.str(self:succesfullTestInfo(testCaseName), 2, 'Test'));
--~ end

--~ function XmlListenerAlaCppUnitXmlOutputter:addIgnore(testCaseName)
--~     self.testCount = self.testCount + 1;
--~     table.insert(self.reportContent.IgnoredTests, xml.str(self:succesfullTestInfo(testCaseName), 2, 'IgnoredTest'));
--~ end

--~ function XmlListenerAlaCppUnitXmlOutputter:addFailure(testCaseName, errorObject)
--~     self.testCount = self.testCount + 1;
--~     table.insert(self.reportContent.FailedTests, xml.str(self:notSuccesfullTestInfo(testCaseName, errorObject), 2, 'FailedTest'));
--~ end

--~ function XmlListenerAlaCppUnitXmlOutputter:addError(testCaseName, errorObject)
--~     self.testCount = self.testCount + 1;
--~     table.insert(self.reportContent.ErrorTests, xml.str(self:notSuccesfullTestInfo(testCaseName, errorObject), 2, 'ErrorTest'));
--~ end

--~ function XmlListenerAlaCppUnitXmlOutputter:startTest(testCaseName)
--~ end

--~ function XmlListenerAlaCppUnitXmlOutputter:endTest(testCaseName)
--~ end

--~ function XmlListenerAlaCppUnitXmlOutputter:startTests()
--~     self.reportContent =
--~     {
--~         FailedTests = {},
--~         SuccessfulTests = {},
--~         ErrorTests = {},
--~         IgnoredTests = {},
--~         Statistics = {},
--~     };
--~     self.testCount = 0;
--~ end

--~ function XmlListenerAlaCppUnitXmlOutputter:endTests()
--~     if not self.xmlFilePath then
--~         self:outputMessage('Wrong setting xml report file path. Using default path.');
--~         self.xmlFilePath = defaultXmlReportPath;
--~     end

--~     self:outputMessage('Begin xml test report "'..self.xmlFilePath..'" creation...\n');

--~     local hXml, errMsg = io.open(self.xmlFilePath, 'w');
--~     if not hXml then
--~         error('Cannot create xml report file "' .. self.xmlFilePath .. '": ' .. errMsg .. '\n', 0);
--~     end

--~     hXml:write("<?xml version=\"1.0\"?>\n<!-- file \"", self.xmlFilePath, "\", generated by XmlListenerAlaCppUnitXmlOutputter -->\n\n")
--~     hXml:write('<?xml-stylesheet type="text/xsl" href="report.xsl"?>');
--~     hXml:write('<TestRun>\n');

--~     hXml:write(' <FailedTests>\n');
--~     hXml:write(table.concat(self.reportContent.FailedTests));
--~     hXml:write(' </FailedTests>\n');

--~     hXml:write(' <ErrorTests>\n');
--~     hXml:write(table.concat(self.reportContent.ErrorTests));
--~     hXml:write(' </ErrorTests>\n');

--~     hXml:write(' <IgnoredTests>\n');
--~     hXml:write(table.concat(self.reportContent.IgnoredTests));
--~     hXml:write(' </IgnoredTests>\n');

--~     hXml:write(' <SuccessfulTests>\n');
--~     hXml:write(table.concat(self.reportContent.SuccessfulTests));
--~     hXml:write(' </SuccessfulTests>\n');

--~     hXml:write(
--~         xml.str(
--~         {
--~             Tests = {self.testCount},
--~             FailuresTotal = {#self.reportContent.FailedTests + #self.reportContent.ErrorTests},
--~             Errors = {#self.reportContent.ErrorTests},
--~             Ignores = {#self.reportContent.IgnoredTests},
--~             Failures = {#self.reportContent.FailedTests},
--~         }, 1, 'Statistics')
--~     );

--~     hXml:write('</TestRun>\n');
--~     hXml:flush();
--~     hXml:close();

--~     self:outputMessage('Xml test report "'..self.xmlFilePath..'" creation finished succesfully\n');
--~ end

--~ function XmlListenerAlaCppUnitXmlOutputter:outputMessage(message)
--~     io.write(message);
--~     io.output():flush();
--~ end
