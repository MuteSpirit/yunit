local testRunner = require('testunit.test_runner')

-- test observer alone, because 'run' function may be called multiple times in one test run
local testObserver = testRunner.TestObserver:new()

local testListeners = require('testunit.test_listeners')
testObserver:addTestListener(testListeners.TextTestProgressListener:new())

function run(path)
    testRunner.loadTestContainers{path}
    testRunner.runAllTestCases(testObserver)
end