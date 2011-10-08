 -- -*- coding: utf-8 -*-

-- Documentation


--- \fn whatOs()
--- \brief Define operative system, on which script is runned
--- \return 'win' or 'unix'

--- \fn osSlash()
--- \brief Define what slash is using in pathes on operative system, on which script is runned
--- \return slash or backslash

--- \fn canonizePath(path)
--- \return Return path, where backslashes are replaced with result of osSlash()

--- \fn tmpDirName()
--- \return Return new name of temporary directory every call (theoretically)

--- \fn split(path)
--- \brief Split the pathname path into a pair, (head, tail) where tail is the last pathname component and head 
--- is everything leading up to that. The tail part will never contain a slash; if path ends in a slash, tail will be 
--- empty. If there is no slash in path, head will be empty. If path is empty, both head and tail are empty.
--- Trailing slashes are stripped from head unless it is the root (one or more slashes only). In all cases,
--- join(head, tail) returns a path to the same location as path (but the strings may differ).

--- \fn filename(path)
--- \param path Full or relative path of file
--- \return two value: name and extension of file or '' value for every undefined part

--- \fn dirname(path)
--- \param[in] path Full or relative path of file
--- \return Path to dir

--- \fn rmdir(dirPath)
--- \brief Removes an existing directory
--- \param[in] dirPath Name of the directory.
--- \return Returns true if the operation was successful; in case of error, it returns nil plus an error string.
--- \details !!! remove directory with all content without any question

--- \fn isFullPath(path)
--- \brief Define is 'path' is full path or not.

--- \fn isRelativePath(path)
--- \brief Define is 'path' is relative path or not.

--- \fn absPath(path, folderPath)
--- \brief Current function convert "path" to absolute with correct deletting dirs . and ..
--- \param[in] path Must be in canonical view
--- \param[in] folderPath This path will set before 'path' if 'path' is not full path. Default value of
--- parameter is equal fs.currentdir()
--- \details "path" may not exist \n
--- If "path" is relative, then we assume, that it is relative to current directory \n
--- If "path" None, then function return current dir path, finished with "slash"

--- \fn fileWildcardToRe(templ)
--- \param[in] templ file template, which may contain special symbols '?' and '*'
--- \return Return regular expression pattern, converted from file template

--- \fn includeFile(path, template)
--- \param[in] path Path to file in canonical form
--- \param[in] template File template, which may contain special symbols '?' and '*'
--- \return true if 'path' is correspond to 'template', false otherwise

--- \fn includeFiles(pathList, template)
--- \brief Filter of pathes during 'pathList' in compliance with 'template'
--- \return List of residuary pathes

--- \fn excludeFiles(pathList, template)
--- \brief Exclude pathes from 'pathList' in compliance with 'template'
--- \return List of residuary pathes

--- \fn isExist(path)
--- \brief Define is exist filesystem object (file or directory)
--- \return true if exist, false otherwise

--- \fn isFile(path)

--- \fn isDir(path)

---\fn ls(dirname, adtArg)
---\brief выводит список файлов и/или подкаталогов данного каталога
--- \param[in] dirname каталог, содержимое которого необходимо вывести
--- \param[in] adtArg таблица, задающая параметры вывода:
--- \details adtArg.showDirs если true, то будут выведены названия каталогов \n
--- adtArg.showFiles если true, то будут выведены названия файлов \n
--- adtArg.fullPath если true, то будут выведены полные пути к файлам и подкаталогам \n
--- adtArg.recursive если true, то будут просмотрены все подкаталоги \n
--- \return list of files and/or dirs

---\fn copyFile(src, dst)
---\brief Copy one file to another file (works ONLY with files)
--- \param[in] src Full or relative path to file, which will be copied
--- \param[in] dst Full or relative path to file, which will be appeared
--- \return true in success or nil and error message in failure case

--- \fn isNetworkPath(path)
--- \param[in] path Full network path 
--- \return true if 'path' is path of file or folder inside network share folder, otherwise return false

--- \fn isLocalPath(path)
--- \param[in] path Full or relative local file or folder path
--- \return true if 'path' is path of file or folder on local disk location

local lfs = require "lfs"
local fs = require "yunit.filesystem"
local luaExt = require "yunit.lua_ext"
local atf = require "yunit.aux_test_func"

local luaUnit = require 'yunit.luaunit'



useTestTmpDirFixture = 
{
    setUp = function(self)
        tmpDir = fs.tmpDirName();
        isNotNil(tmpDir);
        local curDir = lfs.currentdir();
        isNotNil(curDir);
        isNil(lfs.chdir(tmpDir));
        isTrue(lfs.mkdir(tmpDir));
        isTrue(lfs.chdir(tmpDir));
        isTrue(lfs.chdir(curDir));
    end
    ;

    tearDown = function(self)
        isNotNil(tmpDir);
        isTrue(lfs.chdir(tmpDir .. fs.osSlash() .. '..'))
        local status, msg = fs.rmdir(tmpDir)
        areEq(nil, msg)
        isTrue(status)
    end
    ;
};

