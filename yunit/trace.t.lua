local ytrace = require "yunit.trace"

function ltraceback_use_case()
    local function step2()
        error("step2")
    end
    local function step1()
        step2()
    end

    local rc, stackTraceback = xpcall(step1, ytrace.traceback)
    
    isTrue(string.find(stackTraceback.message, "trace%.t%.lua:5: step2"))
    
    for _, step in ipairs(stackTraceback.step) do
        print(step.source .. ':' .. step.line .. ':' .. tostring(step.funcname))
    end
    isTrue(#stackTraceback.step > 2)

    areEq("=[C]",             stackTraceback.step[1].source)
    areEq(-1,                 stackTraceback.step[1].line)
    areEq("function 'error'", stackTraceback.step[1].funcname)

    local step1info = debug.getinfo(step2, "Sl")
    areEq(step1info.source,          stackTraceback.step[2].source)
    areEq(step1info.linedefined + 1, stackTraceback.step[2].line)
    areEq("function 'step2'",            stackTraceback.step[2].funcname)

    local step2info = debug.getinfo(step1, "Sl")
    areEq(step2info.source,          stackTraceback.step[3].source)
    areEq(step2info.linedefined + 1, stackTraceback.step[3].line)
    isTrue(stackTraceback.step[3].funcname, step2info.source .. ":" .. step2info.linedefined))
end
