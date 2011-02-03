--- \fn findAndReplaceMacroByPattern(opt, line, pattern)
--- \brief Replase macro with their values at 'line'
--- \param[in] opt Table with options
--- \param[in] line Line of template TeX file
--- \param[in] pattern Pattern for macro searching
--- \return line after replacing

--- \fn findAndReplaceMacro(opt, line)
--- \brief Replace at line all macro types
--- \param[in] opt Table with options
--- \param[in] line Line of template TeX file
--- \return line without macro

--- \fn expandTemplate(opt, texFilenameWithoutExt, intermediateFileExt)
--- \param[in] opt Table with name sand values of parameters, with were defined at the 1st line of tex file
--- \param[in] texFilenameWithoutExt 
--- \param[in] intermediateFileExt 

--- \fn parseLineWithOpts(line)
--- \brief Parse option for build LaTeX script from first line of LaTeX document file
--- \param[out] opt All founded options and macro will be insered into this table.
--- \param[in] line Line, whitch contain options for build script
--- \details Available options:\n
--- --tepmlate Filename to template file with preambula \n
--- --def <macro>=<value> Set <value> for concrete <macro> for replacing at text with specified <value>\n
--- --case <variant> Set what variant of document parts will be choosed for building pure LaTeX
--- --verbose Turn on verbose output messages

--- \fn convertTexTemplateIfNeeded(name)
--- \param[in] name Filename of LaTeX document, prepared for compilation to PDF
--- \return ".tex" if input file is simple LaTeX document or return ".src" - extension of created file with appling template file and all macro

-- Because of build and tex2pdf commands not view  result document, then use at SciTE such command for compile TeX files:
--
-- command.build.$(file.patterns.latex)=lua5.1.exe -e "\
-- os.execute('lua5.1.exe c:/programs/lua/5.1/lua/atd.lua tex2pdf "$(FileName)"'); \
-- os.execute('lua5.1.exe c:/programs/lua/5.1/lua/atd.lua view "$(FileName)"'); \
-- "



--[[Test ATD module]]
require("unittest")

local usageText =
    (
        "atd.lua [-h] command filename\n" ..
        "Options:\n" ..
        "\t-h\t\tprint this message and exit\n" ..
        "Operands:\n" ..
        "\tcommand\tone of translate, build, tex2pdf, view\n" ..
        "\tfilename\tfile name without extension\n"
    )

local simpleDocument =
[[
\documentclass[14pt,a4paper]{extarticle}
\usepackage[cp1251]{inputenc}
\usepackage[russian]{babel}
\usepackage[dvips,hmargin=15mm,vmargin={15mm,20mm}]{geometry}
\begin{document}
\title{Простейший документ}
\author{Сценарий тестирования}
\date{Редакция от \today}
\maketitle
Текст простейшего документа.
\end{document}
]]

flush_message("Run test: flush_message usage")
assert_exec(0) [[lua5.1 atd.lua -h > output.txt]]
assert_file_equal("output.txt")(usageText)

flush_message("Run test: no command")
assert_exec(-1) [[lua5.1 atd.lua > output.txt]]
assert_file_equal("output.txt")
[[
Active TeX Document: command not specified
Active TeX Document: use -h to short command line usage help
]]

flush_message("Run test: no file name")
assert_exec(-1) [[lua5.1 atd.lua translate > output.txt]]
assert_file_equal("output.txt")
[[
Active TeX Document: file name not specified
Active TeX Document: use -h to short command line usage help
]]

flush_message("Run test: unexpected operand")
assert_exec(-1) [[lua5.1 atd.lua unknown_command somefilename unexpected_operand > output.txt]]
assert_file_equal("output.txt")
[[
Active TeX Document: unexpected operand: unexpected_operand
Active TeX Document: use -h to short command line usage help
]]

flush_message("Run test: unknown command")
assert_exec(-1) [[lua5.1 atd.lua unknown_command somefilename > output.txt]]
assert_file_equal("output.txt")
[[
Active TeX Document: unknown command: unknown_command
Active TeX Document: use -h to short command line usage help
]]

flush_message("Run test: invalid file name")
assert_exec(-1) [[lua5.1 atd.lua translate not*exist > output.txt]]
assert_file_match("output.txt")
[[
Active TeX Document: translate 'not%*exist.atd' to 'not%*exist.tex'
Active TeX Document: atd.lua:%d+: cannot open not%*exist.atd: Invalid argument
$]]

