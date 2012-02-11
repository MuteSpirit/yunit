-- keep it as separate file for backward compatible with old version of yUnit
require "yunit.default_test_run"

local aux = require "yunit.aux"

require "yunit.work_in_netbeans"

--[[
local proccesses = aux.allProccesses()
print(proccesses, #proccesses)

local curProcParentPid = proccesses[aux.pid()].ppid 
print(aux.pid(), proccesses[aux.pid()], proccesses[aux.pid()]['ppid'])

local proccesses = aux.allProccesses()
print(proccesses, #proccesses)

local curProcParentPid = proccesses[aux.pid()].ppid 

local proc = proccesses[curProcParentPid]
while proc 
do
    local exe = string.lower(proc.exe)
    if string.find(exe, 'devenv.exe') then
        require "yunit.work_in_vs"
        break;
    elseif string.find(exe, 'netbeans') then
        require "yunit.work_in_netbeans"
        break;
    elseif string.find(exe, 'scite') then
        require "yunit.work_in_scite"
        break;
    elseif string.find(exe, 'cmd.exe') then
        require "yunit.work_in_cmd"
        break;
    elseif string.find(exe, 'bash') then
        require "yunit.work_in_bash"
        break;
    end

    proc = proccesses[proc.ppid]
end
--]]
