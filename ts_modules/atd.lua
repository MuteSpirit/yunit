local lfs = require("lfs");

--[[ Active TeX Document (ATD) module ]]
-- special case of module defenition
atd = {}


--[[ Auxiliary ATD functions ]]
local function inform(message)
    io.write("Active TeX Document: " .. tostring(message) .. "\n")
    io.output():flush()
end

local function chkarg(argn, argt, argv)
    if type(argv) ~= argt then
        error("argument #" .. argn .. " invalid type: " .. type(argv), 2)
    end
end


--[[ Macroprocessor ]]
-- macrodefenitions table
local macro = {}

-- define macro parameters
-- param tab - table of key = value parameter defenitions
function atd.define(tab)
    chkarg(1, "table", tab)
    for k, v in pairs(tab) do
        if type(k) ~= "string" or not string.match(k, "^[%w_]*$") then
            error("invalid macro defenition key: "..tostring(k), 2)
        end
        if type(v) ~= "string" then
            error("invalid macro defenition value: "..tostring(v), 2)
        end
        macro[tostring(k)] = v
    end
end

-- expand macro parameters in text:
-- @name@ replased by macro[name]
local function translate(text)
	local translated = {}
	local start = 1   -- start of untranslated part in text
	while true do
		local from, to, id = string.find(text, "@([%w_]*)@", start)
		if not from then break end
		table.insert(translated, string.sub(text, start, from-1))
        if string.len(id) == 0 then
            expansion = "@"
        else
            expansion = macro[id]
        end
		table.insert(translated, expansion)
		start = to + 1
	end
    table.insert(translated, string.sub(text, start))
    return table.concat(translated,nil)
end


--[[ Source file processor ]]
local included = {} -- included files registry
local notFirstInclude = false
local prologue, epilogue
local petranslated -- indicate whether prologue & epilogue translated
local textChunks = {} -- translated text chunks

local function includeInform(name)
    includeInform = function (name)
        inform("include file '" .. name .. "'")
    end
end

-- include file name.atd
function atd.include(name)
    chkarg(1, "string", name)
    name = name .. ".atd"
    -- prevent recursive include
    if included[name] then
        error("recursive include of " .. name, 2)
    end
    included[name] = true
    -- load and run or report error
    includeInform(name)
    local includedFile, message = loadfile(name)
    if not includedFile then
        inform(message)
        os.exit(-1)
    end
    local res; res, message = pcall(includedFile)
    if not res then
        inform(message)
        os.exit(-1)
    end
    -- allow successive inclusion
    included[name] = nil
end

-- set prologue text once
function atd.prologue(text)
    chkarg(1, "string", text)
    if not prologue then
        prologue = text
    end
end

-- set epilogue text once
function atd.epilogue(text)
    chkarg(1, "string", text)
    if not epilogue then
        epilogue = text
    end
end

-- append translated text chunk to result,
-- translate prologue & epilogue at first chunk addition
function atd.body(text)
    chkarg(1, "string", text)
    if not petranslated then
        prologue = translate(prologue or "")
        epilogue = translate(epilogue or "")
        petranslated = true
    end
    table.insert(textChunks, translate(text))
end

function atd.format(...)
    atd.body(string.format(...))
end

-- write prologue, translated text chunks and epilogue to tex file
local function writeTranslatedText(name)
    chkarg(1, "string", name)
    name = name .. ".ttd"
    local file = assert(io.open(name, "w"))
    table.insert(textChunks, 1, prologue)
    table.insert(textChunks, epilogue)
    file:write(table.concat(textChunks,nil))
    file:close()
end


--[[ commands ]]
local function translate(name)
    inform("translate '" .. name .. ".atd' to '" .. name .. ".ttd'")
    atd.include(name)
    writeTranslatedText(name)
    textChunks = nil
    collectgarbage ("collect" )
end

local function texify(name, srcext)
    local fromfile, tofile = (name .. srcext), (name .. ".dvi")
    inform("create '" .. tofile .. "' from '" .. fromfile .. "'")
    --local ret_code = os.execute("texify --verbose --language=latex --tex-option=--halt-on-error --tex-option=--max-print-line=127 --tex-option=--enable-write18 " .. fromfile)
    local ret_code = os.execute("latex --halt-on-error --enable-write18 " .. fromfile);
    if 0 == ret_code then
        if (0 ==         os.execute("bibtex8 -H -c cp1251.csf " .. name)) then
            ret_code = os.execute("latex --halt-on-error --enable-write18 " .. fromfile);
        end
        if 0 == ret_code then
            ret_code = os.execute("latex --halt-on-error --enable-write18 " .. fromfile);
        end
        if 0 == ret_code then
            ret_code = os.execute("latex --halt-on-error --enable-write18 " .. fromfile);
        end
    end    
    if ret_code ~= 0 then
        os.exit(ret_code)
    end
end

local function dvips(name)
    local fromfile, tofile = (name .. ".dvi"), (name .. ".ps")
    inform("create '" .. tofile .. "' from '" .. fromfile .. "'")
    local ret_code = os.execute("dvips -Ppdf " .. name)
    if ret_code ~= 0 then
        os.exit(ret_code)
    end