useWinPathDelimiterFixture = 
{
    setUp = function(self)
        self.osSlash = fs.osSlash
        fs.osSlash = function() return '\\'; end
    end;

    tearDown = function(self)
        fs.osSlash = self.osSlash
    end;
}

useUnixPathDelimiterFixture = 
{
    setUp = function(self)
        self.osSlash = fs.osSlash
        fs.osSlash = function() return '/'; end
    end
    ;
    tearDown = function(self)
        fs.osSlash = self.osSlash
    end
    ;
}

function useUnixPathDelimiterFixture.unixCanonizePath()
    areEq('c:/path/to/dir', fs.canonizePath('c:/path/to/dir/'))
    areEq('c:/path/to/dir', fs.canonizePath('c:\\path\\to\\dir\\'))
    areEq('c:/path/to/dir/subdir', fs.canonizePath('c:\\path/to//dir\\\\subdir'))
    areEq('\\\\host1/path/to/dir/subdir', fs.canonizePath('\\\\host1\\path/to//dir\\\\subdir'))
    areEq('//host2/path/to/dir/subdir', fs.canonizePath('//host2\\path/to//dir\\\\subdir'))
    areEq('c:/', fs.canonizePath('c:'));
    areEq('c:/', fs.canonizePath('c:/'));
    areEq('/', fs.canonizePath('/'));
end

if fs.whatOs() == 'win' then
    function useWinPathDelimiterFixture.winCanonizePath(self)
        areEq('c:\\path\\to\\dir', fs.canonizePath('c:/path/to/dir/'))
        areEq('c:\\path\\to\\dir', fs.canonizePath('c:\\path\\to\\dir\\'))
        areEq('c:\\path\\to\\dir\\subdir', fs.canonizePath('c:\\path/to//dir\\\\subdir'))
        areEq('\\\\host1\\path\\to\\dir\\subdir', fs.canonizePath('\\\\host1\\path/to//dir\\\\subdir'))
        areEq('//host2\\path\\to\\dir\\subdir', fs.canonizePath('//host2\\path/to//dir\\\\subdir'))
        areEq('c:\\', fs.canonizePath('c:'));
        areEq('c:\\', fs.canonizePath('c:\\'));
        areEq('\\', fs.canonizePath('\\'));
    end
end

function useUnixPathDelimiterFixture.splitFullPathTest()
    local head, tail;
    head, tail = fs.split('c:/dir/file.ext')
    areEq('c:/dir', head)
    areEq('file.ext', tail)

    head, tail = fs.split('c:/dir/file')
    areEq('c:/dir', head)
    areEq('file', tail)
    
    head, tail = fs.split('c:/dir/')
    areEq('c:/dir', head)
    areEq('', tail)
    
    head, tail = fs.split('c:/dir')
    areEq('c:/', head)
    areEq('dir', tail)
end

function useUnixPathDelimiterFixture.splitRootPathsTest()
    local head, tail;
    head, tail = fs.split('c:/')
    areEq('c:/', head)
    areEq('', tail)

    head, tail = fs.split('c:')
    areEq('c:/', head)
    areEq('', tail)

    head, tail = fs.split('/')
    areEq('/', head)
    areEq('', tail)
end

function useUnixPathDelimiterFixture.splitRelativePathsTest()
    local head, tail;
    
    head, tail = fs.split('file.ext')
    areEq('', head)
    areEq('file.ext', tail)

    head, tail = fs.split('./')
    areEq('.', head)
    areEq('', tail)

    head, tail = fs.split('./file.ext')
    areEq('.', head)
    areEq('file.ext', tail)
    
    head, tail = fs.split('../')
    areEq('..', head)
    areEq('', tail)
    
    head, tail = fs.split('../file.ext')
    areEq('..', head)
    areEq('file.ext', tail)
end

function useUnixPathDelimiterFixture.splitNetworkPathsTest()
    local head, tail;
    head, tail = fs.split('\\\\pc-1')
    areEq('\\\\pc-1', head)
    areEq('', tail)

    head, tail = fs.split('\\\\pc-1/file.ext')
    areEq('\\\\pc-1', head)
    areEq('file.ext', tail)
end
    
