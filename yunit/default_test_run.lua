local lfs = require "yunit.lfs"
local testRunner = require "yunit.test_runner"
local testResultHandlers = require "yunit.test_result_handlers"

function runFrom(dirPaths)
    local runner = testRunner.TestRunner:new()

    local fixFailed = testResultHandlers.FixFailed:new()
    runner:addResultHandler(fixFailed)

    if testResultHandler then
        runner:addResultHandler(testResultHandler)
    end

    runner:loadLtue('yunit.luaunit')
    runner:loadLtue('yunit.cppunit')
    
    for _, dirPath in pairs(dirPaths) do
        runner:lookTestsAt(dirPath)
    end
    
    runner:runAll()

    if not fixFailed:passed() then
        print("Test run executed with fail(es) and/or error(s)")
        os.exit(-1)
    end
end

function run(testContainerPath)
    local runner = testRunner.TestRunner:new()

    local fixFailed = testResultHandlers.FixFailed:new()
    runner:addResultHandler(fixFailed)

    if testResultHandler then
        runner:addResultHandler(testResultHandler)
    end

    runner:loadLtue('yunit.luaunit')
    runner:loadLtue('yunit.cppunit')
    
    runner:runTestsOf(testContainerPath)

    if not fixFailed:passed() then
        print("Test run executed with fail(es) and/or error(s)")
        os.exit(-1)
    end
end
