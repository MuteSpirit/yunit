-- -*- coding: utf-8 -*-

local luaExt = require('lua_ext');

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
function canonizePath(path)
--------------------------------------------------------------------------------------------------------------
    local separator = osSlash();
    -- Skip slashes at NetBios path begin 
    local beginPos, endPos = string.find(path, '^[/\\]+');
    
    local prefixSlashes = '';
    if beginPos and endPos then
        prefixSlashes = string.sub(path, beginPos, endPos);
        path = string.sub(path, endPos + 1, string.len(path));
    end
    path = string.gsub(path, '[/\\]+', separator);
    
    local reOnlyDiskLetterWithColon = '^%w%:$';
    local reDiskLetterWithColonAndSlashes = '^%w%:[/\\]+$';
    if string.find(path, reOnlyDiskLetterWithColon) then
        path = path .. separator;
    elseif not string.find(path, reDiskLetterWithColonAndSlashes) then
        path = string.gsub(path, '[/\\]*$', '');
    end
    
    return prefixSlashes .. path;
end

--------------------------------------------------------------------------------------------------------------
function tmpDirName()
--------------------------------------------------------------------------------------------------------------
    local slash = osSlash();
    local tmp, curDir = canonizePath(os.getenv('TMP')), lfs.currentdir();
    lfs.chdir(tmp);
    local path = canonizePath(tmp .. os.tmpname() .. tostring(os.time()));
    lfs.chdir(curDir);
    return path;
end

--------------------------------------------------------------------------------------------------------------
function split(path)
--------------------------------------------------------------------------------------------------------------
    local reSeparator = '[/\\]+'
    local head, tail

    -- Skip slashes at NetBios path begin 
    local beginPos, endPos = string.find(path, '^' .. reSeparator);
    
    local prefixSlashes = '';
    if beginPos and endPos then
        prefixSlashes = string.sub(path, beginPos, endPos);
        path = string.sub(path, endPos + 1, string.len(path));
    end
    
    local lastSlashPos = string.find(string.reverse(path), reSeparator)
    if lastSlashPos and lastSlashPos > 1 then
        head = string.sub(path, 1, -lastSlashPos - 1)
        tail = string.sub(path, -lastSlashPos + 1, -1)
    elseif not lastSlashPos then
        local reOnlyDiskLetterWithColon = '^%w%:$';
        if string.find(path, reOnlyDiskLetterWithColon) or string.len(prefixSlashes) > 0 then
            head = path
            tail = ''
        else
            head = ''
            tail = path
        end
    else
        head = path
        tail = ''
    end
    
    return canonizePath(prefixSlashes .. head), tail
end

--------------------------------------------------------------------------------------------------------------
function filename(path)
--------------------------------------------------------------------------------------------------------------
    local slash = osSlash();

    _, path = split(path);

    local extRe = '%.([%w%_%-]+)%s*$';
    local nameRe = '/?([%w%_%-%.%s]+)$';

    local ext = string.match(path, extRe) or '';
    local name = string.match(string.gsub(path, extRe, ''), nameRe) or '';

    return name, ext;
end

--------------------------------------------------------------------------------------------------------------
function dirname(path)
--------------------------------------------------------------------------------------------------------------
    path, _ = split(path);
    return path;
end

--------------------------------------------------------------------------------------------------------------
function rmdir(dirPath)
--------------------------------------------------------------------------------------------------------------
    local slash = osSlash();
    dirPath = canonizePath(dirPath)

    for file in lfs.dir(dirPath) do
        if '.' ~= file and '..' ~= file then
            if isDir(dirPath .. slash .. file) then
                local res, msg = rmdir(dirPath .. slash .. file);
                if not res then
                    return res, msg;
                end
            else
                local res, msg = os.remove(dirPath .. slash .. file);
                if not res then
                    return res, msg;
                end
            end
        end
    end

    return lfs.rmdir(dirPath);
end

--------------------------------------------------------------------------------------------------------------
function isNetworkPath(path)
--------------------------------------------------------------------------------------------------------------
   return nil ~= string.find(path, '^\\\\[a-zA-z0-9]');
end

--------------------------------------------------------------------------------------------------------------
function isLocalFullPath(path)
--------------------------------------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------------------------------------
    return isLocalFullPath(path) or isRelativePath(path);
end

