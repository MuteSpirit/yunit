-- -*- coding: utf-8 -*-
--------------------------------------------------------------------------------------------------------------
-- Documentation
--------------------------------------------------------------------------------------------------------------

--- \fn findKey(inTable, inKey)
--- \brief Определяет наличие в таблице ключа с заданным значением (без рекурсивного обхода всей таблицы)
--- \param[in] inTable таблица для поиска
--- \param[in] inKey значение ключа, который надо разыскать
--- \return true если искомый ключ был найден, иначе false

--- \fn findValue(inTable, inValue)
--- \brief Аналогична findKey, только ищется значение в таблице, а не ключ
--- \see findKey

--- \fn notFindValue(inTable, inValue)
--- \brief Функция подтверждает, что данного занчения в таблице нет
--- \param[in] inTable таблица для поиска
--- \param[in] inValue значение, который не должно быть найдено в таблице
--- \return true если искомое значения не было найдено, иначе false

--- \fn convertTextToRePattern(text)
--- \brief Replace magic chars  ( ) . % + - [ ] ^ $ ? *  at 'text' with used at re patterns
--- \param[in] text Source text for pattern creation
--- \return Regula expression patterns

--- \fn string.split(str, delimiter)
--- \brief Splitting string into parts using 'delimited' as a bound beatween them
--- \param[in] str String for cutting
--- \param[in] delimiter It is pattern for delimiter substring. I.e. string.len(delimiter) maybe > 1. Attention with special simbols, whith need % before them.
--- \return Array (i.e. {'a', 'b',}) of string parts

local lunit = require('lunit')
local luaExt = require('lua_ext')

--------------------------------------------------------------------------------------------------------------
module("test_lua_ext", lunit.testcase, package.seeall)
--------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
function testFindInTable()
    assert_true(luaExt.findKey({[1] = "1"}, 1))
    assert_false(luaExt.findKey({[2] = "1"}, 1))
    assert_true(luaExt.findValue({[1] = "1"}, "1"))
    assert_false(luaExt.findValue({[1] = "2"}, "1"))
end

--------------------------------------------------------------------------------------------------------------
function testStringSplit()
    local parts = {};

    parts = string.split('', ';');
    assert_equal('', parts[1]);

    parts = string.split(';', ';');
    assert_equal('', parts[1]);
    assert_equal('', parts[2]);

    parts = string.split(';/bin;', ';');
    assert_equal('', parts[1]);
    assert_equal('/bin', parts[2]);
    assert_equal('', parts[3]);
    
    parts = string.split('/bin;/local/bin;c:', ';');
    assert_equal('/bin', parts[1]);
    assert_equal('/local/bin', parts[2]);
    assert_equal('c:', parts[3]);
    
    parts = string.split('aa  bb  cc\tdd\t\tee\t gg', '%s+');
    assert_equal('aa', parts[1]);
    assert_equal('bb', parts[2]);
    assert_equal('cc', parts[3]);
    assert_equal(6, #parts);
end

function tableKeysTest()
    local keys = luaExt.tableKeys({[10] = 1, [11] = 1, [12] = 1, [13] = 1});
    table.sort(keys);
    assert_equal(10, keys[1]);
    assert_equal(11, keys[2]);
    assert_equal(12, keys[3]);
    assert_equal(13, keys[4]);
end

function tableEmptyTest()
    assert_true(table.empty{});
    assert_false(table.empty{''});
end

function tableCompareTest()
    assert_true(table.isEqual({}, {}));
    assert_true(table.isEqual({1}, {1}));
    assert_true(table.isEqual({1.1}, {1.1}));
    assert_true(table.isEqual({'a'}, {'a'}));
    assert_true(table.isEqual({{}}, {{}}));
    assert_true(table.isEqual({1, 1.1, 'a', {}}, {1, 1.1, 'a', {}}));
    assert_true(table.isEqual({{1}}, {{1}}));
    
    assert_false(table.isEqual({}, {1}));
    assert_false(table.isEqual({}, {1.1}));
    assert_false(table.isEqual({}, {'a'}));
    assert_false(table.isEqual({}, {{}}));
    
    assert_false(table.isEqual({1}, {}));
    assert_false(table.isEqual({1.1}, {}));
    assert_false(table.isEqual({'a'}, {}));
    assert_false(table.isEqual({{}}, {}));

    assert_true(table.isEqual( { [{1}] = 1}, { [{1}] = 1} ));
end
























