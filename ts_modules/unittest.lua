--[[ function for som unit tests. Define function in global name space. ]]
require("lfs")


--[[ Messageas ]]
function flush_message(...)
    io.write(...)
    io.write("\n")
    io.output():flush()
end

local function flush_message2(...)
    io.write(...)
    io.write("\n")
    io.output():flush()
end

function assert_message(msg, level)
    flush_message("Test assertion failed: ", select(2, pcall(error, msg, level or 4)))
end


--[[ lfs utilities ]]
function rmtree(path, verbose)
    local result, errmsg
    if string.find(path, "[\\/]$") then
        path = string.sub(path, 1, -2)
    end
    local mode = lfs.attributes (path, "mode")
    if mode == "directory" then
        local directories, files = {}, {}
        for entry in lfs.dir(path) do
            mode = lfs.attributes (path .. "\\" .. entry, "mode")
            if mode == "directory" then
                if entry ~= "." and entry ~= ".." then
                    directories[#directories + 1] = entry
                end
            elseif mode == "file" then
                files[#files + 1] = entry
            else
                error("can't delete " .. (mode or "not existed") .. " '" .. path .. "\\" .. entry .. "'")
            end
        end
        for _, entry in ipairs(directories) do
            rmtree(path .. "\\" .. entry, verbose)
        end
        for _, entry in ipairs(files) do
            if verbose then
                io.write("delete file '" .. path .. "\\" .. entry .. "'\n")
            end
            result, errmsg = os.remove(path .. "\\" .. entry)
            if not result then
                error("can't remove file '" .. path .. "\\" .. entry .. "': " .. errmsg)
            end
        end
        if verbose then
            io.write("delete directory '" .. path .. "'\n")
        end
        result, errmsg = lfs.rmdir(path)
        if not result then
            error("can't remove directory '" .. path .. "': " .. errmsg)
        end
    else
        error("can't delete " .. (mode or "not existed") .. " (" .. path .. ")")
    end
end

--[[ Simple assertions ]]
function assert_pass(func, ...)
    local t = type(func)
    if t ~= "function" then
        assert_message("expected a function but was a " .. t)
        return
    end
    local result = { pcall(func, ...) }
    if not result[1] then
        if result[2] == nil then result[2] = "nil" end
        assert_message("no error expected but error was: " .. tostring(result[2]))
        return
    end
    return unpack(result, 2)
end

function assert_error(errmsg, func, ...)
    local t = type(func)
    if t ~= "function" then
        assert_message("expected a function but was a " .. t)
        return
    end
    local status, em = pcall(func, ...)
    if status then
        assert_message("error expected but no error occurred")
        return
    end
    if errmsg ~= em then
        assert_message("expected error message '" .. errmsg .. "', but was a '" .. em .. "'")
    end
end

function assert_equal(expected, actual)
    if expected ~= actual then
        if expected == nil then expected = "nil" end
        if actual == nil then actual = "nil" end
        assert_message("expected '" .. tostring(expected) .. "' but was a '" .. tostring(actual) .. "'" )
        return false
    end
    return true
end


--[[ test files utilities ]]
function preparedir(path)
    if string.find(path, "[\\/]$") then
        path = string.sub(path, 1, -2)
    end
    if not lfs.attributes (path, "mode") then
        assert(lfs.mkdir(path))
    end
end

function preparefile(name)
    return
    function (text) 
        local file = assert(io.open(name, "w"))
        file:write(text or "")
        file:close()
    end
end


--[[ file assertions ]]
function assert_file_exists(path)
    if lfs.attributes (path, "mode") ~= "file" then
        assert_message("expected file '" .. path .. "' exists but it dasn't")
    end
end

function assert_file_not_exists(path)
    if lfs.attributes (path, "mode") == "file" then
        assert_message("expected file '" .. path .. "' dasn't exists but it exist")
    end
end

function assert_file_equal(name)
    return
    function (text) 
        local file, message = io.open(name, "r")
        if not file then
            assert_message("expected file '" .. name .. "' was not opened: " .. message)
            return
        end
        local filetext = file:read("*a")
        file:close()
        if filetext ~= text then
            assert_message("expected text:")
            flush_message(text)
            flush_message("but was:")
            flush_message(filetext)
        end
    end
end

function assert_file_match(name)
    return
    function (text) 
        local file, message = io.open(name, "r")
        if not file then
            assert_message("expected file '" .. name .. "' was not opened: " .. message)
            return
        end
        local filetext = file:read("*a")
        file:close()
        if not string.match(filetext, text) then
            assert_message("expected pattern:")
            flush_message(text)
            flush_message("but was a:")
            flush_message(filetext)
        end
    end
end

function assert_exec(retcode)
    return
    function (cmd)
        local rc = os.execute(cmd)
        if rc ~= retcode then
            assert_message("expected return code " .. retcode .. " but was a " .. rc)
        end
    end
end
