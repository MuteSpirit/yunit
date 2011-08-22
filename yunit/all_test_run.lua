local lfs = require('lfs')
local testRunner = require('yunit.test_runner')
local testResultHandlers = require('yunit.test_result_handlers')

function runFrom(dirPath)
    local curDir = lfs.currentdir()
    lfs.chdir(dirPath)

    local runner = testRunner.TestRunner:new()

    local fixFailed = testResultHandlers.FixFailed:new()
    runner:addResultHandler(fixFailed)

    if testResultHandler then
        runner:addResultHandler(testResultHandler)
    end

    runner:loadLtue('yunit.luaunit')
    runner:loadLtue('cppunit')
    runner:lookTestsAt(dirPath)
    runner:runAll()
    
    lfs.chdir(curDir)

    if not fixFailed:passed() then
        error("Test run executed with fail(es) and/or error(s)")
    end
end

