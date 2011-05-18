local fs = require('filesystem')
local luaExt = require('lua_ext')

local ignoredFiles = 
{
    'atd.t.lua',
    'lopt.t.lua',
    'clean.t.lua',
};

local function isTestContainer(path, state)
    if fs.isFile(path) and string.find(path, '%.t%.lua$') then
        return true;
    end
    return false;
end

local function isIgnored(path, state)
    local name, ext = fs.filename(path)
    if luaExt.findValue(ignoredFiles, name .. '.' .. ext) then
        return false
    end
    return true
end

local function complexFilter(path, state)
    return isTestContainer(path, state) and isIgnored(path, state)
end

local function savePath(path, state)
    table.insert(state.paths, path);
end

local path = lfs.currentdir() .. '\\..\\';
local adtArg = {handler = savePath, filter = complexFilter, state = {paths = {}}, recursive = true};
fs.applyOnFiles(path, adtArg);

package.path='./?.lua;./?/init.lua;../ts_modules/?.lua;D:/_portable/lua/5.1/lua/?.lua;D:/_portable/lua/5.1/lua/?/init.lua;../?.lua;../?/init.lua;' .. package.path;
package.cpath='./?.dll;D:/_portable/lua/5.1/lua/?.dll;D:/_portable/lua/5.1/clibs/?.dll;../_bin/?.dll;../_bin/?.so;' .. package.cpath;
local testRunner = require('yunit.test_runner');
local testResultHandlers = require('yunit.test_result_handlers');
testRunner.loadTestContainers(adtArg.state.paths);
local testObserver = testRunner.TestResultHandlerList:new();
testObserver:addHandler(testResultHandlers.SciteTextTestProgressHandler:new());
testRunner.runAllTestCases(testObserver);