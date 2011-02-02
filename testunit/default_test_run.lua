local fs = require('filesystem')
local testRunner = require('testunit.test_runner')

-- test observer alone, because 'run' function may be called multiple times in one test run
local testObserver = testRunner.TestObserver:new()

testObserver:addTestListener(testListener)

function run(path)
    local workingDir = fs.dirname(path)
    lfs.chdir(workingDir)
    
    testRunner.loadTestContainers{fs.canonizePath(path)}
    testRunner.runAllTestCases(testObserver)
end