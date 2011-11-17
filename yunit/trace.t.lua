local ytrace = require "yunit.trace"

function ltraceback_use_case()
    local function step2()
        error("step2")
    end
    local function step1()
        step2()
    end

    local rc, stackTraceback = xpcall(step1, ytrace.traceback)
    
    areEq("step2", stackTraceback.message)
    
    local step1info = debug.getinfo(step1, "Sl")
    areEq(step1info.source,          stackTraceback.step[1].source)
    areEq(step1info.currentline + 1, stackTraceback.step[1].line)
    areEq(step1info.name,            stackTraceback.step[1].funcname)

    local step2info = debug.getinfo(step2, "Sl")
    areEq(step2info.source,          stackTraceback.step[2].source)
    areEq(step2info.currentline + 1, stackTraceback.step[2].line)
    areEq(step2info.name,            stackTraceback.step[2].funcname)
end