function useUnixPathDelimiterFixture.filenameTest()
    local name, ext, dir;
    name, ext = fs.filename('c:/readme.txt');
    isNotNil(name);
    isNotNil(ext);
    areEq('txt', ext);
    areEq('readme', name);

    name, ext = fs.filename('/tmp/readme.txt');
    isNotNil(name);
    isNotNil(ext);
    areEq('txt', ext);
    areEq('readme', name);

    name, ext = fs.filename('./readme.txt');
    isNotNil(name);
    isNotNil(ext);
    areEq('txt', ext);
    areEq('readme', name);

    name, ext = fs.filename('c:/readme.txt.bak');
    isNotNil(name);
    isNotNil(ext);
    areEq('bak', ext);
    areEq('readme.txt', name);

    name, ext = fs.filename('c:/README');
    isNotNil(name);
    isNotNil(ext);
    areEq(ext, '');
    areEq(name, 'README');

    name, ext = fs.filename('c:/');
    isNotNil(name);
    isNotNil(ext);
    areEq(ext, '');
    areEq(name, '');

    name, ext = fs.filename('c:/readme.txt ');
    isNotNil(name);
    isNotNil(ext);
    areEq('txt', ext);
    areEq('readme', name);

    name, ext = fs.filename('c:/readme_again.tx_t');
    isNotNil(name);
    isNotNil(ext);
    areEq('tx_t', ext);
    areEq('readme_again', name);

    name, ext = fs.filename('c:\\path\\to\\dir\\readme_again.tx_t');
    isNotNil(name);
    isNotNil(ext);
    areEq('tx_t', ext);
    areEq('readme_again', name);

    name, ext = fs.filename('d:/svn_wv_rpo_trunk/.svn/dir-prop-base');
    isNotNil(name);
    isNotNil(ext);
    areEq('', ext);
    areEq('dir-prop-base', name);

    name, ext = fs.filename('d:/svn_wv_rpo_trunk/.svn/dir-prop-base');
    isNotNil(name);
    isNotNil(ext);
    areEq('', ext);
    areEq('dir-prop-base', name);

    name, ext= fs.filename('d:/svn_wv_rpo_trunk/dir-prop-base/.svn/dir-prop-base');
    isNotNil(name);
    isNotNil(ext);
    areEq('', ext);
    areEq('dir-prop-base', name);

    name, ext = fs.filename('d:/svn_wv_rpo_trunk/.svn');
    isNotNil(name);
    isNotNil(ext);
    areEq('svn', ext);
    areEq('', name);

    name, ext = fs.filename('d:/svn_wv_rpo_trunk/.svn/.svn');
    isNotNil(name);
    isNotNil(ext);
    areEq('svn', ext);
    areEq('', name);

    name, ext = fs.filename('gepart_ac.ini');
    isNotNil(name);
    isNotNil(ext);
    areEq('gepart_ac', name);
    areEq('ini', ext);

    name, ext = fs.filename('test spaces.ini');
    isNotNil(name);
    isNotNil(ext);
    areEq('test spaces', name);
    areEq('ini', ext);
end


function isExistTest()
    isTrue(fs.isExist(lfs.currentdir()));
    if 'win' == fs.whatOs() then
	isTrue(fs.isExist('c:/'));
	isTrue(fs.isExist('c:'));
    else
	isTrue(fs.isExist('/home/'));
    end
end

function isDirTest()
    local path;
    
    isTrue(fs.isDir(lfs.currentdir()));
    if 'win' == fs.whatOs() then
	isTrue(fs.isDir('c:/'));
	isTrue(fs.isDir('c:'));
	isTrue(fs.isDir('\\'));
    else
	isTrue(fs.isDir('/'));
	isTrue(fs.isDir('/home/'));
    end
    
    path = '/';
    areEq('directory', lfs.attributes(path, 'mode'));
    isTrue(fs.isDir(path));
end


function useUnixPathDelimiterFixture.dirnameTest()
    areEq('c:/', fs.dirname('c:/'));
    areEq('c:/path/to/dir', fs.dirname('c:/path/to/dir/file.ext'));
    areEq('c:/', fs.dirname('c:/file'));
    areEq('c:/', fs.dirname('c:/dir'));
end


function isFullPathTest()
    local OS = fs.whatOs();
    if 'win' == OS then
        isTrue(fs.isFullPath('c:/dir'));
        isTrue(fs.isFullPath('C:/dir'));
        isTrue(fs.isFullPath('\\\\host/dir'));
        isFalse(fs.isFullPath('../dir'));
        isFalse(fs.isFullPath('1:/dir'));
        isFalse(fs.isFullPath('abc:/dir'));
        isFalse(fs.isFullPath('д:/dir'));
        isTrue(fs.isFullPath('/etc/fstab'));
    elseif 'unix' == OS then
        isTrue(fs.isFullPath('/etc/fstab'));
        isTrue(fs.isFullPath('~/dir'));
        isFalse(fs.isFullPath('./configure'));
    else
        isTrue(false, "Unknown operative system");
    end
end