flush_message("Run test: file not exist")
assert_exec(-1) [[lua5.1 atd.lua translate not_exist > output.txt]]
assert_file_match("output.txt")
[[
Active TeX Document: translate 'not_exist.atd' to 'not_exist.tex'
Active TeX Document: atd.lua:%d+: cannot open not_exist.atd: No such file or directory
$]]

flush_message("Run test: include not existed")
preparefile("test.one.atd")
[[
atd.include "not_exist"
]]
assert_exec(-1) [[lua5.1 atd.lua translate test.one > output.txt]]
assert_file_equal("output.txt")
[[
Active TeX Document: translate 'test.one.atd' to 'test.one.tex'
Active TeX Document: include file 'not_exist.atd'
Active TeX Document: test.one.atd:1: cannot open not_exist.atd: No such file or directory
]]

flush_message("Run test: include self")
preparefile("test.one.atd")
[[
atd.include "test.one"
]]
assert_exec(-1) [[lua5.1 atd.lua translate test.one > output.txt]]
assert_file_equal("output.txt")
[[
Active TeX Document: translate 'test.one.atd' to 'test.one.tex'
Active TeX Document: test.one.atd:1: recursive include of test.one.atd
]]

flush_message("Run test: cyclic include")
preparefile("test.one.atd")
[[
atd.include "test.two"
]]
preparefile("test.two.atd")
[[
atd.include "test.one"
]]
assert_exec(-1) [[lua5.1 atd.lua translate test.one > output.txt]]
assert_file_equal("output.txt")
[[
Active TeX Document: translate 'test.one.atd' to 'test.one.tex'
Active TeX Document: include file 'test.two.atd'
Active TeX Document: test.two.atd:1: recursive include of test.one.atd
]]

flush_message("Run test: successive include")
preparefile("test.one.atd")
[[
atd.include "test.two"
atd.include "test.two"
]]
preparefile("test.two.atd")
[[
local tmp = "The test"
]]
assert_exec(0) [[lua5.1 atd.lua translate test.one > output.txt]]
assert_file_equal("output.txt")
[[
Active TeX Document: translate 'test.one.atd' to 'test.one.tex'
Active TeX Document: include file 'test.two.atd'
Active TeX Document: include file 'test.two.atd'
]]
assert_file_equal("test.one.tex")
[[]]

flush_message("Run test: chunk additions")
preparefile("test.one.atd")
[=[
atd.body [[]]
atd.body [[1]]
atd.body [[2]]
atd.body [[3]]
atd.body "\n"
atd.body "1\n"
atd.body "23\n"
]=]
assert_exec(0) [[lua5.1 atd.lua translate test.one > output.txt]]
assert_file_equal("output.txt")
[[
Active TeX Document: translate 'test.one.atd' to 'test.one.tex'
]]
assert_file_equal("test.one.tex")
[[
123
1
23
]]

flush_message("Run test: empty source")
preparefile("test.one.atd")
[[]]
assert_exec(0) [[lua5.1 atd.lua translate test.one > output.txt]]
assert_file_equal("output.txt")
[[
Active TeX Document: translate 'test.one.atd' to 'test.one.tex'
]]
assert_file_equal("test.one.tex")
[[]]

flush_message("Run test: empty prologue & epilogue")
preparefile("test.one.atd")
[[
atd.prologue ""
atd.epilogue ""
atd.body "T"
]]
assert_exec(0) [[lua5.1 atd.lua translate test.one > output.txt]]
assert_file_equal("output.txt")
[[
Active TeX Document: translate 'test.one.atd' to 'test.one.tex'
]]
assert_file_equal("test.one.tex")
[[T]]

flush_message("Run test: short prologue & epilogue")
preparefile("test.one.atd")
[[
atd.prologue "L"
atd.epilogue "R"
atd.body "C"
]]
assert_exec(0) [[lua5.1 atd.lua translate test.one > output.txt]]
assert_file_equal("output.txt")
[[
Active TeX Document: translate 'test.one.atd' to 'test.one.tex'
]]
assert_file_equal("test.one.tex")
[[LCR]]

flush_message("Run test: prologue, body, epilogue")
preparefile("test.one.atd")
[[
atd.prologue "pro\n"
atd.epilogue "epi\n"
atd.body "body\n"
]]
assert_exec(0) [[lua5.1 atd.lua translate test.one > output.txt]]
assert_file_equal("output.txt")
[[
Active TeX Document: translate 'test.one.atd' to 'test.one.tex'
]]
assert_file_equal("test.one.tex")
[[
pro
body
epi
]]