--------------------------------------------------------------------------------------------------------------
function isFullPath(path)
--------------------------------------------------------------------------------------------------------------
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
function absPath(path, basePath)
--------------------------------------------------------------------------------------------------------------
    local slash = osSlash();
    basePath = basePath or lfs.currentdir();
    if not path then
        return basePath;
    end

    path = canonizePath(path);
    path = (isFullPath(path) and path) or basePath .. slash .. path;

    local file, ext = filename(path)
    if ext and '' ~= ext then
        file = file .. '.' .. ext
    end

    dirPath = dirname(path)
    
    local real = {};        -- table, containing names of dirs

    for dir in string.gmatch(dirPath, '[^' .. slash .. ']+') do
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
function fileWildcardToRe(templ)
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
    return nil ~= string.match(path, fileWildcardToRe(template));
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
    local pattern = fileWildcardToRe(template);

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
    return 'directory' == lfs.attributes(canonizePath(path), 'mode');
end

--------------------------------------------------------------------------------------------------------------
-- Filters for function applyOnFiles
--------------------------------------------------------------------------------------------------------------

function noFilter(path, state)
    return true
end

function fileFilter(path, state)
    return isFile(path)
end

function dirFilter(path, state)
    return isDir(path)
end

--------------------------------------------------------------------------------------------------------------
function applyOnFiles(dirPath, namedArgs)
--------------------------------------------------------------------------------------------------------------
    if not namedArgs and not dirPath or not namedArgs.handler or not isDir(dirPath) then
        return;
    end
    
    local filter = namedArgs.filter or noFilter
    local handler = namedArgs.handler
    
    local slash = osSlash();
    local path;
    
    for file in lfs.dir(dirPath) do
        if '.' ~= file and '..' ~= file then
            path = dirPath .. slash .. file;
            if filter(path, namedArgs.state) then
                handler(path, namedArgs.state);
            end

            if isDir(path) and namedArgs.recursive then
                applyOnFiles(path, namedArgs);
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

--------------------------------------------------------------------------------------------------------------
function du(path)
--------------------------------------------------------------------------------------------------------------
    if isFile(path) then
        return lfs.attributes(path, 'size');
    end

    local function calculateSize(path, state)
        state.size = state.size + lfs.attributes(path, 'size');
    end
    
    local adtArg = {filter = fileFilter, handler = calculateSize, state = {size = 0}, recursive = true};
    applyOnFiles(path, adtArg);
    
    return adtArg.state.size;
end

--------------------------------------------------------------------------------------------------------------
function copyFile(src, dst)
--------------------------------------------------------------------------------------------------------------
    if dst == src then
        return nil, 'Trying to copy file to the same path'
    end
    local readMode, writeMode = 'rb', 'wb';

    local hSrcFile = io.open(src, readMode);
    if not hSrcFile then
        local errMsg = 'Can\'t open source file: "' .. src .. '"';
        return nil, errMsg;
    end

    local hDstFile = io.open(dst, writeMode);
    if not hDstFile then
        hSrcFile:close();
        local errMsg = 'Can\'t open destination file: "' .. dst .. '"';
        return nil, errMsg;
    end

    hDstFile:write(hSrcFile:read('*a'));

    hDstFile:close();
    hSrcFile:close();

    return true;
end

--------------------------------------------------------------------------------------------------------------
function copyDir(src, dst)
--------------------------------------------------------------------------------------------------------------
    if isFile(src) then
        return nil, 'Can\'t copy something other than directory'
    end
    if isFile(dst) then
        return nil, 'Can\'t copy dir into file'
    end
    
    local status, errMsg;
    local baseSrcPath = split(src)
    
    local function processDir(dirPath)
        status, errMsg = lfs.mkdir(string.gsub(dirPath, luaExt.convertTextToRePattern(baseSrcPath), dst))
        if not status then
            return status, errMsg
        end
    end
    
    processDir(src)
    local dirs = ls(src, {recursive = true, fullPath = true, showDirs = true})
    for i = 1, #dirs do
        processDir(dirs[i])
    end
    
    local files = ls(src, {recursive = true, fullPath = true, showFiles = true})
    for i = 1, #files do
        status, errMsg = copyFile(files[i], string.gsub(files[i], luaExt.convertTextToRePattern(baseSrcPath), dst))
        if not status then
            return status, errMsg
        end
    end
    
    return true;
end

--------------------------------------------------------------------------------------------------------------
function bytesTo(sizeInBytes, sizeDimension)
--------------------------------------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------------------------------------
function localPathAsNetworkPath(localPath)
--------------------------------------------------------------------------------------------------------------
    return string.gsub(localPath, '^([%a%d]):', '\\\\localhost/%1$');
end