function isRelativePathTest()
    local OS = fs.whatOs();
    if 'win' == OS then
        isTrue(fs.isRelativePath('./dir'));
        isTrue(fs.isRelativePath('../dir'));

        isFalse(fs.isRelativePath('.../dir'));
        isFalse(fs.isRelativePath('c:/dir'));
        isFalse(fs.isRelativePath('\\\\host/dir'));
    elseif 'unix' == OS then
        isTrue(fs.isRelativePath('./configure'));
        isTrue(fs.isRelativePath('../dir'));

        isFalse(fs.isRelativePath('.../dir'));
        isFalse(fs.isRelativePath('/etc/fstab'));
        isFalse(fs.isRelativePath('~/dir'));
    else
        isTrue(false, "Unknown operative system");
    end
end


function filePathTemplatesToRePatternsTest()
    areEq('[^/\\]*$', fs.fileWildcardToRe('*'));
    areEq('[^/\\]?$', fs.fileWildcardToRe('?'));
    areEq('[^/\\]?[^/\\]?$', fs.fileWildcardToRe('??'));
    areEq('[^/\\]*%.lua$', fs.fileWildcardToRe('*.lua'));
    areEq('[^/\\]?[^/\\]*$', fs.fileWildcardToRe('?*'));
    areEq('[^/\\]*[^/\\]?$', fs.fileWildcardToRe('*?'));
    areEq('/dir/%([^/\\]?[^/\\]?[^/\\]?[^/\\]*%.[^/\\]*%)%)$', fs.fileWildcardToRe('/dir/(???*.*))'));
end


function selectFilesByTemplatesTest()
    local fileNames =
    {
        'file.cpp', 'file.h', 'file.t.cpp',
        'file.lua', 'file.t.lua', 'file.luac',
        'file.cxx', 'file.c', 'file.hpp',
        'file.txt', 'file', 'FILE',
   };

    local actual, expected;

    expected = {'file.cpp', 'file.t.cpp',};
    actual = fs.includeFiles(fileNames, '*.cpp');
    for i = 1, #expected do
        areEq(expected[i], actual[i]);
    end
    actual = fs.excludeFiles(expected, '*.t.cpp');
    expected = {'file.cpp'};
    for i = 1, #expected do
        areEq(expected[i], actual[i]);
    end

    expected = {'file.luac', 'file.lua', 'file.t.lua', };
    actual = fs.includeFiles(fileNames, '*.lua?');
    for _, path in pairs(expected) do
        isTrue(luaExt.findValue(actual, path));
    end
    actual = fs.excludeFiles(fileNames, '*c');
    expected = {'file.lua', 'file.t.lua', };
    for _, path in pairs(expected) do
        isTrue(luaExt.findValue(actual, path));
    end

    expected = {'file.c', 'file.cpp', 'file.cxx', };
    actual = fs.includeFiles(fileNames, '*.c*');
    for _, path in pairs(expected) do
        isTrue(luaExt.findValue(actual, path));
    end
end


function filePathByTemplateTest()
    isTrue(fs.includeFile('main.h', '*.h'));
    isTrue(fs.includeFile('main.cpp', '*.cpp'));
    isFalse(fs.includeFile('main.h ', '*.h'));

    isTrue(fs.includeFile('main.h', '*.?'));
    isTrue(fs.includeFile('main.c', '*.?'));
    isTrue(fs.includeFile('main.c', '*.??'));

    isTrue(fs.includeFile('main.t.cpp', '*.cpp'));
    isTrue(fs.includeFile('main.h.cpp', '*.cpp'));
    isFalse(fs.includeFile('main.h.cpp', '*.h'));

    isTrue(fs.includeFile('./main.h', '*.h'));
    isTrue(fs.includeFile('../main.h', '*.h'));
    isTrue(fs.includeFile('d:/main.cpp/main.h', '*.h'));
    isFalse(fs.includeFile('d:/main.cpp/main.h', '*.cpp'));
end




function useTestTmpDirFixture.DeleteEmptyDirectory()
    local tmpSubdir = tmpDir .. fs.osSlash() .. tostring(os.time());
    isTrue(lfs.mkdir(tmpSubdir));
    isTrue(lfs.chdir(tmpSubdir));
    isTrue(lfs.chdir(tmpDir));
    local status, msg = fs.rmdir(tmpSubdir)
    areEq(nil, msg)
    isTrue(status)
end;
    
function useTestTmpDirFixture.DeleteDirectoryWithEmptyTextFile()
    local tmpSubdir = tmpDir .. fs.osSlash() .. tostring(os.time());
    isNil(lfs.chdir(tmpSubdir))
    isTrue(lfs.mkdir(tmpSubdir))
    isTrue(lfs.chdir(tmpSubdir))
    local tmpFilePath = tmpSubdir .. fs.osSlash() .. 'tmp.file'
    local tmpFile = io.open(tmpFilePath, 'w')
    isNotNil(tmpFile)
    tmpFile:close()
    isTrue(lfs.chdir(tmpDir))
    local status, msg = fs.rmdir(tmpSubdir)
    areEq(nil, msg)
    isTrue(status)
