local file = arg[1];
--~ file = 'lua_ext.t.lua';
--~ file = 'filesystem.t.lua';
--~ file = '..\\yunit\\test_result_handlers.t.lua';
file = '..\\yunit\\cppunit.t.lua';
if not file then
    error('Use filename as 1st arg');
end

local reStr = 
{
    ['module%(%"?([^%"]+)%"?,.-%)'] = '};\n\nTEST_SUITE("%1")\n{',
    ['^end%s*$'] = 'end\n};',
    ['function (%w+)%(%)'] = 'TEST_CASE{"%1", function(self)',
    ['assert_pass%(function%(%) (.+) end%);'] = '%1;',
    ['    };'] = '    end\n    };',
    ['ASSERT_PASS'] = 'ASSERT_NO_THROW',
    ['%-%-%-%-[%-]+'] = '',
    ['assert_error'] = 'ASSERT_THROW',
    ['local lunit = require%([\'"]lunit[\'"]%)'] = 'local luaUnit = require(\'yunit.luaunit\');\nmodule(\''.. string.gsub(file, '%.lua$', '') .. '\', luaUnit.testmodule, package.seeall);',
};


local text;

local hFile = io.open(file, 'r');
text = hFile:read('*a');
hFile:close();

for assertWord in string.gmatch(text, 'assert_[%w_]*') do
    if not reStr[assertWord] then
        reStr[assertWord] = string.upper(assertWord);
    end
end

local n;
local lines = {};

for line in io.lines(file) do
    for re, repl in pairs(reStr) do
        line, n = string.gsub(line, re, repl); 
    end
    table.insert(lines, line);
end

-- close TEST_SUITE
table.insert(lines, '};');

--~ print(table.concat(lines, '\n'));

hFile = io.open(file .. '.bak', 'w');
hFile:write(text);
hFile:close();

hFile = io.open(file, 'w');
hFile:write(table.concat(lines, '\n'));
hFile:close();