flush_message("Run test: first prologue & epilogue used")
preparefile("test.one.atd")
[[
atd.prologue "pro1\n"
atd.epilogue "epi1\n"
atd.prologue "pro2\n"
atd.epilogue "epi2\n"
atd.body "body\n"
]]
assert_exec(0) [[lua5.1 atd.lua translate test.one > output.txt]]
assert_file_equal("output.txt")
[[
Active TeX Document: translate 'test.one.atd' to 'test.one.tex'
]]
assert_file_equal("test.one.tex")
[[
pro1
body
epi1
]]

flush_message("Run test: invalid key type")
preparefile("test.one.atd")
[[
atd.define { [{}]="1" }
]]
assert_exec(-1) [[lua5.1 atd.lua translate test.one > output.txt]]
assert_file_match("output.txt")
[[
Active TeX Document: translate 'test.one.atd' to 'test.one.tex'
Active TeX Document: test.one.atd:1: invalid macro defenition key: table: %x+
$]]

flush_message("Run test: invalid value type")
preparefile("test.one.atd")
[[
atd.define { ["1"]={} }
]]
assert_exec(-1) [[lua5.1 atd.lua translate test.one > output.txt]]
assert_file_match("output.txt")
[[
Active TeX Document: translate 'test.one.atd' to 'test.one.tex'
Active TeX Document: test.one.atd:1: invalid macro defenition value: table: %x+
$]]

flush_message("Run test: invalid key format")
preparefile("test.one.atd")
[[
atd.define { ["!"] = "1" }
]]
assert_exec(-1) [[lua5.1 atd.lua translate test.one > output.txt]]
assert_file_equal("output.txt")
[[
Active TeX Document: translate 'test.one.atd' to 'test.one.tex'
Active TeX Document: test.one.atd:1: invalid macro defenition key: !
]]

flush_message("Run test: valid macro defenition")
preparefile("test.one.atd")
[=[
atd.define { a = "1" }
atd.define { ab = "12" }
atd.define { a9_ = "@a@" }
atd.body [[@@@a@@ab@@a9_@]]
]=]
assert_exec(0) [[lua5.1 atd.lua translate test.one > output.txt]]
assert_file_equal("output.txt")
[[
Active TeX Document: translate 'test.one.atd' to 'test.one.tex'
]]
assert_file_equal("test.one.tex")
[[@112@a@]]

flush_message("Run test: valid macro substitution")
preparefile("test.one.atd")
[=[
atd.define { a = "TEXT" }
atd.body [[
text@@text@@@a@@@text@a@
@a@123@a@]]
]=]
assert_exec(0) [[lua5.1 atd.lua translate test.one > output.txt]]
assert_file_equal("output.txt")
[[
Active TeX Document: translate 'test.one.atd' to 'test.one.tex'
]]
assert_file_equal("test.one.tex")
[[
text@text@TEXT@textTEXT
TEXT123TEXT]]

flush_message("Run test: build simple doc")
preparefile("test.one.atd")("atd.body [[" .. simpleDocument .. "]]")
assert_exec(0) [[lua5.1 atd.lua build test.one > nil]]

flush_message("Run test: tex2pdf simple doc")
assert_exec(0) [[lua5.1 atd.lua tex2pdf test.one > nil]]

flush_message("Run test: view pdf")
assert_exec(0) [[lua5.1 atd.lua view test.one > nil]]

--------------------------------------------------------------------------------------------------------------
-- Test, which are using lunit
--------------------------------------------------------------------------------------------------------------

local lunit = require("lunit")
local fs = require("filesystem")
require("atd")

--------------------------------------------------------------------------------------------------------------
module("atd_test", lunit.testcase, package.seeall)
--------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
--- \fn Fake function only for testing
function inform(msg)
--------------------------------------------------------------------------------------------------------------
end 

--------------------------------------------------------------------------------------------------------------
function testParseLineWithOptsNotClearOptTable()
    local opts = {testKey = 'testValue'};
    parseLineWithOpts(opts, " --template='teplate_file.tex' ");
    assert_equal('testValue', opts.testKey);
end

