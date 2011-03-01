local fs = require('filesystem')
local testRunner = require('testunit.test_runner')

-- test observer alone, because 'run' function may be called multiple times in one test run
local testObserver = testRunner.TestResultHandlerList:new()

if testResultHandler then
    testObserver:addHandler(testResultHandler)
end

function run(path)
    local workingDir = fs.dirname(path)
    lfs.chdir(workingDir)
    
    testRunner.loadTestUnitEngines{'cppunit', 'testunit.luaunit'};
    testRunner.loadTestContainers{fs.canonizePath(path)}
    testRunner.runAllTestCases(testObserver)
end