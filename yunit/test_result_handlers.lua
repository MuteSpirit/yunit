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
        reportPath = defaultReportPath,
    };

------------------------------------------------------
function XmlTestResultHandler:new()
    local o =
    {
        tableWithSuccesses = {},
        tableWithIgnores = {},
        tableWithErrors = {},
        tableWithFailures = {},
        reportPath = defaultReportPath,
    };
    setmetatable(o, self);
    self.__index = self;
    return o;
end

function XmlTestResultHandler:outputMessage(message)
    io.write(message);
    io.output():flush();
end

function TextTestProgressHandler:onTestSuccessfull(testCaseName)
    table.insert(self.tableWithSuccesses, {testCaseName});
end

function TextTestProgressHandler:onTestFailure(testCaseName, errorObject)
    table.insert(self.tableWithFailures, {testCaseName, errorObject});
end

function TextTestProgressHandler:onTestError(testCaseName, errorObject)
    table.insert(self.tableWithErrors, {testCaseName, errorObject});
end

function TextTestProgressHandler:onTestIgnore(testCaseName, errorObject)
    table.insert(self.tableWithIgnores, {testCaseName, errorObject});
end

function XmlTestResultHandler:onTestsBegin()
    self.tableWithSuccesses = {}
    self.tableWithIgnores = {}
    self.tableWithErrors = {}
    self.tableWithFailures = {}
end

--~ function XmlTestResultHandler:succesfullTestInfo(testCaseName)
--~     return {
--~         id = self.testCount,
--~         Name = {testCaseName},
--~     };
--~ end

--~ function XmlTestResultHandler:notSuccesfullTestInfo(testCaseName, errorObject)
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

function XmlTestResultHandler:onTestsEnd()
    self:outputMessage('Make XML report "' .. self.reportPath .. '"...');

    local f, errMsg = io.open(self.reportPath, 'w')
    if not f then
        self:outputMessage('Cannot create xml report file "' .. self.reportPath .. '": ' .. errMsg .. '\r\n', 0)
        return
    end

    repLines = {}
    table.insert(repLines, '<?xml version="1.0"?>'
    table.insert(repLines, '<!-- File has been generated by XmlTestResultHandler -->')
    table.insert(repLines, '')
    table.insert(repLines, '<TestRun>')

    table.insert(repLines, '\t<FailedTests>');
--~     table.insert(repLines, table.concat(self.reportContent.FailedTests));
    table.insert(repLines, '\t</FailedTests>');

    table.insert(repLines, '\t<ErrorTests>');
--~     table.insert(repLines, table.concat(self.reportContent.ErrorTests));
    table.insert(repLines, '\t</ErrorTests>');

    table.insert(repLines, '\t<IgnoredTests>');
--~     table.insert(repLines, table.concat(self.reportContent.IgnoredTests));
    table.insert(repLines, '\t</IgnoredTests>');

    table.insert(repLines, '\t<SuccessfulTests>');
--~     table.insert(repLines, table.concat(self.reportContent.SuccessfulTests));
    table.insert(repLines, '\t</SuccessfulTests>');

--~     table.insert(repLines, 
--~         xml.str(
--~         {
--~             Tests = {self.testCount},
--~             FailuresTotal = {#self.reportContent.FailedTests + #self.reportContent.ErrorTests},
--~             Errors = {#self.reportContent.ErrorTests},
--~             Ignores = {#self.reportContent.IgnoredTests},
--~             Failures = {#self.reportContent.FailedTests},
--~         }, 1, 'Statistics')
--~     );

    table.insert(repLines, '</TestRun>');
    f:write(table.concat(repLines, '\r\n'));
    f:close();

    self:outputMessage(' done\r\n');
end

