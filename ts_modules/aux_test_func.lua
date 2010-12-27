-- -*- coding: utf-8 -*-
local _G = _G

--------------------------------------------------------------------------------------------------------------
module(...)
_G.setmetatable(_M, {__index = _G})
--------------------------------------------------------------------------------------------------------------

local luaExt = require('lua_ext');
local lfs = require("lfs")

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