end;

function useTestTmpDirFixture.DeleteDirectoryWithNotEmptyTextFile()
    local tmpSubdir = tmpDir .. fs.osSlash() .. tostring(os.time());
    isNil(lfs.chdir(tmpSubdir))
    isTrue(lfs.mkdir(tmpSubdir))
    isTrue(lfs.chdir(tmpSubdir))

    local tmpFilePath = tmpSubdir .. fs.osSlash() .. 'tmp.file'
    local tmpFile = io.open(tmpFilePath, 'w')
    isNotNil(tmpFile)
    tmpFile:write('some\nsimple\ntext\n')
    tmpFile:close()

    isTrue(lfs.chdir(tmpDir))
    local status, msg = fs.rmdir(tmpSubdir)
    areEq(nil, msg)
    isTrue(status)
end;

function useTestTmpDirFixture.DeleteDirectoryWithEmptySubdirectory()
    local tmpSubdir = tmpDir .. fs.osSlash() .. tostring(os.time());
    isNil(lfs.chdir(tmpSubdir))
    isTrue(lfs.mkdir(tmpSubdir))
    isTrue(lfs.chdir(tmpSubdir))

    local tmpSubSubdir = tmpSubdir .. fs.osSlash() .. 'subdir';
    isNil(lfs.chdir(tmpSubSubdir));
    isTrue(lfs.mkdir(tmpSubSubdir));
    isTrue(lfs.chdir(tmpSubSubdir));
    isTrue(fs.isExist(tmpSubSubdir));
    isTrue(lfs.chdir(tmpDir));
    
    local status, msg = fs.rmdir(tmpSubdir)
    areEq(nil, msg)
    isTrue(status)
end;

function useTestTmpDirFixture.DeleteDirectoryWithSubdirectoryWithNotEmptyTextFile()
local tmpSubdir = tmpDir .. fs.osSlash() .. tostring(os.time());
isNil(lfs.chdir(tmpSubdir))
isTrue(lfs.mkdir(tmpSubdir))
isTrue(lfs.chdir(tmpSubdir))

local tmpSubSubdir = tmpSubdir .. fs.osSlash() .. 'subdir';
isNil(lfs.chdir(tmpSubSubdir));
isTrue(lfs.mkdir(tmpSubSubdir));
isTrue(lfs.chdir(tmpSubSubdir));

local tmpFilePath = tmpSubSubdir .. fs.osSlash() .. 'tmp.file'
local tmpFile = io.open(tmpFilePath, 'w')
isNotNil(tmpFile)
tmpFile:write('some\nsimple\ntext\n')
tmpFile:close()

isTrue(lfs.chdir(tmpDir));
local status, msg = fs.rmdir(tmpSubdir)
areEq(nil, msg)
isTrue(status)
end;




function useTestTmpDirFixture.isNetworkPathTest()
    isTrue(fs.isNetworkPath([[\\172.22.3.20\folder\]]));
    isTrue(fs.isNetworkPath([[\\alias\folder\]]));

    isFalse(fs.isNetworkPath('c:/'));
    isFalse(fs.isNetworkPath('../'));
    isFalse(fs.isNetworkPath('./'));
    isFalse(fs.isNetworkPath('/'));
    isFalse(fs.isNetworkPath('\\'));

    isTrue(fs.isNetworkPath([[\\172.22.3.20\folder\file.ext]]));
    isTrue(fs.isNetworkPath([[\\alias\folder\file.ext]]));
    
    isFalse(fs.isNetworkPath('c:/file.ext'));
    isFalse(fs.isNetworkPath('../file.ext'));
    isFalse(fs.isNetworkPath('./file.ext'));
    isFalse(fs.isNetworkPath('/file.ext'));
    isFalse(fs.isNetworkPath('\\file.ext'));
end


function useTestTmpDirFixture.isLocalFullPathTest()
    if 'win' == fs.whatOs() then
        isTrue(fs.isLocalFullPath('\\'));
        isTrue(fs.isLocalFullPath('c:/'));
        isTrue(fs.isLocalFullPath('c:/file.ext'));
        isTrue(fs.isLocalFullPath('\\file.ext'));
    else
        isTrue(fs.isLocalFullPath('/'));
        isTrue(fs.isLocalFullPath('/file.ext'));
    end

    isFalse(fs.isLocalFullPath([[\\172.22.3.20\folder\]]));
    isFalse(fs.isLocalFullPath([[\\alias\folder\]]));
end


