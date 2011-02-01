local fs = require('filesystem')
local testRunner = require('testunit.test_runner')
local testListeners = require('testunit.test_listeners')

-- test observer alone, because 'run' function may be called multiple times in one test run
local testObserver = testRunner.TestObserver:new()
testObserver:addTestListener(testListeners.TextTestProgressListener:new())

function run(path)
    testRunner.loadTestContainers{fs.canonizePath(path)}
    testRunner.runAllTestCases(testObserver)
end