end

local function ps2pdf(name)
    local fromfile, tofile = (name .. ".ps"), (name .. ".pdf")
    inform("create '" .. tofile .. "' from '" .. fromfile .. "'")
    local ret_code = os.execute("ps2pdf " .. fromfile)
    if ret_code ~= 0 then
        os.exit(ret_code)
    end
end

local function viewpdf(name)
    local filename = (name .. ".pdf")
    inform("open '" .. filename .. "'")
    local ret_code = os.execute('start "", "' .. filename .. '"')
    if ret_code ~= 0 then
        os.exit(ret_code)
    end
end

local function ttd2pdf(filename)
    texify(filename, ".ttd")
    dvips(filename)
    ps2pdf(filename)
--~     viewpdf(filename)
end

--------------------------------------------------------------------------------------------------------------
local function findAndReplaceMacroByPattern(opt, line, pattern)
--------------------------------------------------------------------------------------------------------------
    for macro, name, default in string.gmatch(line, pattern) do
        if macro and name then
            local substr = "";
            if opt.macro[name] then
                substr = opt.macro[name];
            elseif default then
                substr = default;
            end
            line = string.gsub(line, macro, substr);
        end
    end
    
    return line;
end

--------------------------------------------------------------------------------------------------------------
function findAndReplaceMacro(opt, line)
--------------------------------------------------------------------------------------------------------------
    line = string.gsub(line, '%s+', ' ');
    -- pattern '(@{([^{}]+)})[^{]?' disturb for search at example '@{macro1}@{macro2}', it can't find 2nd macro,
    -- so we use pattern '(@{([^{}]+)})', but the turn of patterns checking must be the same:
    -- 1. '(@{([^{}]+)}{([^{}]*)})'
    -- 2. '(@{([^{}]+)})'
    line = findAndReplaceMacroByPattern(opt, line, '(@{([^{}]+)}{([^{}]*)})');
    line = findAndReplaceMacroByPattern(opt, line, '(@{([^{}]+)})');
    return line;
end

--------------------------------------------------------------------------------------------------------------
function expandTemplate(opt, filenameWithoutExt, intermediateFileExt)
--------------------------------------------------------------------------------------------------------------
    local function print_warn(message)
        inform('WARNING: '..message);
    end
    
    local function print_verb(message)
        if true == opt.verbose then
            inform(message);
        end
    end
    
    -- we defined that our file 'name' is needed template document for compiling to PDF
    -- now we must read that template file, replace all macro at it, and combine that peaces into full LTeX document
    if not opt.template then
        error("can't open template file: path is unknown");
    end

    local hTemplateFile = io.open(opt.dir..opt.template, 'r');
    if not hTemplateFile then
        error("can't open template file: " .. opt.dir .. opt.template, 1);
    end
    
    local intermediateFileName = filenameWithoutExt .. '.' .. intermediateFileExt;
    local hIntermediateFile = io.open(opt.dir .. intermediateFileName, 'w');
    if not hIntermediateFile then
        hTemplateFile:close();
        error("can't open intermediate file: " .. opt.dir .. intermediateFileName, 1);
    end

    -- prepare some stuff
    if not opt.case then
        opt.case = '0';
    end
    local block_mode = '';
    
--     local tmpltRe = "^@([@{}%+])((%w*)%s*)(.*)";
--     local macroRe = ".*(@{([^{}%W]*)}({([^{]*)})?)";
    local tmpltRe = "^@([@{}%+])(%w*%s*)(.*)";
    local macroRe = ".*(@{([^{}]+)}({([^{}]*)})?)";
    -- process file line by line
    local n_line = 0;
    for line in hTemplateFile:lines() do
        local continue = false; -- this variable is needed for imitation of 'continue' command from python
        n_line = n_line + 1;
        local cmd, tags, tmplLine = string.match(line, tmpltRe);
        if cmd and tags and tmplLine then
            line = string.gsub(tmplLine, ' ', '');
            local numOfCase;
            if cmd == '}' then -- close block
                if block_mode == '' then
                    print_warn(string.format("unexpected command \@} at %s line %d. - ignore", opt.template, n_line));
                else
                    block_mode = '';
                    print_verb(string.format("command \@} at %s line %d. - close block", opt.template, n_line));
                end
            elseif cmd == '{' then -- open block
                if(block_mode ~= '') then
                    print_warn(string.format("nested command \@{ at %s line %d - ignore", opt.template, n_line));
                else
                    _, numOfCase = string.gsub(tags, opt.case, '%0');
                    if 0 == numOfCase then -- replasee by normal code of counting number of substring at string
                        block_mode = 'exclude block';
                    else
                        opt.case_use = 1;
                        block_mode = 'include block';
                    end
                    print_verb(string.format("command \@{%s at %s line %d - %s", tags, opt.template, n_line, block_mode));
                end
            else -- one line block
                _, numOfCase = string.gsub(tags, opt.case, '%0');
                if 0 == numOfCase then
                    print_verb(string.format("command \@-%s at %s line %d - exclude line", tags, opt.template, n_line));
                    continue = true;
                else
                    opt.case_used = 1;
                    print_verb(string.format("command \@-%s at %s line %d - include line", tags, opt.template, n_line));
                end
            end
        end        
        
        if false == continue and 'exclude block' ~= block_mode then
            hIntermediateFile:write(findAndReplaceMacro(opt, line) .. '\n');
        end
    end
    
    hTemplateFile:close();
    hIntermediateFile:close();

    if not opt.case_used then
        print_warn(string.format("case %s at %s line 1 don't used in template", opt.case, opt.name))
    end