function useTestTmpDirFixture.isLocalPathTest()
    if 'win' == fs.whatOs() then
        isTrue(fs.isLocalPath('c:/'));
        isTrue(fs.isLocalPath('c:/file.ext'));
        isTrue(fs.isLocalPath('\\'));
        isTrue(fs.isLocalPath('\\file.ext'));
    end
    isTrue(fs.isLocalPath('../'));
    isTrue(fs.isLocalPath('./'));
    isTrue(fs.isLocalPath('/'));
    isTrue(fs.isLocalPath('../file.ext'));
    isTrue(fs.isLocalPath('./file.ext'));
    isTrue(fs.isLocalPath('/file.ext'));

    isFalse(fs.isLocalPath([[\\172.22.3.20\folder\]]));
    isFalse(fs.isLocalPath([[\\alias\folder\]]));
    
    isFalse(fs.isLocalPath([[\\172.22.3.20\folder\file.ext]]));
    isFalse(fs.isLocalPath([[\\alias\folder\file.ext]]));
end



function useTestTmpDirFixture.dirBypassTest()
--     local fileNames =
--     {
--         'file.cpp', 'file.h', 'file.t.cpp',
--         'file.lua', 'file.t.lua', 'file.luac',
--         'file.cxx', 'file.c', 'file.hpp',
--         'file.txt', 'file', 'FILE',
--     end
--    };
    local slash = fs.osSlash();
    -- Test defining if it is directory or not
    isTrue(fs.isDir(tmpDir));
    local tmpFilePath = tmpDir .. slash .. 'tmp.file';
    isTrue(atf.createTextFileWithContent(tmpFilePath));
    isFalse(fs.isDir(tmpFilePath))

    local dirname = tmpDir;
    local pathes = {};

    table.insert(pathes, tmpFilePath);

    dirname = dirname .. slash .. 'dir';
    isTrue(lfs.mkdir(dirname));
    isTrue(atf.createTextFileWithContent(dirname .. slash .. 'file.1'));
    table.insert(pathes, dirname .. slash .. 'file.1');

    dirname = dirname .. slash .. 'subdir';
    isTrue(lfs.mkdir(dirname));
    isTrue(atf.createTextFileWithContent(dirname .. slash .. 'file.2'));
    table.insert(pathes, dirname .. slash .. 'file.2');
--[=[
    tmp.file
    dir/file.1
    dir/subdir/file.2
--]=]
    --[[
    local files = fs.ls(tmpDir, {recursive = true, fullPath = true, onlyFiles = true});
    --]]
    local files = fs.ls(tmpDir, {recursive = true, fullPath = true, showDirs = false, showFiles = true});
    areEq(#pathes, #files);

    for _, file in ipairs(pathes) do
        isTrue(luaExt.findValue(files, file));
    end
-- test by Gorokhov
    files = fs.ls(tmpDir, {recursive = false, fullPath = true, showDirs = true, showFiles = true});
    areEq(2, #files);

    files = fs.ls(tmpDir, {recursive = true, fullPath = true, showDirs = true, showFiles = false});
    areEq(2, #files);

end


function useUnixPathDelimiterFixture.absPathOnFullFilePaths()
    if 'win' == fs.whatOs() then
        areEq('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/./dir2/file.txt'));
        areEq('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/./dir2/./file.txt'));
        areEq('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/././dir2/file.txt'));
        areEq('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/dir2/dir3/../file.txt'));
        areEq('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/dir2/./dir3/../file.txt'));
        areEq('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/dir2/dir3/.././file.txt'));
        areEq('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/dir2/dir3/./../file.txt'));
        areEq('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/dir2/dir3/./.././file.txt'));
        areEq('d:/dir1/file.txt', fs.absPath('d:/dir1/dir2/../dir3/../file.txt'));

        areEq('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\.\\dir2\\file.txt'));
        areEq('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\.\\dir2\\.\\file.txt'));
        areEq('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\.\\.\\dir2\\file.txt'));
        areEq('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\dir2\\dir3\\..\\file.txt'));
        areEq('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\dir2\\.\\dir3\\..\\file.txt'));
        areEq('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\dir2\\dir3\\..\\.\\file.txt'));
        areEq('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\dir2\\dir3\\.\\..\\file.txt'));
        areEq('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\dir2\\dir3\\.\\..\\.\\file.txt'));
        areEq('d:/dir1/file.txt', fs.absPath('d:\\dir1\\dir2\\..\\dir3\\..\\file.txt'));
    else
        areEq('/dir1/dir2/file.txt', fs.absPath('/dir1/./dir2/file.txt', '/'));
        areEq('/dir1/dir2/file.txt', fs.absPath('/dir1/./dir2/./file.txt'));
        areEq('/dir1/dir2/file.txt', fs.absPath('/dir1/././dir2/file.txt'));
        areEq('/dir1/dir2/file.txt', fs.absPath('/dir1/dir2/dir3/../file.txt'));
        areEq('/dir1/dir2/file.txt', fs.absPath('/dir1/dir2/./dir3/../file.txt'));
        areEq('/dir1/dir2/file.txt', fs.absPath('/dir1/dir2/dir3/.././file.txt'));
        areEq('/dir1/dir2/file.txt', fs.absPath('/dir1/dir2/dir3/./../file.txt'));
        areEq('/dir1/dir2/file.txt', fs.absPath('/dir1/dir2/dir3/./.././file.txt'));
        areEq('/dir1/file.txt', fs.absPath('/dir1/dir2/../dir3/../file.txt'));
    end
