require'trace'
testListener = require('testunit.test_listeners').TextTestProgressListener:new()
testListener.outputMessage = trace