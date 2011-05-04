local _G = _G

--------------------------------------------------------------------------------------------------------------
module(...)
_G.setmetatable(_M, {__index = _G})
--------------------------------------------------------------------------------------------------------------

local testRunner = require("yunit.test_runner");
--~ require("LuaXML");
--~ local xml = xml;


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
        return errorObject.source .. ":" .. tostring(errorObject.line) .. ": " .. errorObject.message;
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

    message = message.."\t\t\tSuccessful:\t\t" .. tostring(#self.tableWithSuccesses) .. "\n";

    message = message.."\t\t\tTotal:\t\t" .. tostring(self:totalTestNum()) .. "\n";

    return message;
end

function TextTestProgressHandler:outputMessage(message)
    io.write(message);
    io.output():flush();
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

function TextTestProgressHandler:onTestBegin(testCaseName)
end

function TextTestProgressHandler:onTestEnd(testCaseName)
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

SciteTextTestProgressHandler.editorSpecifiedErrorLine = TextTestProgressHandler.sciteErrorLine--~ local defaultXmlReportPath = 'report.xml';

--~ ------------------------------------------------------
--~ XmlListenerAlaCppUnitXmlOutputter = testRunner.TestResultHandler:new{
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

--~ function XmlListenerAlaCppUnitXmlOutputter:onTestSuccessfull(testCaseName)
--~     self.testCount = self.testCount + 1;
--~     table.insert(self.reportContent.SuccessfulTests, xml.str(self:succesfullTestInfo(testCaseName), 2, 'Test'));
--~ end

--~ function XmlListenerAlaCppUnitXmlOutputter:onTestIgnore(testCaseName)
--~     self.testCount = self.testCount + 1;
--~     table.insert(self.reportContent.IgnoredTests, xml.str(self:succesfullTestInfo(testCaseName), 2, 'IgnoredTest'));
--~ end

--~ function XmlListenerAlaCppUnitXmlOutputter:onTestFailure(testCaseName, errorObject)
--~     self.testCount = self.testCount + 1;
--~     table.insert(self.reportContent.FailedTests, xml.str(self:notSuccesfullTestInfo(testCaseName, errorObject), 2, 'FailedTest'));
--~ end

--~ function XmlListenerAlaCppUnitXmlOutputter:onTestError(testCaseName, errorObject)
--~     self.testCount = self.testCount + 1;
--~     table.insert(self.reportContent.ErrorTests, xml.str(self:notSuccesfullTestInfo(testCaseName, errorObject), 2, 'ErrorTest'));
--~ end

--~ function XmlListenerAlaCppUnitXmlOutputter:onTestBegin(testCaseName)
--~ end

--~ function XmlListenerAlaCppUnitXmlOutputter:onTestEnd(testCaseName)
--~ end

--~ function XmlListenerAlaCppUnitXmlOutputter:onTestsBegin()
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

--~ function XmlListenerAlaCppUnitXmlOutputter:onTestsEnd()
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
