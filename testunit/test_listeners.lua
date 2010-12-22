local setmetatable, ipairs, tostring, pcall, require, dofile, error = setmetatable, ipairs, tostring, pcall, require, dofile, error;
local debug_traceback = debug.traceback;
local table, io, string, package, os = table, io, string, package, os;

local testRunner = require("testunit.test_runner");

require("LuaXML");
local xml = xml;
--------------------------------------------------------------------------------------------------------------
module('testunit.test_listeners');
--------------------------------------------------------------------------------------------------------------


------------------------------------------------------
TextTestProgressListener = testRunner.TestListener:new{
        successfulTestsNum = 0,
        failedTestsNum = 0,
        errorTestsNum = 0,
        ignoredTestsNum = 0,
    };
------------------------------------------------------

function TextTestProgressListener:new(o)
    o = o or {
        successfulTestsNum = 0,
        failedTestsNum = 0,
        errorTestsNum = 0,
        ignoredTestsNum = 0,
    };
    setmetatable(o, self);
    self.__index = self;
    return o;
end

function TextTestProgressListener:addSuccessful(testCaseName)
    self.successfulTestsNum = self.successfulTestsNum + 1;
    self:outputMessage("OK");
end

function TextTestProgressListener:addIgnore(testCaseName)
    self.ignoredTestsNum = self.ignoredTestsNum + 1;
    self:outputMessage("IGNORED");
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

function TextTestProgressListener:addFailure(testCaseName, errorObject)
    self.failedTestsNum = self.failedTestsNum + 1;
    self:outputMessage("FAILURE\n\t" .. self:editorSpecifiedErrorLine(errorObject));
end

function TextTestProgressListener:addError(testCaseName, errorObject)
    self.errorTestsNum = self.errorTestsNum + 1;
    self:outputMessage("ERROR\n\t" .. self:editorSpecifiedErrorLine(errorObject));
end

function TextTestProgressListener:startTest(testCaseName)
    self:outputMessage(testCaseName..": ");
end

function TextTestProgressListener:endTest(testCaseName)
    self:outputMessage("\n");
end

function TextTestProgressListener:startTests()
    self.successfulTestsNum = 0;
    self.failedTestsNum = 0;
    self.errorTestsNum = 0;
    self.ignoredTestsNum = 0;
end

function TextTestProgressListener:totalTestNum()
    return self.failedTestsNum + self.errorTestsNum + self.ignoredTestsNum + self.successfulTestsNum;
end

function TextTestProgressListener:endTests()
    local message = "Execution of tests has been completed:\n";

    message = message.."\t\t\tFailed:      "..tostring(self.failedTestsNum);
    if self.failedTestsNum > 0 then
        message = message.."\t(0_-) BUGS !!!";
    end
    message = message.."\n";

    message = message.."\t\t\tErrors:       "..tostring(self.errorTestsNum);
    if self.errorTestsNum > 0 then
        message = message.."\t(0_0) ???";
    end
    message = message.."\n";

    message = message.."\t\t\tIgnored:     "..tostring(self.ignoredTestsNum);
    if self.ignoredTestsNum > 0 then
        message = message.."\to(^_^)o ?";
    end
    message = message.."\n";

    message = message.."\t\t\tSuccessful:  "..tostring(self.successfulTestsNum).."\n";

    message = message.."\t\t\tTotal:       "..tostring(self:totalTestNum()).."\n";

    self:outputMessage(message);
end

function TextTestProgressListener:outputMessage(message)
    io.write(message);
    io.output():flush();
end


------------------------------------------------------
SciteTextTestProgressListener = TextTestProgressListener:new();
------------------------------------------------------

SciteTextTestProgressListener.editorSpecifiedErrorLine = TextTestProgressListener.sciteErrorLine

function SciteTextTestProgressListener:addSuccessful(testCaseName)
    self.successfulTestsNum = self.successfulTestsNum + 1;
    self:outputMessage(testCaseName .. ": OK\n");
end

function SciteTextTestProgressListener:addFailure(testCaseName, errorObject)
    self.failedTestsNum = self.failedTestsNum + 1;
    self:outputMessage(testCaseName .. ": FAILURE\n" .. self:editorSpecifiedErrorLine(errorObject) .. "\n");
end

function SciteTextTestProgressListener:addError(testCaseName, errorObject)
    self.errorTestsNum = self.errorTestsNum + 1;
    self:outputMessage(testCaseName .. ": ERROR\n".."\t" .. self:editorSpecifiedErrorLine(errorObject) .. "\n");
end

function SciteTextTestProgressListener:startTest(testCaseName)
end

function SciteTextTestProgressListener:endTest(testCaseName)
end

local defaultXmlReportPath = 'report.xml';

------------------------------------------------------
XmlListenerAlaCppUnitXmlOutputter = testRunner.TestListener:new{
        reportContent =
        {
            FailedTests = {},
            SuccessfulTests = {},
            ErrorTests = {},
            IgnoredTests = {},
            Statistics = {},
        },
        testCount = 0,
        xmlFilePath = defaultXmlReportPath,
    };
