local lfs = require "yunit.lfs"
local fs = require "yunit.filesystem"
local testRunner = require "yunit.test_runner"
local testResultHandlers = require "yunit.test_result_handlers"

local usedLtueArray = {}

--[=[ 
    use this function to control what LTUE need to load and use, i.e. for usage only 'yunit.luaunit' run:
    lua -l yunit.work_in_scite -l yunit.default_test_run -e "use{'yunit.luaunit'}" -e "run[[test.t.lua]]"
    in command line
--]=]
function use(ltueArray)
    usedLtueArray = ltueArray
end

--[=[ 
    @param[in] inArg Maybe: 
                     1) path to test container
                     2) path of directory with test containers (recursive search)
                     3) table with elements from item 1, 2, 3
--]=]
function run(inArg)
    if nil == inArg then
        error('not nill expected as argument, but was one')
        return
    end

    local runner = testRunner.TestRunner:new()

    runner:addResultHandler(testResultHandlers.EstimatedTime:new())
    
    if testResultHandler then
        runner:addResultHandler(testResultHandler)
    end

    runner:addLoadtHandler(testResultHandlers.TextLoadTestContainerHandler:new())
    
    local listOfUsedLtueWasNotSpecifiedInCommandLine = not next(usedLtueArray)
    
    if listOfUsedLtueWasNotSpecifiedInCommandLine then
        runner:loadLtue('yunit.luaunit')
        runner:loadLtue('yunit.cppunit')
    else
        for _, ltueName in ipairs(usedLtueArray) do
            runner:loadLtue(ltueName)
        end
    end

    local fixFailed = testResultHandlers.FixFailed:new()
    runner:addResultHandler(fixFailed)
    runner:addLoadtHandler(fixFailed)

    local function handleArg(arg)
        if 'string' == type(arg) then
            local path = arg

            if not fs.isExist(path) then
                error('receive path to unexist file/directory: "' .. path .. '"')
                return
            elseif fs.isDir(path) then
                runner:runTestContainersFromDir(path)
            elseif fs.isFile(path) then
                runner:runTestContainer(path)
            else
                error('receive path to unknown file system object type (not file and not directory): "' .. path .. '"')
                return
            end
        elseif 'table' == type(arg) then
            for _, path in pairs(arg) do
                handleArg(path)
            end
        else
            error('table or string expected, but was %s', type(arg))
            return
        end
    end

    runner:onTestsBegin()
    handleArg(inArg)
    runner:onTestsEnd()

    if not fixFailed:passed() then
        print(fixFailed:message())
        io.stdout:flush()
        io.stderr:flush()
        os.exit(-1)
    end
end
