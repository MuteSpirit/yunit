--[[ lopt - script argument parser. POSIX and some GNU compliant.  ]]

local error, assert, print, pairs, string = error, assert, print, pairs, string

module(...)

--[[ handlers ]]
local shortHandlers, longHandlers = {}, {}

function handlers(tab)
    for k, v in pairs(tab) do
        if string.len(k) == 1 then
            shortHandlers[k] = v
        else
            longHandlers[k] = v
        end
    end
end

-- get option handler or die
local function getShort (name)
    handler = shortHandlers[name]
    if not handler then error("unknown option: " .. name, 3) end
    return handler
end

local function getLong (name)
    handler = longHandlers[name]
    if not handler then error("unknown option: " .. name, 3) end
    return handler
end


-- parse script arguments and run options handlers; return first operand index in arg[]
function run (arg)
    -- start lookup options from arg[1]
    local n = 1
    while arg[n] do
        local dash, name, delimiter, param = string.match (arg[n], "^(%-%-?)([%w]*)([=%s]?)(.*)")
        -- most likely there are some options in the command line
        if dash == "-" then
            -- shoud be short POSIX option(s) in arg[n]
            if string.len(delimiter) ~= 0 then error("equals sign '=' in short option not allowed: " .. arg[n]) end
            if string.len(param) ~= 0 then error("invalid short option name: " .. string.sub(param, 1, 1) .. " in " .. arg[n]) end
            if string.len(name) == 0 then return n end -- there is a first script operand (one dash) in arg[n]
            if (string.len(name) == 1) then
                -- single option, my be with argument in arg[n + 1]
                if getShort(name)(name, arg[n + 1] or "") then
                    n = n + 1
                end
            else
                -- there are more then one flag in arg[n]
                assert(string.len(name) > 1)
                for i = 1, string.len(name) do
                    local flagName = string.sub(name, i, i)
                     -- flag gets no argument
                    if getShort(flagName)(flagName, "") then error("short option '" .. name .. "' with mandatory argument shoud not used as flag") end
                end
            end
        elseif dash == "--" then
            if arg == "--" then return n + 1 end -- there is "stop" double dash in arg[n], all next args are operands
            -- shoud be long GNU option in arg[n], my be with argument
            if string.len(name) == 0 then error("long option without name: " .. arg[n]) end
            if string.len(param) ~= 0 and string.len(delimiter) == 0 then error("invalid character '" .. string.sub(param, 1, 1) .. "' in long option name: " .. argv[n]) end
            getLong(name)(name, param)
        else
            -- neither '-' nor '--', i.e. there is first operand in arg[n]
            assert(dash == nil)
            return n
        end
        n = n + 1
    end
    -- all arguments (my be none) are options - no operands
    assert(arg[n] == nil)
    return n
end