------------------------------------------------------

function XmlListenerAlaCppUnitXmlOutputter:new(o)
    o = o or {
        reportContent =
        {
            FailedTests = {},
            SuccessfulTests = {},
            ErrorTests = {},
            IgnoredTests = {},
            Statistics = {},
        },
        testCount = 0,
        xmlFilePath = defaultXmlReportPath,
    };
    setmetatable(o, self);
    self.__index = self;
    return o;
end

function XmlListenerAlaCppUnitXmlOutputter:xmlPath(newPath)
    self.xmlFilePath = newPath;
end

function XmlListenerAlaCppUnitXmlOutputter:succesfullTestInfo(testCaseName)
    return {
        id = self.testCount,
        Name = {testCaseName},
    };
end

function XmlListenerAlaCppUnitXmlOutputter:notSuccesfullTestInfo(testCaseName, errorObject)
    return {
        id = self.testCount,
        Name = {testCaseName},
        FailureType = {'Assertion'},
        Location =
            {
                File = {errorObject.source},
                Line = {errorObject.line},
            },
        Message = {errorObject.message},
    };
end

function XmlListenerAlaCppUnitXmlOutputter:addSuccessful(testCaseName)
    self.testCount = self.testCount + 1;
    table.insert(self.reportContent.SuccessfulTests, xml.str(self:succesfullTestInfo(testCaseName), 2, 'Test'));
end

function XmlListenerAlaCppUnitXmlOutputter:addIgnore(testCaseName)
    self.testCount = self.testCount + 1;
    table.insert(self.reportContent.IgnoredTests, xml.str(self:succesfullTestInfo(testCaseName), 2, 'IgnoredTest'));
end

function XmlListenerAlaCppUnitXmlOutputter:addFailure(testCaseName, errorObject)
    self.testCount = self.testCount + 1;
    table.insert(self.reportContent.FailedTests, xml.str(self:notSuccesfullTestInfo(testCaseName, errorObject), 2, 'FailedTest'));
end

function XmlListenerAlaCppUnitXmlOutputter:addError(testCaseName, errorObject)
    self.testCount = self.testCount + 1;
    table.insert(self.reportContent.ErrorTests, xml.str(self:notSuccesfullTestInfo(testCaseName, errorObject), 2, 'ErrorTest'));
end

function XmlListenerAlaCppUnitXmlOutputter:startTest(testCaseName)
end

function XmlListenerAlaCppUnitXmlOutputter:endTest(testCaseName)
end

function XmlListenerAlaCppUnitXmlOutputter:startTests()
    self.reportContent =
    {
        FailedTests = {},
        SuccessfulTests = {},
        ErrorTests = {},
        IgnoredTests = {},
        Statistics = {},
    };
    self.testCount = 0;
end

function XmlListenerAlaCppUnitXmlOutputter:endTests()
    if not self.xmlFilePath then
        self:outputMessage('Wrong setting xml report file path. Using default path.');
        self.xmlFilePath = defaultXmlReportPath;
    end

    self:outputMessage('Begin xml test report "'..self.xmlFilePath..'" creation...\n');

    local hXml, errMsg = io.open(self.xmlFilePath, 'w');
    if not hXml then
        error('Cannot create xml report file "' .. self.xmlFilePath .. '": ' .. errMsg .. '\n', 0);
    end

    hXml:write("<?xml version=\"1.0\"?>\n<!-- file \"", self.xmlFilePath, "\", generated by XmlListenerAlaCppUnitXmlOutputter -->\n\n")
    hXml:write('<?xml-stylesheet type="text/xsl" href="report.xsl"?>');
    hXml:write('<TestRun>\n');

    hXml:write(' <FailedTests>\n');
    hXml:write(table.concat(self.reportContent.FailedTests));
    hXml:write(' </FailedTests>\n');

    hXml:write(' <ErrorTests>\n');
    hXml:write(table.concat(self.reportContent.ErrorTests));
    hXml:write(' </ErrorTests>\n');

    hXml:write(' <IgnoredTests>\n');
    hXml:write(table.concat(self.reportContent.IgnoredTests));
    hXml:write(' </IgnoredTests>\n');

    hXml:write(' <SuccessfulTests>\n');
    hXml:write(table.concat(self.reportContent.SuccessfulTests));
    hXml:write(' </SuccessfulTests>\n');

    hXml:write(
        xml.str(
        {
            Tests = {self.testCount},
            FailuresTotal = {#self.reportContent.FailedTests + #self.reportContent.ErrorTests},
            Errors = {#self.reportContent.ErrorTests},
            Ignores = {#self.reportContent.IgnoredTests},
            Failures = {#self.reportContent.FailedTests},
        }, 1, 'Statistics')
    );

    hXml:write('</TestRun>\n');
    hXml:flush();
    hXml:close();

    self:outputMessage('Xml test report "'..self.xmlFilePath..'" creation finished succesfully\n');
end

function XmlListenerAlaCppUnitXmlOutputter:outputMessage(message)
    io.write(message);
    io.output():flush();
end
