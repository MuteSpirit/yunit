local _M = {}
local _Mmt = {__index = _G}
setmetatable(_M, _Mmt)
local _G = _M

local testRunner = require "yunit.test_runner"
local ytrace = require "yunit.trace"

------------------------------------------------------
TextTestProgressHandler = testRunner.TestResultHandler:new()
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
    return tostring(errorObject.source) .. ":" .. tostring(errorObject.line) .. ": " .. tostring(errorObject.message)
end

function TextTestProgressHandler:msvcErrorLine(errorObject)
    return tostring(errorObject.source) .. "(" .. tostring(errorObject.line) .. ") : " .. tostring(errorObject.message)
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
    io.stdout:write(message)
    ytrace.trace(message)
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
    if str and '' ~= str then 
        table.insert(res, str)
    end

    self:outputMessage(table.concat(res, '\n'));
end

function TextTestProgressHandler:addFailedTestsMessageLines(res, tests)
    local testName, errorObject

    for _, record in ipairs(tests) do
        testName, errorObject = record[1], record[2]

        local funcName = ''
        if errorObject.func and '' ~= errorObject.func then
            funcName = ' (' ..  errorObject.func .. ')'
        end
        
        table.insert(res, errorObject.source .. '::' .. testName .. funcName)
        table.insert(res, '\t' .. self:editorSpecifiedErrorLine(errorObject))

        if errorObject.traceback then
            for _, step in ipairs(errorObject.traceback) do
                local sourcePathWithoutFirstSymbol = string.sub(step.source, 2)
                table.insert(res, '\t' .. self:editorSpecifiedErrorLine{source = sourcePathWithoutFirstSymbol, line = step.line, message = step.funcname})
            end
        end
        
        table.insert(res, '------------------------------------------------------------------------------------------------------')
    end;
end

function TextTestProgressHandler:totalErrorStr()
    if #self.tableWithErrors == 0 then
        return ''
    end
    
    local res = {'----Errors----'}
    self:addFailedTestsMessageLines(res, self.tableWithErrors)
    table.insert(res, '') -- for one more '\n'
    return table.concat(res, '\n')
end

function TextTestProgressHandler:totalFailureStr()
    if #self.tableWithFailures == 0 then
        return ''
    end

    local res = {'----Failures----'}
    self:addFailedTestsMessageLines(res, self.tableWithFailures)
    table.insert(res, '') -- for one more '\n'
    return table.concat(res, '\n')
end

function TextTestProgressHandler:totalIgnoreStr()
    if #self.tableWithIgnores == 0 then
        return ''
    end

    local res = {'----Ignored----'}
    local testName
    
    for _, record in ipairs(self.tableWithIgnores) do
        testName, errorObject = record[1], record[2]
        table.insert(res, self:editorSpecifiedErrorLine(errorObject) ..  testName)
    end;

    table.insert(res, '') -- for ending \n

    return table.concat(res, '\n')
end


--------------------------------------------------------------------------------------------------------------------------------------------
SciteTextTestProgressHandler = TextTestProgressHandler:new()
--------------------------------------------------------------------------------------------------------------------------------------------

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
    io.write(message)
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

------------------------------------------------------
FixFailed = {}

local function fixFailedIndexMetaMethod(table, idx)
    return rawget(FixFailed, idx) or rawget(TestResultHandler, idx) or rawget(LoadTestContainerHandler, idx) 
end

function FixFailed:new()
    local o =
    {
        thereIsFailureTest_ = false,
        thereIsAlmostOneTest_ = false,
        thereIsAlmostOneNotLoadedTestContainer_ = false,
    };
    setmetatable(o, self)
    self.__index = fixFailedIndexMetaMethod
    return o
end

function FixFailed:passed()
    return self.thereIsAlmostOneTest_ and not self.thereIsFailureTest_ and not self.thereIsAlmostOneNotLoadedTestContainer_
end

function FixFailed:message()
    local msg = "Test run executed with error(s): "
    if not self.thereIsAlmostOneTest_ then
        msg = msg .. 'no one test has been run;'
    end
    
    if self.thereIsFailureTest_ then
        msg = msg .. ' almost one test has been failed;'
    end
    
    if self.thereIsAlmostOneNotLoadedTestContainer_ then
        msg = msg .. ' almost one test container has not been loaded'
    end
    
    return msg
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

function FixFailed:onLtueNotFound()
    self.thereIsAlmostOneNotLoadedTestContainer_ = true
end

function FixFailed:onLoadError()
    self.thereIsAlmostOneNotLoadedTestContainer_ = true
end

------------------------------------------------------
EstimatedTime = testRunner.TextTestProgressHandler:new()

function EstimatedTime:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function EstimatedTime:onTestsBegin()
    self.testsHasBeganAt_ = os.time()
end

function EstimatedTime:onTestsEnd()
    self.testsHasEndAt_ = os.time()
    local estimatedTime = os.difftime(self.testsHasEndAt_, self.testsHasBeganAt_)
    self:outputMessage('\nTest time = ' .. tostring(estimatedTime) .. ' sec\n')
end

--------------------------------------------------------------------------------------------------------------------------------------------
NetbeansTextTestProgressHandler = TextTestProgressHandler:new()
--------------------------------------------------------------------------------------------------------------------------------------------
function NetbeansTextTestProgressHandler:editorSpecifiedErrorLine(errorObject)
    return tostring(errorObject.source) .. ":" .. tostring(errorObject.line) .. ":0: " .. tostring(errorObject.message)
end

------------------------------------------------------
TextLoadTestContainerHandler = testRunner.LoadTestContainerHandler:new()

function TextLoadTestContainerHandler:new()
    local o = 
    {
        notLoadedTestContainers_ = {};
        loadedTestContainers_ = {};
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function TextLoadTestContainerHandler:outputMessage(message)
    io.stdout:write(message)
    ytrace.trace(message)
end

function TextLoadTestContainerHandler:onLtueNotFound(info)
    table.insert(self.notLoadedTestContainers_, info)
end

function TextLoadTestContainerHandler:onLoadError(info)
    table.insert(self.notLoadedTestContainers_, info)
end

function TextLoadTestContainerHandler:onLoadSuccess(info) -- usual 'info' is {path = testContainerPath, numOfTests = #tests}
    table.insert(self.loadedTestContainers_, info)
end

function TextLoadTestContainerHandler:onLoadEnd()
    local msg = {}

    local numberOfNotLoaded = #self.notLoadedTestContainers_
    if numberOfNotLoaded > 0 then
        table.insert(msg, string.format('Could not load %d test container%s:', numberOfNotLoaded, 1 == numberOfNotLoaded and '' or 's'))
        for _, info in pairs(self.notLoadedTestContainers_) do
            local errMsg = info.message or 'LTUE not found'
            table.insert(msg, '\t'..info.path..': '..errMsg)
        end
        table.insert(msg, '')
    end

    local numberOfLoaded = #self.loadedTestContainers_
    if numberOfLoaded > 0 then
        table.insert(msg, string.format('There %s %d test container%s loaded:', 1 == numberOfLoaded and 'was' or 'were', numberOfLoaded, 1 == numberOfLoaded and '' or 's'))
        for _, info in pairs(self.loadedTestContainers_) do
            table.insert(msg, string.format('\t%s (%d test%s)', info.path, info.numOfTests, 1 == info.numOfTests and '' or 's'))
        end
        table.insert(msg, '')
    end

    if next(msg) then
        self:outputMessage(table.concat(msg, '\n'))
    end
end


return _M
