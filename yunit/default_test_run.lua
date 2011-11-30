local lfs = require "yunit.lfs"
local testRunner = require "yunit.test_runner"
local testResultHandlers = require "yunit.test_result_handlers"

local usedLtueArray = {}

--[=[ use this function to control what LTUE need to load and use, i.e. for usage only 'yunit.luaunit' run:
lua -l yunit.work_in_scite -l yunit.default_test_run -e "use{'yunit.luaunit'}" -e "run[[test.t.lua]]"
in command line
--]=]
function use(ltueArray)
    usedLtueArray = ltueArray
end

local makeDefaultTestRunner

function runFrom(dirPaths)
    local runner = makeDefaultTestRunner()
    local fixFailed = testResultHandlers.FixFailed:new()
    runner:addResultHandler(fixFailed)
    runner:addLoadtHandler(fixFailed)

    for _, dirPath in pairs(dirPaths) do
        runner:lookTestsAt(dirPath)
    end
    
    runner:runAll()

    if not fixFailed:passed() then
        print(fixFailed:message())
        os.exit(-1)
    end
end

function run(testContainerPath)
    local runner = makeDefaultTestRunner()
    local fixFailed = testResultHandlers.FixFailed:new()
    runner:addResultHandler(fixFailed)
    runner:addLoadtHandler(fixFailed)
    
    runner:runTestsOf(testContainerPath)

    if not fixFailed:passed() then
        print("Test run executed with fail(es) and/or error(s)")
        os.exit(-1)
    end
end

makeDefaultTestRunner = function()
    local runner = testRunner.TestRunner:new()

    runner:addResultHandler(testResultHandlers.EstimatedTime:new())
    
    if testResultHandler then
        runner:addResultHandler(testResultHandler)
    end
    
    local listOfUsedLtueWasNotSpecifiedInCommandLine = not next(usedLtueArray)
    
    if listOfUsedLtueWasNotSpecifiedInCommandLine then
        runner:loadLtue('yunit.luaunit')
        runner:loadLtue('yunit.cppunit')
    else
        for _, ltueName in ipairs(usedLtueArray) do
            runner:loadLtue(ltueName)
        end
    end
    
    return runner
end