end


function useUnixPathDelimiterFixture.absPathOnRelativePaths()
    areEq('c:/dir1', fs.absPath('./dir1/', 'c:/'));
    areEq(fs.canonizePath(lfs.currentdir()) .. fs.osSlash() .. 'dir1', fs.absPath('./dir1/'));
    areEq('/dir/dir1', fs.absPath('/dir/./dir1/'))
end

function useTestTmpDirFixture.copyDirWithFileTest()
    local total = 0
    local path

    for n = 0, 10 do
        path = tmpDir .. fs.osSlash() .. n .. '.txt'
        atf.createTextFileWithContent(path, string.rep(' ', n));
        areEq(n, fs.du(path))
        total = total + n
    end
    areEq(total, fs.du(tmpDir))
end


function useTestTmpDirFixture.copyFileToAnotherPlaceTest()
    local text = 'some\nsimple\ntext\n';
    local src = tmpDir .. fs.osSlash() .. 'src.txt';
    local dst = tmpDir .. fs.osSlash() .. 'dst.txt';

    atf.createTextFileWithContent(src, text);
    areNotEq(src, dst);

    isTrue(fs.copyFile(src, dst));

    isTrue(fs.isExist(src));
    isTrue(fs.isExist(dst));

    isTrue(fs.isFile(src));
    isTrue(fs.isFile(dst));
    
    areEq(text, atf.fileContentAsString(dst))
end

function useTestTmpDirFixture.copyFileIntoItselfTest()
    local text = 'some\nsimple\ntext\n';
    local src = tmpDir .. fs.osSlash() .. 'src.txt';
    local dst = src;

    atf.createTextFileWithContent(src, text)

    isNil(fs.copyFile(src, dst))
end

function useTestTmpDirFixture.copyDirWithCopyFileFuncTest()
    local srcDir = tmpDir .. fs.osSlash() .. '1';
    local srcFile = srcDir .. fs.osSlash() .. 'tmp.txt';
    local dstDir = tmpDir .. fs.osSlash() .. '2';
    local dstFile = dstDir .. fs.osSlash() .. 'tmp.txt';

    lfs.mkdir(srcDir);
    lfs.mkdir(dstDir);
    local text = 'some\nsimple\ntext\n';
    atf.createTextFileWithContent(srcFile, text);
    
    isNil(fs.copyFile(srcDir, dstDir))
    isNil(fs.copyFile(srcFile, dstDir))
end

function useTestTmpDirFixture.copyDirWithFileTest()
    local src = tmpDir .. fs.osSlash() .. '1'
    local dst = tmpDir .. fs.osSlash() .. '2'
    lfs.mkdir(src);
    lfs.mkdir(dst);

    local text = 'some\nsimple\ntext\n';
    atf.createTextFileWithContent(src .. fs.osSlash() .. 'tmp.txt', text);

    local status, errMsg = fs.copyDir(src, dst)
    areEq(nil, errMsg)
    isTrue(status);

    local dstSubDir = dst .. fs.osSlash() .. '1'

    isTrue(fs.isExist(dstSubDir));
    isTrue(fs.isDir(dstSubDir));

    isTrue(fs.isExist(dstSubDir .. fs.osSlash() .. 'tmp.txt'));
    isTrue(fs.isFile(dstSubDir .. fs.osSlash() .. 'tmp.txt'));
end

function useTestTmpDirFixture.copyDirWithSubdirWithFileTest()
    local src = tmpDir .. fs.osSlash() .. '1'
    local srcFile = src .. fs.osSlash() .. 'src.txt'
    local srcSubdir = src .. fs.osSlash() .. 'subdir'
    local srcFileInSubdir = srcSubdir .. fs.osSlash() .. 'tmp.txt'
    
    local dst = tmpDir .. fs.osSlash() .. '2'
    local srcDirInDstDir = dst .. fs.osSlash() .. '1'
    local dstFile = srcDirInDstDir .. fs.osSlash() .. 'src.txt'
    local dstSubdir = srcDirInDstDir .. fs.osSlash() .. 'subdir'
    local srcFileInDstSubdir = dstSubdir .. fs.osSlash() .. 'tmp.txt'
    
    lfs.mkdir(src);
    lfs.mkdir(srcSubdir);
    lfs.mkdir(dst);

    local text = 'some\nsimple\ntext\n';
    atf.createTextFileWithContent(srcFile, text);
    atf.createTextFileWithContent(srcFileInSubdir, text);

    local status, errMsg = fs.copyDir(src, dst)
    areEq(nil, errMsg)
    isTrue(status);

    isTrue(fs.isExist(srcDirInDstDir));
    isTrue(fs.isDir(srcDirInDstDir));

    isTrue(fs.isExist(dstSubdir));
    isTrue(fs.isDir(dstSubdir));

    isTrue(fs.isExist(dstFile));
    isTrue(fs.isFile(dstFile));

    isTrue(fs.isExist(srcFileInDstSubdir));
    isTrue(fs.isFile(srcFileInDstSubdir));
