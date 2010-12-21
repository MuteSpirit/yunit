-- -*- coding: utf-8 -*-

local luaExt = require('lua_ext');
require('lua_date');

module(..., package.seeall)

local lfs = require("lfs")

--- \brief Define on what operating system script is run
--- \return 'win' or 'unix'
--------------------------------------------------------------------------------------------------------------
function whatOs()
--------------------------------------------------------------------------------------------------------------
    local tmp = os.getenv('TMP');
    if string.match(tmp, '^%w:') then
        return 'win'
    else
        return 'unix'
    end
end

--------------------------------------------------------------------------------------------------------------
function osSlash()
--------------------------------------------------------------------------------------------------------------
    return 'win' == whatOs() and '\\' or '/';
end

--------------------------------------------------------------------------------------------------------------
function slash()
--------------------------------------------------------------------------------------------------------------
    return '/';
end

--------------------------------------------------------------------------------------------------------------
function dir(path)
--------------------------------------------------------------------------------------------------------------
    return lfs.dir(path);
end

--------------------------------------------------------------------------------------------------------------
function chdir(path)
--------------------------------------------------------------------------------------------------------------
    return lfs.chdir(path);
end

--------------------------------------------------------------------------------------------------------------
function canonizePath(path, separator)
--------------------------------------------------------------------------------------------------------------
    local separator = separator or slash();
    local pre = '';
    local i, j = string.find(path, '^[/\\]+');
    local str = path;
    if nil ~= i then
        pre = string.sub(path, i, j);
        str, n = string.gsub(str, '^[/\\]+', '');
    end
    str, n = string.gsub(str, '[/\\]+', separator);
    return pre .. str;
end

--------------------------------------------------------------------------------------------------------------
function currentdir()
--------------------------------------------------------------------------------------------------------------
    return canonizePath(lfs.currentdir(), slash()) .. slash();
end

--------------------------------------------------------------------------------------------------------------
function tmpDirName()
--------------------------------------------------------------------------------------------------------------
    local slash = slash();
    local tmp, curDir = canonizePath(os.getenv('TMP'), slash), currentdir();
    chdir(tmp);
    local path = canonizePath(tmp .. os.tmpname() .. tostring(os.time()) .. slash, slash);
    chdir(curDir);
    return path;
end


--------------------------------------------------------------------------------------------------------------
function filename(path)
--------------------------------------------------------------------------------------------------------------
    local filePath = canonizePath(path);

    local extRe = '%.([%w%_%-]+)%s*$';
    local nameRe = '/?([%w%_%-%.%s]+)$';

    local ext = string.match(filePath, extRe) or '';
    local name = string.match(string.gsub(filePath, extRe, ''), nameRe) or '';

    local dirpathEndPos = string.len(filePath);
    local filenameRe = name;
    if '' ~= ext then
        filenameRe = filenameRe .. '.' .. ext;
    end
    if '.' ~= filenameRe then
        filenameRe = luaExt.convertTextToRePattern(filenameRe) .. '%s*$';
        dirpathEndPos = string.find(filePath, filenameRe) - 1;
    end
    local dirpath = canonizePath(string.sub(filePath, 0, dirpathEndPos), slash());

    return name, ext, dirpath;
end

--------------------------------------------------------------------------------------------------------------
function dirname(path)
--------------------------------------------------------------------------------------------------------------
    _, _, path = filename(path);
    return path;
end

-- return 0 if all is Ok
--------------------------------------------------------------------------------------------------------------
function mkdir(dirPath)
--------------------------------------------------------------------------------------------------------------
--     return os.execute('mkdir ' .. dirPath)
    return lfs.mkdir(canonizePath(dirPath, osSlash()));
end

function rmfile(path)
    return os.remove(path);
end

--------------------------------------------------------------------------------------------------------------
function rmdir(dirPath)
--------------------------------------------------------------------------------------------------------------
--     if 0 == os.execute('rmdir /s/q ' .. dirPath) then
--         return true
--     else
--         return false
--     end
    local slash = osSlash();                  -- OS slash
    dirPath = canonizePath(dirPath, slash)

    for file in dir(dirPath) do
        if '.' ~= file and '..' ~= file then
            if isDir(dirPath .. file .. slash) then
                local res, msg = rmdir(dirPath .. file .. slash);
                if not res then
                    return res, msg;
                end
            else
                local res, msg = rmfile(dirPath .. file);
                if not res then
                    return res, msg;
                end
            end
        end
    end

    return lfs.rmdir(dirPath);
end

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
function isNetworkPath(path)
    return nil ~= string.find(path, '^\\\\[a-zA-z0-9]');
end

