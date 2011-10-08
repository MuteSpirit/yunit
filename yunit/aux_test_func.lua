local _M = {}
local _Mmt = {__index = _G}
setmetatable(_M, _Mmt)
local _G = _M

--------------------------------------------------------------------------------------------------------------
function createTextFileWithContent(path, content)
--------------------------------------------------------------------------------------------------------------
    local hFile = io.open(path, 'w');
    if nil == hFile then
        return false;
    end
    if content and 'string' == type(content) then
        hFile:write(content);
    end
    hFile:close();
    return true;
end

--------------------------------------------------------------------------------------------------------------
function fileContentAsString(path)
--------------------------------------------------------------------------------------------------------------
    local hFile, errMsg = io.open(path, 'r');
    if not hFile then
        return hFile, errMsg;
    end
    local str = hFile:read('*a');
    hFile:close();
    return str;
end

--------------------------------------------------------------------------------------------------------------
function fileContentAsLines(path)
--------------------------------------------------------------------------------------------------------------
    local lines = {};
    for line in io.lines(path) do
        table.insert(lines, line);
    end
    return lines;
end

function pr(msg)
    print('Call from aux:' .. msg .. '\r\n')
end

return _M
