-- keep it as separate file for backward compatible with old version of yUnit
require "yunit.default_test_run"

local aux = require "yunit.aux"
local fs = require "yunit.filesystem"

if 'win' == fs.whatOs() then
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
else
    local pid = aux.pid()
    local ppid = aux.ppid(pid)
    local reachedInitProcess = nil == ppid or 1 == ppid
    
    while not reachedInitProcess
    do
        local exe = string.lower(aux.exePath(pid))
        if string.find(exe, 'devenv.exe') then
            require "yunit.work_in_vs"
            break;
        elseif string.find(exe, 'netbeans') then
            require "yunit.work_in_netbeans"
            break;
        elseif string.find(exe, 'scite') then
            require "yunit.work_in_scite"
            break;
        end

        pid = ppid
        ppid = aux.ppid(pid)
        reachedInitProcess = nil == ppid or 1 == ppid
    end

    if reachedInitProcess then
        require "yunit.work_in_scite"
    end
end

