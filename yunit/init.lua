-- keep it as separate file for backward compatible with old version of yUnit
require "yunit.default_test_run"

local aux = require "yunit.aux"

local proccesses = aux.allProccesses()
local curProcParentPid = proccesses[aux.pid()].ppid 

local proc = proccesses[curProcParentPid]
while proc 
do
    local exe = string.lower(proc.exe)
    if string.find(exe, 'devenv.exe') then
        require "yunit.work_in_vs"
        break;
    elseif string.find(exe, 'scite') or string.find(exe, 'sc1') then
        require "yunit.work_in_scite"
        break;
    end

    proc = proccesses[proc.ppid]
end

