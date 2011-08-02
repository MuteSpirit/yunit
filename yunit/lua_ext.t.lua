-- -*- coding: utf-8 -*-

-- Documentation

--- \fn table.toLuaCode(inTable, indent, resultHandler)
--- \brief Преобразует объект типа таблица в строку лунового кода, создающего такую таблицу
--- \param[in] inTable таблица для обработки
--- \param[in] indent отступ от начала строки для элементов таблицы
--- \param[in] resultHandler указатель на функцию-обработчик результата, если nil, то функция просто вернет результирующую строку

--- \fn findKey(inTable, inKey)
--- \brief Определяет наличие в таблице ключа с заданным значением (без рекурсивного обхода всей таблицы)
--- \param[in] inTable таблица для поиска
--- \param[in] inKey значение ключа, который надо разыскать
--- \return true если искомый ключ был найден, иначе false

--- \fn findValue(inTable, inValue)
--- \brief Аналогична findKey, только ищется значение в таблице, а не ключ
--- \see findKey

--- \fn table.keys(inTable)
--- \brief Return list of keys in 'inTable' 
--- \param[in] inTable table for processing

--- \fn table.isEmpty(tableValue)
--- \return true if table does not contain any elements

--- \fn convertTextToRePattern(text)
--- \brief Replace magic chars  ( ) . % + - [ ] ^ $ ? *  at 'text' with used at re patterns
--- \param[in] text Source text for pattern creation
--- \return Regula expression patterns

--- \fn string.split(str, delimiter)
--- \brief Splitting string into parts using 'delimited' as a bound beatween them
--- \param[in] str String for cutting
--- \param[in] delimiter It is pattern for delimiter substring. I.e. string.len(delimiter) maybe > 1. Attention with special simbols, whith need % before them.
--- \return Array (i.e. {'a', 'b',}) of string parts



local luaExt = require('yunit.lua_ext')



function testFindInTable()
    isTrue(luaExt.findKey({[1] = "1"}, 1))
    isFalse(luaExt.findKey({[2] = "1"}, 1))
    isTrue(luaExt.findValue({[1] = "1"}, "1"))
    isFalse(luaExt.findValue({[1] = "2"}, "1"))
end

function toLuaCode()
    local t = 
    {
        [1] = 1,
        ['a'] = [=[a]=],
        [{}] = {},
    }
    local spaceAsTab = string.rep(' ', 4);
    local str = table.toLuaCode(t, spaceAsTab .. spaceAsTab);
    local designedStr = 
    [[{
        [1] = 1,
        [{}] = {},
        ['a'] = [=[a]=],
}]]    
    areEq(designedStr, str)
end

function testStringSplit()
    local parts = {};

    parts = string.split('', ';');
    areEq('', parts[1]);

    parts = string.split(';', ';');
    areEq('', parts[1]);
    areEq('', parts[2]);

    parts = string.split(';/bin;', ';');
    areEq('', parts[1]);
    areEq('/bin', parts[2]);
    areEq('', parts[3]);
    
    parts = string.split('/bin;/local/bin;c:', ';');
    areEq('/bin', parts[1]);
    areEq('/local/bin', parts[2]);
    areEq('c:', parts[3]);
    
    parts = string.split('aa  bb  cc\tdd\t\tee\t gg', '%s+');
    areEq('aa', parts[1]);
    areEq('bb', parts[2]);
    areEq('cc', parts[3]);
    areEq(6, #parts);
end

function tableKeysTest()
    local keyList = table.keys({[10] = 1, [11] = 1, [12] = 1, [13] = 1});
    table.sort(keyList);
    areEq(10, keyList[1]);
    areEq(11, keyList[2]);
    areEq(12, keyList[3]);
    areEq(13, keyList[4]);
end

function tableEmptyTest()
    isTrue(table.isEmpty{});
    isFalse(table.isEmpty{''});
end

function convertTextToRePattern()
    areEq('exportDg %.cpp', luaExt.convertTextToRePattern('exportDg .cpp'));
    
end

function tableCompareTest()
    isTrue(table.isEqual({}, {}));
    isTrue(table.isEqual({1}, {1}));
    isTrue(table.isEqual({1.1}, {1.1}));
    isTrue(table.isEqual({'a'}, {'a'}));
    isTrue(table.isEqual({{}}, {{}}));
    isTrue(table.isEqual({1, 1.1, 'a', {}}, {1, 1.1, 'a', {}}));
    isTrue(table.isEqual({{1}}, {{1}}));
    
    isTrue(table.isEqual({['a'] = 'a', ['1.1'] = 1.1, ['1'] = 1, {}}, {['1.1'] = 1.1, ['1'] = 1, ['a'] = 'a', {}}));
    local a = function () end
    isTrue(table.isEqual({['a'] = a, ['1.1'] = 1.1, ['1'] = 1, {}}, {['1.1'] = 1.1, ['1'] = 1, ['a'] = a, {}}));
    isFalse(table.isEqual({['a'] = true}, {['a'] = false}));
    isTrue(table.isEqual({['a'] = false}, {['a'] = false}));

    isFalse(table.isEqual({}, {1}));
    isFalse(table.isEqual({}, {1.1}));
    isFalse(table.isEqual({}, {'a'}));
    isFalse(table.isEqual({}, {{}}));
    
    isFalse(table.isEqual({1}, {}));
    isFalse(table.isEqual({1.1}, {}));
    isFalse(table.isEqual({'a'}, {}));
    isFalse(table.isEqual({{}}, {}));

    isTrue(table.isEqual( { [{1}] = 1}, { [{1}] = 1} ));
end

