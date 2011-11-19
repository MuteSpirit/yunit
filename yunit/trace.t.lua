local ytrace = require "yunit.trace"

function traceback_message()
    local expectedMessage = "test error message"
    local function step()
        error(expectedMessage)
    end
    
    local rc, traceback = xpcall(step, ytrace.traceback)
    local stepInfo = debug.getinfo(step, "Sl")
    
    areEq(string.sub(stepInfo.source, 2), traceback.error.source)
    areEq(stepInfo.linedefined + 1, traceback.error.line)
    areEq(expectedMessage, traceback.error.message)
end

function traceback_stack_steps_use()
    local function step2()
        error("step2")
    end
    local function step1()
        step2()
    end

    local rc, traceback = xpcall(step1, ytrace.traceback)
    
    isTrue(#traceback.stack >= 3)

    areEq("=[C]",             traceback.stack[1].source)
    areEq(-1,                 traceback.stack[1].line)
    areEq("function 'error'", traceback.stack[1].funcname)

    local step2info = debug.getinfo(step2, "Sl")
    areEq(step2info.source,          traceback.stack[2].source)
    areEq(step2info.linedefined + 1, traceback.stack[2].line)
    areEq("function 'step2'",         traceback.stack[2].funcname)

    local step1info = debug.getinfo(step1, "Sl")
    areEq(step1info.source,             traceback.stack[3].source)
    areEq(step1info.linedefined + 1,    traceback.stack[3].line)
    isTrue(string.find(traceback.stack[3].funcname, ":" .. step1info.linedefined))
end