end

--------------------------------------------------------------------------------------------------------------
function parseLineWithOpts(opt, line)
--------------------------------------------------------------------------------------------------------------
    -- Find options with values (GNU options)
    local function findGnuOpt(optName)
        local equalSign, leftLimiter = string.match(line, '%-%-'..optName.."([=%s]?)('?)");
        if equalSign and leftLimiter then
            local pattern;
            if '' ~= leftLimiter then -- i.e. "--case 'R'" or "--case='R'"
                pattern = '%-%-'..optName..equalSign..leftLimiter.."([^"..leftLimiter.."]+)"..leftLimiter.."?";
            else -- i.e. "--case R" or "--case=R"
                pattern = '%-%-'..optName..equalSign.."([^%s]+)";
            end
            
            local value = string.match(line, pattern);
            if value then
                opt[optName] = value;
                return;
            end
        end
    end
    
    local function findFlagOpt(optName)
        if string.match(line, '%-%-'..optName..'%W*') then
            opt[optName] = true;
        end
    end

    -- find --def options of view "--def <macro>='<value>'"
    local function findMacroDefinitions()
        if not opt['macro'] then opt['macro'] = {}; end
        for macro, _, value in string.gmatch(line, "%-%-def%s+([%w_%-]+)%s*[=%s]?%s*('?)([^']+)%2") do
            if macro and value then
                opt['macro'][macro] = value;
            end
        end
    end
    
    findGnuOpt('template');
    findGnuOpt('case');
    findFlagOpt('verbose');
    -- searching for others simple options
    -- ... (you may add here)
    
    findMacroDefinitions()
end

--------------------------------------------------------------------------------------------------------------
local function convertTexTemplateIfNeeded(name)
--------------------------------------------------------------------------------------------------------------
    local intermediateFileExt, defaultTexExt = 'src', 'tex';

    local filename = (name..'.'..defaultTexExt);
    inform("open '" .. filename .. "'");
    
    local texFileOptions = {};

    for line in io.lines(filename) do
        if not string.find(line, '^%s*%%.*%-%-') then
            -- i.e. this document is clear LaTeX without using templates and macro, whitch can parse latex_build.py
            inform('File is pure LaTeX document. Nomacro replacement needed.');
            return '.'..defaultTexExt;
        end
        inform("File is LaTeX document, using template and macro. Begin parsing.");
        parseLineWithOpts(texFileOptions, line);
        -- add some options, with can't be founded from 1st line of TeX file
        texFileOptions.dir = lfs.currentdir() .. '\\';
        texFileOptions.macro['FILE_NAME'] = filename;

        expandTemplate(texFileOptions, name, intermediateFileExt)
        break;
    end
    
    return '.'..intermediateFileExt;
end

local function tex2pdf(filename)
    texify(filename, convertTexTemplateIfNeeded(filename))
    dvips(filename)
    ps2pdf(filename)
--~     viewpdf(filename)
end

local function build(filename)
    translate(filename)
    ttd2pdf(filename)
end


function getFileOptions(opt)
end

--[[ options ]]
local function onHelp()
    io.write (
        "atd.lua [-h] command filename\n" ..
        "Options:\n" ..
        "\t-h\t\tprint this message and exit\n" ..
        "Operands:\n" ..
        "\tcommand\tone of translate, build, tex2pdf, view\n" ..
        "\tfilename\tfile name without extension\n"
    )
    os.exit(0)
end


--[[ main ]]
assert(require("lopt"))
local function main()
    -- parse arguments
    lopt.handlers
    {
        h = onHelp
    }

    local function onArgumentError(msg)
        inform(msg)
        inform("use -h to short command line usage help")
        os.exit(-1)
    end

    local command, filename, unexpectedOperand = unpack(arg, lopt.run(arg))

    -- check operands
    if not command then onArgumentError("command not specified") end
    if not filename then onArgumentError("file name not specified") end
    if unexpectedOperand then onArgumentError("unexpected operand: " .. unexpectedOperand) end

    -- execute command
    local commands =
    {
        translate = translate,
        tex2pdf = tex2pdf,
        view = viewpdf,
        build = build
    }
    local cmdfunc = commands[command]
    if cmdfunc then
        cmdfunc(filename)
    else
        onArgumentError("unknown command: " .. command)
    end
    os.exit(0)
end

--[[ bootstrap ]]
res, message = pcall(main)
if not res then
    inform(message)
    os.exit(-1)
end