--------------------------------------------------------------------------------------------------------------
function testParseLineWithOptsFindTemplate()
    local opts;
    
    opts = {};
    parseLineWithOpts(opts, " --template='teplate_file.tex' ");
    assert_equal("teplate_file.tex", opts.template);

    opts = {};
    parseLineWithOpts(opts, " --template 'teplate_file.tex' ");
    assert_equal("teplate_file.tex", opts.template);
end
--------------------------------------------------------------------------------------------------------------
function testParseLineWithOptsfindCase()
    local opts;
    
    opts = {};
    parseLineWithOpts(opts, "--case=R");
    assert_equal("R", opts.case);
    
    opts = {};
    parseLineWithOpts(opts, "--case R");
    assert_equal("R", opts.case);
    
    opts = {};
    parseLineWithOpts(opts, "--case='R'");
    assert_equal("R", opts.case);
    
    opts = {};
    parseLineWithOpts(opts, "--case 'R'");
    assert_equal("R", opts.case);
end
--------------------------------------------------------------------------------------------------------------
function testParseLineWithOptsFindMacroDefinitions()
    local opts = {};
    parseLineWithOpts(opts, "--def author='Genius' --def date='today'");
    assert_equal("Genius", opts.macro.author);
    assert_equal("today", opts.macro.date);
end
--------------------------------------------------------------------------------------------------------------
function testParseLineWithOptsFindVerbose()
    local opts = {};
    parseLineWithOpts(opts, "--verbose");
    assert_equal(true, opts.verbose);
end

--------------------------------------------------------------------------------------------------------------
function testParseLineWithOptsAllOptionsSimultaneous()
    local opts = {};
    parseLineWithOpts(opts, "--template='teplate_file.tex'  --def author='Genius' --case R --def date='today' --verbose");
    assert_equal("teplate_file.tex", opts.template);
    assert_equal("R", opts.case);
    assert_equal("Genius", opts.macro.author);
    assert_equal("today", opts.macro.date);
    assert_equal(true, opts.verbose);
end

--------------------------------------------------------------------------------------------------------------
function testFindAndReplaceMacro()
    local opt;
    
    opt = {macro = {today = 'doomsday'}};
    assert_equal('This is last day. This is doomsday', findAndReplaceMacro(opt, 'This is last day. This is @{today}'));

    opt = {macro = {}};
    assert_equal('This is last day. This is doomsday', findAndReplaceMacro(opt, 'This is last day. This is @{today}{doomsday}'));

    opt = {macro = {}};
    assert_equal('This is last day. This is ', findAndReplaceMacro(opt, 'This is last day. This is @{today}'));

    opt = {macro = {today = 'doomsday', realMan = 'Duke Nukem'}};
    assert_equal("This is last day. This is doomsday. This Duke Nukem's day.", findAndReplaceMacro(opt, "This is last day. This is @{today}. This @{realMan}'s day."));
    
    opt = {macro = {today = 'doomsday', realMan = 'Duke Nukem'}};
    assert_equal("This is last day. This is doomsday. This Duke Nukem's day.", findAndReplaceMacro(opt, "This is last day. This is @{today}. This @{realMan}{Bruce Willis}'s day."));
    
    opt = {macro = {today = 'doomsday', realMan = 'Duke Nukem'}};
    assert_equal("This is last day. This is doomsday. This Duke Nukem's day.", findAndReplaceMacro(opt, "This is last day. This is @{today}. This @{realMan}{Bruce Willis}'s day."));
    
    opt = {macro = {today = 'doomsday', realMan = nil}};
    assert_equal("This is last day. This is doomsday. This Bruce Willis's day.", findAndReplaceMacro(opt, "This is last day. This is @{today}. This @{realMan}{Bruce Willis}'s day."));
    
    opt = {macro = {['os'] = 'Windows', definition = ' is very unlogical.'},};
    assert_equal('Windows is very unlogical.', findAndReplaceMacro(opt, '@{os}@{definition}'));
end

