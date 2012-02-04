-- keep it as separate file for backward compatible with old version of yUnit
require "yunit.default_test_run"

local aux = require "yunit.aux"

local proccesses = aux.allProccesses()
local curProcParentPid = proccesses[aux.pid()].ppid 

local proc = proccesses[curProcParentPid]
while proc 
do
    if string.find(proc.exe, 'devenv.exe') then
        require "yunit.work_in_vs"
        break;
    end

    proc = proccesses[proc.ppid]
end