--------------------------------------------------------------------------------------------------------------
function isLocalFullPath(path)
    local pattern = {win = {'^[a-zA-z]%:', '^[/\\][^/\\]', '^[/\\]+$'}, unix = {'^[%/%~]',}};
    for _, patRe in ipairs(pattern[whatOs()]) do
        if string.find(path, patRe) then
            return true;
        end
    end
    return false;
end

--------------------------------------------------------------------------------------------------------------
function isLocalPath(path)
    return isLocalFullPath(path) or isRelativePath(path);
end

--------------------------------------------------------------------------------------------------------------
function isFullPath(path)
    return isNetworkPath(path) or isLocalFullPath(path);
end

--------------------------------------------------------------------------------------------------------------
function isRelativePath(path)
--------------------------------------------------------------------------------------------------------------
    local pattern = {'^%.[/\\]', '^%.%.[/\\]'};
    for _, patRe in ipairs(pattern) do
        if string.find(path, patRe) then
            return true;
        end
    end
    return false;
end

--------------------------------------------------------------------------------------------------------------
function absPath(path, folderPath)
--------------------------------------------------------------------------------------------------------------
    folderPath = folderPath or currentdir();
    if not path then
        return folderPath;
    end

-- ??? 'path' must be in canonical view
--     path = canonizePath(path);
    path = (isFullPath(path) and path) or folderPath .. path;

    local file, ext, dirPath = filename(path);
    if ext and '' ~= ext then
        file = file .. '.' .. ext;
    end

    local slash = slash();  -- slash ('/') sign
    local real = {};        -- table, containing names of dirs

    for dir in string.gmatch(dirPath, '[^/\\]+') do
        if '.' ~= dir then
            if ".." == dir then
                table.remove(real);
            else
                table.insert(real, dir);
            end
        end
    end

    return table.concat(real, slash) .. slash .. file;
end

--------------------------------------------------------------------------------------------------------------
function relativePath(path, basePath)
--------------------------------------------------------------------------------------------------------------
    local _, endPos = string.find(path, basePath, 1, true);
    return string.sub(path, endPos + 1);
end

