local ytrace = require'yunit.trace'
testResultHandler = require('yunit.test_result_handlers').TextTestProgressHandler:new()
local toOutput = testResultHandler.outputMessage
testResultHandler.outputMessage = function (self, msg)
 ytrace.trace(msg)
 toOutput(self, msg)
end
