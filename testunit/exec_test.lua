package.cpath="../_bin/?.so" .. package.cpath;
local testRunner = require("test_runner");

local dllExt = testRunner.isWin() and "dll" or "so";
testRunner.loadTestDrivers
{
	"lua_test_sample.t.lua",
	"../_bin/cppunit.t."..dllExt,
};
local testObserver = testRunner.TestObserver:new();
testObserver:addTestListener(testRunner.TextTestProgressListener:new());
testRunner.runAllTestCases(testObserver);
