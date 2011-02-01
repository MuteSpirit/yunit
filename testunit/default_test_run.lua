local fs = require('filesystem')
local testRunner = require('testunit.test_runner')

local testObserver = testRunner.TestObserver:new()

local testListeners = require('testunit.test_listeners')
testObserver:addTestListener(testListeners.TextTestProgressListener:new())

function run(path)
    testRunner.loadTestContainers{fs.canonizePath(path)}
    testRunner.runAllTestCases(testObserver)
end