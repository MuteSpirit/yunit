--- @todo Сделать отдельную библиотеку yunit.dll, к-ая не линкуется ни с одной из библиотек Lua. Но имеет перенаправлять вызовы функций вида luaopen_yunit_lfs в вызов фукнций из соответствующей библиотеки yunit_lua_??.dll. Это естественней, т.к. на этапе компиляции, в настройках проекта (а значит прямо из CMake) можно задать имена библиотек, в к-ые нужно перенаправлять вызовы

local yunitLibOutName
if 'Lua 5.2' == _VERSION then
    yunitLibOutName = 'yunit_lua_52'
elseif 'Lua 5.1' == _VERSION then
    yunitLibOutName = 'yunit_lua_51'
else
    yunitLibOutName = 'yunit'
end

function loadSubModule(name)
    package.loaded['yunit.' .. name] = require(yunitLibOutName .. '.' .. name)
end

-- preload all C++ submodules
loadSubModule('aux')
loadSubModule('cppunit')
loadSubModule('lfs')
loadSubModule('mine')
loadSubModule('trace')

-- keep it as separate file for backward compatible with old version of yUnit
require "yunit.default_test_run"

local aux = require "yunit.aux"
local fs = require "yunit.filesystem"

if 'win' == fs.whatOs() then
    local proccesses = aux.allProccesses()

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
        end

        proc = proccesses[proc.ppid]
    end
else -- not Windows
    local pid = aux.pid()
    local ppid = aux.ppid(pid)
    local reachedInitProcess = nil == ppid or 1 == ppid
    
    while not reachedInitProcess
    do
        local exe = string.lower(aux.exePath(pid))
        if string.find(exe, 'netbeans') then
            require "yunit.work_in_netbeans"
            break;
        elseif string.find(exe, 'scite') then
            require "yunit.work_in_scite"
            break;
        elseif string.find(exe, 'bash') then
            require "yunit.work_in_bash"
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


--]=]