local texTemplateFileContent = [=[
@@0\documentclass[12pt,a4paper]{article}
@@R\documentclass[12pt,a4paper,twoside]{report}
\usepackage{amssymb,latexsym,amsmath}
\usepackage[cp1251]{inputenc}
\usepackage[russian]{babel}
@@0\usepackage[dvips,hmargin=15mm,vmargin={15mm,20mm}]{geometry}
@@R\usepackage[dvips,hmargin=15mm,bindingoffset=10mm,twoside,vmargin={15mm,20mm}]{geometry}
\usepackage[obeyspaces,spaces]{url}
\usepackage[unicode,ps2pdf]{hyperref}
\usepackage{indentfirst}
\usepackage[labelsep=period]{caption}
\usepackage{tabulary}
\usepackage{longtable}
\usepackage[dvips,dvipsnames]{xcolor}
\usepackage[dvips]{graphicx}
\usepackage{listings}
\usepackage{pstcol, pst-node, pst-tree}
\usepackage{versions}

\begin{document}

\title{@{title}}
\author{@{author}{\we}}
\date{Редакция от @{today}{\today}}
\maketitle

\tableofcontents

\input{@{FILE_NAME}}

\end{document}
]=];

-- !!! Don't foget to make concatenation: texFileContentBegin..texTemplateFilenameWitoutExt..texFileContentEnd
local texFileContentBegin = [=[
%--template ']=];
local texFileContentEnd = [=[' --def title='Общее руководство' --def author='\we' --def today='???'

\section{Проведение забастовочных мероприятий в малых фирмах частного сектора экономики}
Примером лозунгов при проведении стачки могут быть, например, следующие:
\begin{itemize}
\item "Даешь ночную смену и гибкий график программистам! Ура!"
\item "Windows - <censored>! Билл Гейтс - <censored>! Даешь Linux, Codeblocks и GCC!"
\end{itemize}
Следующая известная фраза не рекомендуется к применению из-за наличия граматических ошибок и прямых оскорблений личности:
\begin{itemize}
\item "ЗАРПЛАТАМА НЕТ! РАБОТЫМА НЕТ! НАСЯЛЬНИКА <censored>!"
\end{itemize}
]=];

--------------------------------------------------------------------------------------------------------------
function testExpandTemplate()
    local opt =
    {
        dir = tmpDir,
        name = 'temp',
        template = 'temp_template.tex',
        verbose = true,
        pause = false,
        case = 'R',
        macro =
        {
            FILE_NAME = 'temp.tex',
            title = 'Общее руководство',
            today = '???',
        },
    };
    
    assert_true(fs.createTextFileWithContent(opt.dir .. opt.name..'.tex', texFileContentBegin..opt.template..texFileContentEnd));
    assert_true(fs.isExist(opt.dir .. opt.name..'.tex'));
    assert_true(fs.createTextFileWithContent(tmpDir .. opt.template, texTemplateFileContent));
    assert_true(fs.isExist(tmpDir .. opt.template));
    assert_true(lfs.chdir(tmpDir));

    expandTemplate(opt, 'temp', 'src');
    assert_true(fs.isExist(opt.dir .. opt.name..'.src'));
    local hSrcFile = io.open(opt.dir .. opt.name..'.src', 'r');
    assert_not_nil(hSrcFile);

    assert_equal([=[
\documentclass[12pt,a4paper,twoside]{report}
\usepackage{amssymb,latexsym,amsmath}
\usepackage[cp1251]{inputenc}
\usepackage[russian]{babel}
\usepackage[dvips,hmargin=15mm,bindingoffset=10mm,twoside,vmargin={15mm,20mm}]{geometry}
\usepackage[obeyspaces,spaces]{url}
\usepackage[unicode,ps2pdf]{hyperref}
\usepackage{indentfirst}
\usepackage[labelsep=period]{caption}
\usepackage{tabulary}
\usepackage{longtable}
\usepackage[dvips,dvipsnames]{xcolor}
\usepackage[dvips]{graphicx}
\usepackage{listings}
\usepackage{pstcol, pst-node, pst-tree}
\usepackage{versions}

\begin{document}

\title{Общее руководство}
\author{\we}
\date{Редакция от ???}
\maketitle

\tableofcontents

\input{temp.tex}

\end{document}
]=], hSrcFile:read('*a'));
    hSrcFile:close();
    
end

--------------------------------------------------------------------------------------------------------------
-- function testConvertTexTemplateIfNeeded()
--     local tmpFilePath = tmpDir .. 'tmp.file';
--     local text = [[%--template 'til_it_design_template.tex' --def title='Инфраструктура' --def author='\we']]..'\n';
--     assert_true(fs.createTextFileWithContent(tmpFilePath, text));
--     local args = convertTexTemplateIfNeeded(tmpFilePath);
--     assert_equal("'til_it_design_template.tex'", args.template);
--     assert_equal("'Инфраструктура'", args.title);
--     assert_equal('\we', args.author);
-- end
