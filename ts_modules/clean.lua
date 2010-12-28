--[[ Clean utility ]]
assert(require("lfs"))
assert(require("lopt"))


--[[ Auxiliary Clean utility functions ]]
local function inform(message)
    io.write("Clean utility: " .. tostring(message) .. "\n")
    io.output():flush()
end


--[[ commands ]]
local function clean(extlist, directory, filename, verbose)
    -- prepare directory
    if string.find(directory, "[\\/]$") then
        directory = string.sub(directory, 1, -2)
    end
    -- prepare extensions table
    local extensions = {}
    for e in string.gmatch(extlist, "%.([^%.]*)") do
        extensions[e] = true
    end
    -- prepare file entries table
    local entries = {}
    for entry in lfs.dir(directory) do
        if lfs.attributes (directory .. "\\" .. entry, "mode") == "file" then
            entries[#entries + 1] = entry
        end
    end
    -- enumerate entries
    if verbose then
        inform("current directory is '" .. lfs.currentdir() .. "'")
    end
    for _, entry in ipairs(entries) do
        local pos, _, ext = string.find(entry, "%.([^%.]*)$", 2)
        if not pos then
            pos, ext = 0, ""
        end
        local name = string.sub(entry, 1, pos - 1)
        if not filename or filename == name then
            if extensions[ext] then
                if verbose then
                    inform("delete file '".. directory .. "\\" .. entry .. "'")
                end
                os.remove (directory .. "\\" .. entry)
            end
        end
    end
end

--[[ options ]]
local function onHelp()
    io.write (
        "clean.lua [options] extlist directory\n" ..
        "Options:\n" ..
        "\t-h\t\tprint this message and exit\n" ..
        "\t-v\t\tverbose output\n" ..
        "\t-n <name>\tdelete files with name <name> only\n" ..
        "Operands:\n" ..
        "\textlist\tcomma separated extension list\n" ..
        "\tdirectory\tdirectory to clean\n"
    )
    os.exit(0)
end


--[[ main ]]
local function main()
    -- parse arguments
    local filename;
    local function onName(name, optarg)
        filename = optarg
        return true
    end
    local verbose;
    local function onVerbose(name, optarg)
        verbose = true
    end

    lopt.handlers
    {
        h = onHelp,
        v = onVerbose,
        n = onName
    }

    local function onArgumentError(msg)
        inform(msg)
        inform("use -h to short command line usage help")
        os.exit(-1)
    end

    local extlist, directory, unexpectedOperand = unpack(arg, lopt.run(arg))

    -- check operands
    if not extlist then onArgumentError("extension list not specified") end
    if not directory then onArgumentError("directory not specified") end
    if unexpectedOperand then onArgumentError("unexpected operand: " .. unexpectedOperand) end

    -- execute command
    clean(extlist, directory, filename, verbose)
end

--[[ bootstrap ]]
res, message = pcall(main)
if not res then
    inform(message)
    os.exit(-1)
end
