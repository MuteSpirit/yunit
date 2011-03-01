require'trace'
testResultHandler = require('testunit.test_listeners').TextTestProgressListener:new()
testResultHandler.outputMessage = trace