end

function useTestTmpDirFixture.copyFilesWithCopyDirFuncTest()
    local srcDir = tmpDir .. fs.osSlash() .. '1';
    local srcFile = srcDir .. fs.osSlash() .. 'tmp.txt';
    local dstDir = tmpDir .. fs.osSlash() .. '2';
    local dstFile = dstDir .. fs.osSlash() .. 'tmp.txt';

    lfs.mkdir(srcDir);
    lfs.mkdir(dstDir);
    local text = 'some\nsimple\ntext\n';
    atf.createTextFileWithContent(srcFile, text);
    
    isNil(fs.copyDir(srcFile, dstDir))
    isNil(fs.copyDir(srcDir, dstFile))
end

function useTestTmpDirFixture.copyTest()
end



function useTestTmpDirFixture.relativePathTest()
    areEq('subdir/', fs.relativePath('c:/path/to/dir/subdir/', 'c:/path/to/dir/'));
    areEq('subdir\\', fs.relativePath('c:\\path\\to\\dir\\subdir\\', 'c:\\path\\to\\dir\\'));
end


function useTestTmpDirFixture.applyOnFilesTest()
    local slash = fs.osSlash();
    local dirname = tmpDir;
    local pathes = {};
--[=[
    tmp.file
    dir/file.1
    dir/subdir/file.2
--]=]
    local tmpFilePath = dirname .. slash .. 'tmp.file';
    isTrue(atf.createTextFileWithContent(tmpFilePath));
    isTrue(fs.isFile(tmpFilePath))
    table.insert(pathes, tmpFilePath);
    
    dirname = dirname  .. slash .. 'dir';

    local file1path = dirname .. slash .. 'file.1'
    isTrue(lfs.mkdir(dirname));
    isTrue(atf.createTextFileWithContent(file1path));
    table.insert(pathes, file1path);

    dirname = dirname .. slash .. 'subdir';

    local file2path = dirname .. slash .. 'file.2'
    isTrue(lfs.mkdir(dirname));
    isTrue(atf.createTextFileWithContent(file2path));
    table.insert(pathes, file2path);
    
    do    
        local files = {};
        local function savePath(path, state)
            if not fs.isDir(path) then
                table.insert(state, path);
            end
        end
        
        fs.applyOnFiles(tmpDir, {handler = savePath, state = files, recursive = true});
        
        areEq(#pathes, #files);
        isTrue(luaExt.findValue(pathes, tmpFilePath));
        isTrue(luaExt.findValue(pathes, file1path));
        isTrue(luaExt.findValue(pathes, file2path));
    end
    do
        local function fileFilter(path)
            return not fs.isDir(path);
        end
        
        local function savePath(path, state)
            table.insert(state, path);
        end

        local files = {};
        
        fs.applyOnFiles(tmpDir, {handler = savePath, filter = fileFilter, state = files, recursive = true});

        areEq(#pathes, #files);
        isTrue(luaExt.findValue(pathes, tmpFilePath));
        isTrue(luaExt.findValue(pathes, file1path));
        isTrue(luaExt.findValue(pathes, file2path));
    end
end

function useTestTmpDirFixture.bytesToTest()
    areEq(1, fs.bytesTo(1024, 'k'));
    areEq(1, fs.bytesTo(1024, 'K'));
    areEq(1, fs.bytesTo(1024 * 1024, 'M'));
    areEq(1024 * 1024, fs.bytesTo(1024 * 1024, 'm'));
end

function useTestTmpDirFixture.fileLastModTimeTest()
    local filetime = os.date('*t', lfs.attributes('win' == fs.whatOs() and 'c:/windows/system32/cmd.exe' or '/bin/sh', 'change'))
    local curTime = os.time()
    isTrue(os.time(filetime) < os.time())
    isTrue(os.difftime(curTime, os.time(filetime)) > 0)
end

function useTestTmpDirFixture.defineFileSizeTest()
    local size = lfs.attributes('win' == fs.whatOs() and 'c:/windows/system32/cmd.exe' or '/bin/sh', 'size')
    local size2 = lfs.attributes('filesystem.t.notlua', 'size')
    isTrue(size > 0);
    isNil(size2)
end

function useTestTmpDirFixture.localPathToFormatOfNetworkPathTest()
end
