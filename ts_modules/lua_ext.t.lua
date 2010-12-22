-- -*- coding: utf-8 -*-

-- Documentation


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

local luaUnit = require("testunit.luaunit");
module("lua_ext.t", luaUnit.testmodule, package.seeall);
local luaExt = require('lua_ext')


TEST_SUITE("test_lua_ext")
{



TEST_CASE{"testFindInTable", function(self)
    ASSERT_TRUE(luaExt.findKey({[1] = "1"}, 1))
    ASSERT_FALSE(luaExt.findKey({[2] = "1"}, 1))
    ASSERT_TRUE(luaExt.findValue({[1] = "1"}, "1"))
    ASSERT_FALSE(luaExt.findValue({[1] = "2"}, "1"))
end
};


TEST_CASE{"testStringSplit", function(self)
    local parts = {};

    parts = string.split('', ';');
    ASSERT_EQUAL('', parts[1]);

    parts = string.split(';', ';');
    ASSERT_EQUAL('', parts[1]);
    ASSERT_EQUAL('', parts[2]);

    parts = string.split(';/bin;', ';');
    ASSERT_EQUAL('', parts[1]);
    ASSERT_EQUAL('/bin', parts[2]);
    ASSERT_EQUAL('', parts[3]);
    
    parts = string.split('/bin;/local/bin;c:', ';');
    ASSERT_EQUAL('/bin', parts[1]);
    ASSERT_EQUAL('/local/bin', parts[2]);
    ASSERT_EQUAL('c:', parts[3]);
    
    parts = string.split('aa  bb  cc\tdd\t\tee\t gg', '%s+');
    ASSERT_EQUAL('aa', parts[1]);
    ASSERT_EQUAL('bb', parts[2]);
    ASSERT_EQUAL('cc', parts[3]);
    ASSERT_EQUAL(6, #parts);
end
};

TEST_CASE{"tableKeysTest", function(self)
    local keys = luaExt.tableKeys({[10] = 1, [11] = 1, [12] = 1, [13] = 1});
    table.sort(keys);
    ASSERT_EQUAL(10, keys[1]);
    ASSERT_EQUAL(11, keys[2]);
    ASSERT_EQUAL(12, keys[3]);
    ASSERT_EQUAL(13, keys[4]);
end
};

TEST_CASE{"tableEmptyTest", function(self)
    ASSERT_TRUE(table.empty{});
    ASSERT_FALSE(table.empty{''});
end
};

TEST_CASE{"tableCompareTest", function(self)
    ASSERT_TRUE(table.isEqual({}, {}));
    ASSERT_TRUE(table.isEqual({1}, {1}));
    ASSERT_TRUE(table.isEqual({1.1}, {1.1}));
    ASSERT_TRUE(table.isEqual({'a'}, {'a'}));
    ASSERT_TRUE(table.isEqual({{}}, {{}}));
    ASSERT_TRUE(table.isEqual({1, 1.1, 'a', {}}, {1, 1.1, 'a', {}}));
    ASSERT_TRUE(table.isEqual({{1}}, {{1}}));
    
    ASSERT_FALSE(table.isEqual({}, {1}));
    ASSERT_FALSE(table.isEqual({}, {1.1}));
    ASSERT_FALSE(table.isEqual({}, {'a'}));
    ASSERT_FALSE(table.isEqual({}, {{}}));
    
    ASSERT_FALSE(table.isEqual({1}, {}));
    ASSERT_FALSE(table.isEqual({1.1}, {}));
    ASSERT_FALSE(table.isEqual({'a'}, {}));
    ASSERT_FALSE(table.isEqual({{}}, {}));

    ASSERT_TRUE(table.isEqual( { [{1}] = 1}, { [{1}] = 1} ));
end
};
};