--------------------------------------------------------------------------------------------------------------
function fileTemplToRe(templ)
--------------------------------------------------------------------------------------------------------------
--  magic characters: ( ) . % + - * ? [ ^ $
--  replacements: '%(', '%)', '%.', '%%', '%+', '%-', '.*', '.', '%[', '%^', '%$' respectively
    templ = string.gsub(templ, '([%(%)%.%%%+%-%[%]%^%$])', '%%%1');
    templ = string.gsub(templ, '%?', '[^/\\]?');
    templ = string.gsub(templ, '%*', '[^/\\]*');
    return templ .. '$';
end

--------------------------------------------------------------------------------------------------------------
function includeFile(path, template)
--------------------------------------------------------------------------------------------------------------
    return nil ~= string.match(path, fileTemplToRe(template));
end


--------------------------------------------------------------------------------------------------------------
function includeFiles(pathList, template)
--------------------------------------------------------------------------------------------------------------
    local pathes = {};

    for _, filename in ipairs(pathList) do
        if includeFile(filename, template) then
            table.insert(pathes, filename);
        end
    end

    return pathes;
end

--------------------------------------------------------------------------------------------------------------
function excludeFiles(pathList, template)
--------------------------------------------------------------------------------------------------------------
    local pathes = {};
    local pattern = fileTemplToRe(template);

    for _, filename in ipairs(pathList) do
        if not string.match(filename, pattern) then
            table.insert(pathes, filename);
        end
    end

    return pathes;
end

--------------------------------------------------------------------------------------------------------------
function isExist(path)
--------------------------------------------------------------------------------------------------------------
    if string.find(path, '^%w%:$') then
        path = path .. '/';
    elseif not string.find(path, '^%w%:[/\\]+$') then
        path = string.gsub(path, '[/\\]*$', '');
    end

    return nil ~= lfs.attributes(path, 'mode');
end


--------------------------------------------------------------------------------------------------------------
function isFile(path)
--------------------------------------------------------------------------------------------------------------
    return 'file' == lfs.attributes(string.gsub(path, '[/\\]*$', ''), 'mode');
end


--------------------------------------------------------------------------------------------------------------
function isDir(path)
--------------------------------------------------------------------------------------------------------------
    if string.find(path, '^%w%:$') then
        path = path .. '/';
    elseif not string.find(path, '^%w%:[/\\]+$') then
        path = string.gsub(path, '[/\\]*$', '');
    end
    
    return 'directory' == lfs.attributes(path, 'mode');
end

function applyOnFiles(dirPath, namedArgs)
    namedArgs = namedArgs or {};
    if not dirPath or not namedArgs.handler or not isDir(dirPath) then
        return;
    end
    
    local filter = namedArgs.filter or function(path, state) return true; end
    
    local slash = slash();
    local path;
    
    for file in dir(dirPath) do
        if '.' ~= file and '..' ~= file then
            path = dirPath .. file;
            if filter(path, namedArgs.state) then
                namedArgs.handler(path, namedArgs.state);
            end

            if isDir(path .. slash) and namedArgs.recursive then
                applyOnFiles(path .. slash, namedArgs);
            end
        end
    end
end


--- \param[in] dirname path to directory for finding subfiles
--------------------------------------------------------------------------------------------------------------
function ls(dirname, adtArg)
--------------------------------------------------------------------------------------------------------------
    adtArg = adtArg or {};
    local res = {};

    local function savePath(path, state)
        local isItDir = isDir(path);
        if not adtArg.fullPath then
            local name, ext = filename(path);
            path = name;
            if ext and '' ~= ext then
                path = path .. '.' .. ext;
            end
        end

        if adtArg.showDirs and isItDir or not isItDir and adtArg.showFiles then
            table.insert(state, path);
        end
    end
    
    applyOnFiles(dirname, {handler = savePath, state = res, recursive = adtArg.recursive});
    
    return res;
end

-----------------------------------------------------
function du(path)
    if isFile(path) then
        return fileSize(path);
    end

    local function calculateSize(path, state)
        if isFile(path) then
            state.size = state.size + fileSize(path);
        end
    end
    
    local adtArg = {handler = calculateSize, state = {size = 0}, recursive = true};
    applyOnFiles(path, adtArg);
    
    return adtArg.state.size;
end

-----------------------------------------------------
function copyFile(srcFilePath, dstFilePath, binary)
    local readMode, writeMode = 'r', 'w';
    if binary then
        readMode = readMode .. 'b';
        writeMode = writeMode .. 'b';
    end

    local hSrcFile = io.open(srcFilePath, readMode);
    if not hSrcFile then
        local errMsg = 'Can\'t open source file: "' .. srcFilePath .. '"';
        return false, errMsg;
    end

    local hDstFile = io.open(dstFilePath, writeMode);
    if not hDstFile then
        local errMsg = 'Can\'t open destination file: "' .. dstFilePath .. '"';
        return false, errMsg;
    end

    hDstFile:write(hSrcFile:read('*a'));

    hDstFile:close();
    hSrcFile:close();

    return true;
end

function copyDir(srcDirPath, dstDirPath)
--~     local dirs = string.split(srcDirPath, '[/\\]+');
--~
--~     local copiedDir = dirs[#dirs];
--~     if not copiedDir or 0 == string.len(copiedDir) then
--~         copiedDir = dirs[#dirs - 1];
--~     end
--~
--~     local status, errMsg = true, '';
--~     status, errMsg = fs.mkdir(dstDirPath);
--~     if not status then
--~         return status, errMsg;
--~     end
--~
--~     local files = fs.ls(srcDirPath, {recursive = false, fullPath = true, showFiles = true});
--~     for _, filePath in ipairs(files) do
--~         copyFile
--~     end
--~
--~     return true;
    return false;
end

------------------------------------------------------
function copyBinaryFile(srcFilePath, dstFilePath)
    return copyFile(srcFilePath, dstFilePath, true);
end

------------------------------------------------------
function copy(srcPath, dstPath)
    if isFile(srcPath) and (not isExist(dstPath) or isFile(dstPath)) then
        return copyFile(srcPath, dstPath);
    end
end

------------------------------------------------------
function bytesTo(sizeInBytes, sizeDimension)
    local size = sizeInBytes;
    if sizeDimension then
        if 'k' == sizeDimension or 'K' == sizeDimension then
            size = sizeInBytes / 1024;
        elseif 'M' == sizeDimension then
            size = sizeInBytes / (1024 * 1024);
        elseif 'G' == sizeDimension then
            size = sizeInBytes / (1024 * 1024 * 1024);
        end
    end
    return size;
end

------------------------------------------------------
function fileSize(path)
    return lfs.attributes(path, 'size') or 0;
end

------------------------------------------------------
function fileLastModTime(path)
    return os.date('*t', lfs.attributes(path, 'change'));
end

------------------------------------------------------
function touch(filepath, atime, mtime)
    return lfs.touch(filepath, atime, mtime);
end

------------------------------------------------------
function fileContentAsString(path)
    local hFile, errMsg = io.open(path, 'r');
    if not hFile then
        return hFile, errMsg;
    end
    local str = hFile:read('*a');
    hFile:close();
    return str;
end

------------------------------------------------------
function fileContentAsLines(path)
    local lines = {};
    for line in io.lines(path) do
        table.insert(lines, line);
    end
    return lines;
end

------------------------------------------------------
function localPathAsNetworkPath(localPath)
    return string.gsub(localPath, '^([%a%d]):', '\\\\localhost/%1$');
end