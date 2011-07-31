local fs = require('yunit.filesystem')
local testRunner = require('yunit.test_runner')
--~ local minidump = require('minidump')

-- test observer alone, because 'run' function may be called multiple times in one test run
local testObserver = testRunner.TestResultHandlerList:new()

if testResultHandler then
    testObserver:addHandler(testResultHandler)
end

local fixFailedResHandler = require('yunit.test_result_handlers').FixFailed:new()
testObserver:addHandler(fixFailedResHandler)

--~ if testResultHandler2 then
--~     testObserver:addHandler(testResultHandler2)
--~ end

--~ minidump.setCrashHandler()

function run(path)
    local workingDir = fs.dirname(path)
    lfs.chdir(workingDir)

    io.stdout:setvbuf("no")
    io.stderr:setvbuf("no")
    
    testRunner.loadTestUnitEngines{'yunit.luaunit'}
    testRunner.loadTestContainers{fs.canonizePath(path)}
    testRunner.runAllTestCases(testObserver)
    
    if not fixFailedResHandler:passed() then
        error("Test run has not been passed")
    end
end