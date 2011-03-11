--[[
\section{Модуль для разбора аргументов командной строки lopt}
Модуль отвечает требованиям стандартов и определению аргументов командной строки, данных в технической или эксплуатационной документации компании

При создании модуля в качестве образцов функций для анализа аргументов командной строки в Lua были рассмотрены:
\begin{itemize}
\item[1.] AlternativeGetOpt "--- поддерживает POSIX частично, не останавливается перед операндами.
\item[2.] CommandLineModule "--- поддерживает собственный синтаксис командной строки.
\item[3.] getopt module in stdlib "--- зависит от нескольких других пакетов stdlib, достаточно сложен.
\item[4.] Lua optparse "--- частично соответствует стандартам, частично повторяет модуль Python.
\item[5.] Metalua's option parser: "--- расширяет стандарт, достаточно сложен, преобразует типы аргументов.
\item[6.] See near line 129 of [\url{http://wordgrinder.svn.sourceforge.net/viewvc/wordgrinder/wordgrinder-0.3.2/src/lua/main.lua?revision=147&view=markup}] "--- прост, оригинальный функциональный метод определения аргументов.
\item[7.] GetOpt (old - Lua 4) "--- устарел, новая версия, getopt, входит в stdlib.
\item[8.] LappFramework "--- сложное определение аргументов через текстовое описание их использования.
\end{itemize}

С учетом исходных требований и результатов анализа в качестве основы для модуля используются варианты 6 и 3.
]]

--[[ lopt.lua unit tests]]
require("unittest")
require("lopt")

--[[ test options handlers ]]
local values = {}

local function setval(name, optarg)
    if optarg == nil then optarg = "nil" end
    values[name] = optarg
end

local function flag(name, optarg)
    setval(name)
end

local function opt(name, optarg)
    setval(name, optarg)
    return true
end

local function gnu(name, optarg)
    setval(name, optarg)
end

lopt.handlers
{
    h = flag,
    v = flag,
    ['1'] = flag,
    o = opt,
    l1 = gnu,
    l2 = gnu,
    l3 = gnu,
}

--[[ test options handlers ]]
flush_message("Run test: test valid options parsing")
do 
    local argv = { "-vh", "-o", "my/file.ext", "--l1= 333 ", "--l3" }
    if assert_equal(6, assert_pass(lopt.run, argv)) then
        assert_equal("nil", values.v)
        assert_equal("nil", values.h)
        assert_equal("my/file.ext", values.o)
        assert_equal(" 333 ", values.l1)
        assert_equal(nil, values.l2)
        assert_equal("", values.l3)
    end
end
do
    flush_message("Run test: test unknown option parsing")
    argv = { "-vx", "my/file.ext", "--n1= 333 " };
    assert_error("unknown option: x", lopt.run, argv)
end
do
    flush_message("Run test: test number as short option");
    local argv = { "-1"};
    if assert_equal(2, assert_pass(lopt.run, argv)) then
        assert_equal("nil", values['1']);
    end
end
do
    flush_message("Run test: test setting long option without '=' sign");

    if assert_equal(2, assert_pass(lopt.run, { "--l1 333"})) then
        assert_equal("333", values.l1);
    end
end
