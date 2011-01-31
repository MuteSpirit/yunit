local fs = require('filesystem')
local testRunner = require('testunit.test_runner')
local testListeners = require('testunit.test_listeners')

local testObserver = testRunner.TestObserver:new()
testObserver:addTestListener(testListeners.TextTestProgressListener:new())

function run(path)
    testRunner.loadTestContainers{fs.canonizePath(path)}
    testRunner.runAllTestCases(testObserver)
end