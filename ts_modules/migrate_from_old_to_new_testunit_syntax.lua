local fs = require("filesystem")

local files = arg

if not files[1] then
    table.insert(files, 'lua_ext.t.lua')
    table.insert(files, 'filesystem.t.lua')
    table.insert(files, '..\\testunit\\test_listeners.t.lua')
    table.insert(files, '..\\testunit\\test_runner.t.lua')
    table.insert(files, '..\\testunit\\cppunit.t.lua')
    table.insert(files, 'aux_test_func.t.lua')
    table.insert(files, '..\\testunit\\lua_test_sample.t.lua')
    table.insert(files, '..\\testunit\\luaunit.t.lua')
end

local reStr = 
{
    ['local luaUnit = require%("testunit%.luaunit"%)'] = '',
    ['module%(.+'] = '',
    ['TEST_CASE{"([^"]+)", function%(self%)'] = 'function %1()',
    ['teardown'] = 'tearDown',
    ['setup'] = 'setUp',
    ['self%.'] = '',
    ['^;'] = '',
    
    ['ASSERT%s*%('] = 'isTrue(',
    ['ASSERT_TRUE%s*%('] = 'isTrue(',
    ['ASSERT_FALSE%s*%('] = 'isFalse(',
    ['ASSERT_EQUAL%s*%('] = 'areEq(',
    ['ASSERT_STRING_EQUAL%s*%('] = 'areEq(',
    ['ASSERT_NOT_EQUAL%s*%('] = 'areNotEq(',
    ['ASSERT_NO_THROW%s*%('] = 'noThrow(',
    ['ASSERT_THROW%s*%('] = 'willThrow(',

    ['ASSERT_IS_FUNCTION%s*%('] = 'isFunction(',
    ['ASSERT_IS_TABLE%s*%('] = 'isTable(',
    ['ASSERT_IS_NUMBER%s*%('] = 'isNumber(',
    ['ASSERT_IS_STRING%s*%('] = 'isString(',
    ['ASSERT_IS_BOOLEAN%s*%('] = 'isBoolean(',
    ['ASSERT_IS_NIL%s*%('] = 'isNil(',

    ['ASSERT_IS_NOT_FUNCTION%s*%('] = 'isNotFunction(',
    ['ASSERT_IS_NOT_TABLE%s*%('] = 'isNotTable(',
    ['ASSERT_IS_NOT_NUMBER%s*%('] = 'isNotNumber(',
    ['ASSERT_IS_NOT_STRING%s*%('] = 'isNotString(',
    ['ASSERT_IS_NOT_BOOLEAN%s*%('] = 'isNotBoolean(',
    ['ASSERT_IS_NOT_NIL%s*%('] = 'isNotNil(',
}

-- replace first uppercase letter in fixture name with lowercase letter
local uppercaseLetters = {'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', }

table.foreach(uppercaseLetters, function(_, ch)
    reStr['TEST_FIXTURE%("' .. ch .. '([^"]+)"%)'] = string.lower(ch) .. '%1 = '
    reStr['TEST_FIXTURE%("' .. string.lower(ch) .. '([^"]+)"%)'] = string.lower(ch) .. '%1 = '
    
    reStr['TEST_CASE_EX{"([^"]+)", "' .. ch .. '([^"]+)", function%(self%)'] = 'function ' .. string.lower(ch) .. '%2.%1()'
    reStr['TEST_CASE_EX{"([^"]+)", "' .. string.lower(ch) .. '([^"]+)", function%(self%)'] = 'function ' .. string.lower(ch) .. '%2.%1()'
end)


local globalReStr = 
{
    ['\n[^%-][%sT]*EST_SUITE%(.-%)\n{'] = '',
    ['\n(%s*end%s*)\n%s*};%s*\n%s*};'] = '\n%1\n',
    ['\n(%s*end%s*)\n%s*};'] = '\n%1',
    ['};\s*$'] = '',
}

for i = 1, table.maxn(files) do
    local file = files[i]

    local n;
    local lines = {};

    for line in io.lines(file) do
        for re, repl in pairs(reStr) do
            line, n = string.gsub(line, re, repl); 
        end
        table.insert(lines, line);
    end

    --~ print(table.concat(lines, '\n'));
    local text = table.concat(lines, '\n')
    for re, repl in pairs(globalReStr) do
        text, n = string.gsub(text, re, repl); 
    end

--~     print(text)
    fs.copyFile(file, file .. '.bak')
    
    hFile = io.open(file, 'w');
    hFile:write(text);
    hFile:close();
end
