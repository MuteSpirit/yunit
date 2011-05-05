local fs = require('filesystem')
local testRunner = require('yunit.test_runner')
local minidump = require('minidump')

-- test observer alone, because 'run' function may be called multiple times in one test run
local testObserver = testRunner.TestResultHandlerList:new()

if testResultHandler then
    testObserver:addHandler(testResultHandler)
end

minidump.setCrashHandler()

function run(path)
    local workingDir = fs.dirname(path)
    lfs.chdir(workingDir)

    io.stdout:setvbuf("no")
    io.stderr:setvbuf("no")
    
    testRunner.loadTestUnitEngines{'cppunit', 'yunit.luaunit'}
    testRunner.loadTestContainers{fs.canonizePath(path)}
    testRunner.runAllTestCases(testObserver)
end