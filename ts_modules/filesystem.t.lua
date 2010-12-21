 -- -*- coding: utf-8 -*-
--------------------------------------------------------------------------------------------------------------
-- Documentation
--------------------------------------------------------------------------------------------------------------

--- \fn whatOs()
--- \brief Define operative system, on which script is runned
--- \return 'win' or 'unix'

--- \fn canonicalSlash()
--- \return slash (as at Unix systems)

--- \fn osSlash()
--- \brief Define what slash is using in pathes on operative system, on which script is runned
--- \return slash or backslash

--- \fn currentdir()
--- \return Returns a string with the current working directory or nil  plus an error string

--- \fn dir(path)
--- \details Lua iterator over the entries of a given directory. Each time the iterator is called it returns a directory entry's name as a string, or nil if there are no more entries. Raises an error if path is not a directory.

--- \fn chdir(path)
--- \brief Changes the current working directory to the given path.
--- \return Returns true in case of success or nil plus an error string.

--- \fn canonizePath(path, slash)
--- \return Return path, where backslashes are replaced with 'slash'

--- \fn tmpDirName()
--- \return Return new name of temporary directory every call (theoretically)

--- \fn filename(path)
--- \param path Full or relative path of file
--- \return two value: name and extension of file or '' value for every undefined part

--- \fn dirname(path, slash)
--- \param[in] path Full or relative path of file
--- \param[in] slash Slash, which you want to see into directory path
--- \return Path to dir

--- \fn rmdir(dirPath)
--- \brief Removes an existing directory
--- \param[in] dirPath Name of the directory.
--- \return Returns true if the operation was successful; in case of error, it returns nil plus an error string.
--- \details !!! remove directory with all content without any question

--- \fn mkdir(dirPath)
--- \details Creates a new directory. The argument is the name of the new directory.
--- \return Returns true if the operation was successful; in case of error, it returns nil plus an error string.

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

--- \fn fileTemplToRe(templ)
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

--- \fn createTextFileWithContent(path, content)
--- \brief создает файл с указанным текстовым содержимым
--- \param[in] path путь к создаваемому файлу (ВНИМАНИЕ! Существующий файл с тем же именем будет перезаписан)
--- \param[in] содержимое, к-ое необходимо записать в созданный файл
--- \return true, если все прошло без ошибок, иначе - false

---\fn ls(dirname, adtArg)
---\brief выводит список файлов и/или подкаталогов данного каталога
--- \param[in] dirname каталог, содержимое которого необходимо вывести
--- \param[in] adtArg таблица, задающая параметры вывода:
--- \details adtArg.showDirs если true, то будут выведены названия каталогов \n
--- adtArg.showFiles если true, то будут выведены названия файлов \n
--- adtArg.fullPath если true, то будут выведены полные пути к файлам и подкаталогам \n
--- adtArg.recursive если true, то будут просмотрены все подкаталоги \n
--- \return list of files and/or dirs

---\fn copyFile(srcFilePath, dstFilePath, binary)
---\brief Copy one file
--- \param[in] srcFilePath Full or relative path to file, which will be copied
--- \param[in] dstFilePath Full or relative path to file, which will be appeared
--- \param[in] binary If true, then srcFilePath will be opened as binary file, otherwise as text file
--- \return successStatus and error message in failure case

--- \fn isNetworkPath(path)
--- \param[in] path Full network path 
--- \return true if 'path' is path of file or folder inside network share folder, otherwise return false

--- \fn isLocalPath(path)
--- \param[in] path Full or relative local file or folder path
--- \return true if 'path' is path of file or folder on local disk location


local lunit = require("lunit")

--------------------------------------------------------------------------------------------------------------
module("filesystem_test_common", lunit.testcase, package.seeall)
--------------------------------------------------------------------------------------------------------------

local fs = require("filesystem")
local luaExt = require('lua_ext')

function whatOsTest()
    assert_equal('win', fs.whatOs())
end

--------------------------------------------------------------------------------------------------------------
function canonizePathTest()
    local slash = '/';
    assert_equal('c:/path/to/dir/', fs.canonizePath('c:/path/to/dir/', slash))
    assert_equal('c:/path/to/dir/', fs.canonizePath('c:\\path\\to\\dir\\', slash))
    assert_equal('c:/path/to/dir/subdir', fs.canonizePath('c:\\path/to//dir\\\\subdir', slash))
    assert_equal('\\\\host1/path/to/dir/subdir', fs.canonizePath('\\\\host1\\path/to//dir\\\\subdir'))
    assert_equal('//host2/path/to/dir/subdir', fs.canonizePath('//host2\\path/to//dir\\\\subdir'))
end

--------------------------------------------------------------------------------------------------------------
function filenameTest()
    local name, ext, dir;
    name, ext = fs.filename('c:/readme.txt');
    assert_not_nil(name);
    assert_not_nil(ext);
    assert_equal('txt', ext);
    assert_equal('readme', name);

    name, ext = fs.filename('/tmp/readme.txt');
    assert_not_nil(name);
    assert_not_nil(ext);
    assert_equal('txt', ext);
    assert_equal('readme', name);

    name, ext = fs.filename('./readme.txt');
    assert_not_nil(name);
    assert_not_nil(ext);
    assert_equal('txt', ext);
    assert_equal('readme', name);

    name, ext = fs.filename('c:/readme.txt.bak');
    assert_not_nil(name);
    assert_not_nil(ext);
    assert_equal('bak', ext);
    assert_equal('readme.txt', name);

    name, ext = fs.filename('c:/README');
    assert_not_nil(name);
    assert_not_nil(ext);
    assert_equal(ext, '');
    assert_equal(name, 'README');

    name, ext = fs.filename('c:/');
    assert_not_nil(name);
    assert_not_nil(ext);
    assert_equal(ext, '');
    assert_equal(name, '');

    name, ext = fs.filename('c:/readme.txt ');
    assert_not_nil(name);
    assert_not_nil(ext);
    assert_equal('txt', ext);
    assert_equal('readme', name);

    name, ext = fs.filename('c:/readme_again.tx_t');
    assert_not_nil(name);
    assert_not_nil(ext);
    assert_equal('tx_t', ext);
    assert_equal('readme_again', name);

    name, ext = fs.filename('c:\\path\\to\\dir\\readme_again.tx_t');
    assert_not_nil(name);
    assert_not_nil(ext);
    assert_equal('tx_t', ext);
    assert_equal('readme_again', name);

    name, ext = fs.filename('d:/svn_wv_rpo_trunk/.svn/dir-prop-base');
    assert_not_nil(name);
    assert_not_nil(ext);
    assert_equal('', ext);
    assert_equal('dir-prop-base', name);

    name, ext = fs.filename('d:/svn_wv_rpo_trunk/.svn/dir-prop-base');
    assert_not_nil(name);
    assert_not_nil(ext);
    assert_equal('', ext);
    assert_equal('dir-prop-base', name);

    name, ext, dir = fs.filename('d:/svn_wv_rpo_trunk/dir-prop-base/.svn/dir-prop-base');
    assert_not_nil(name);
    assert_not_nil(ext);
    assert_equal('', ext);
    assert_equal('dir-prop-base', name);
    assert_equal('d:/svn_wv_rpo_trunk/dir-prop-base/.svn/', dir);

    name, ext = fs.filename('d:/svn_wv_rpo_trunk/.svn');
    assert_not_nil(name);
    assert_not_nil(ext);
    assert_equal('svn', ext);
    assert_equal('', name);

    name, ext, dir = fs.filename('d:/svn_wv_rpo_trunk/.svn/.svn');
    assert_not_nil(name);
    assert_not_nil(ext);
    assert_equal('svn', ext);
    assert_equal('', name);
    assert_equal('d:/svn_wv_rpo_trunk/.svn/', dir);

    name, ext, dir = fs.filename('gepart_ac.ini');
    assert_not_nil(name);
    assert_not_nil(ext);
    assert_equal('gepart_ac', name);
    assert_equal('ini', ext);
    assert_equal('', dir);

    name, ext, dir = fs.filename('test spaces.ini');
    assert_not_nil(name);
    assert_not_nil(ext);
    assert_equal('test spaces', name);
    assert_equal('ini', ext);
    assert_equal('', dir);

end

--------------------------------------------------------------------------------------------------------------
function isExistTest()
    assert_true(fs.isExist(fs.currentdir()), fs.currentdir() .. ' is not exist');
    assert_true(fs.isExist('c:/'));
    assert_true(fs.isExist('c:'));
end

function isDirTest()
    assert_true(fs.isDir(fs.currentdir()), fs.currentdir() .. ' is not exist');
    assert_true(fs.isDir('c:/'));
    assert_true(fs.isDir('c:'));
end

--------------------------------------------------------------------------------------------------------------
function dirnameTest()
    assert_equal('c:/', fs.dirname('c:/'));
    assert_equal('c:/path/to/dir/', fs.dirname('c:/path/to/dir/file.ext'));
    assert_equal('c:/', fs.dirname('c:/file'));
    assert_equal('c:/dir/', fs.dirname('c:/dir/'));
end

--------------------------------------------------------------------------------------------------------------
function isFullPathTest()
    local OS = fs.whatOs();
    if 'win' == OS then
        assert_true(fs.isFullPath('c:/dir'));
        assert_true(fs.isFullPath('C:/dir'));
        assert_true(fs.isFullPath('\\\\host/dir'));
        assert_false(fs.isFullPath('../dir'));
        assert_false(fs.isFullPath('1:/dir'));
        assert_false(fs.isFullPath('abc:/dir'));
        assert_false(fs.isFullPath('д:/dir'));
        assert_true(fs.isFullPath('/etc/fstab'));
    elseif 'unix' == OS then
        assert_true(fs.isFullPath('/etc/fstab'));
        assert_true(fs.isFullPath('~/dir'));
        assert_false(fs.isFullPath('./configure'));
    else
        assert_true(false, "Unknown operative system");
    end
end

--------------------------------------------------------------------------------------------------------------
function isRelativePathTest()
    local OS = fs.whatOs();
    if 'win' == OS then
        assert_true(fs.isRelativePath('./dir'));
        assert_true(fs.isRelativePath('../dir'));

        assert_false(fs.isRelativePath('.../dir'));
        assert_false(fs.isRelativePath('c:/dir'));
        assert_false(fs.isRelativePath('\\\\host/dir'));
    elseif 'unix' == OS then
        assert_true(fs.isRelativePath('./configure'));
        assert_true(fs.isRelativePath('../dir'));

        assert_false(fs.isRelativePath('.../dir'));
        assert_false(fs.isRelativePath('/etc/fstab'));
        assert_false(fs.isRelativePath('~/dir'));
    else
        assert_true(false, "Unknown operative system");
    end
end

--------------------------------------------------------------------------------------------------------------
function filePathTemplatesToRePatternsTest()
    assert_equal('[^/\\]*$', fs.fileTemplToRe('*'));
    assert_equal('[^/\\]?$', fs.fileTemplToRe('?'));
    assert_equal('[^/\\]?[^/\\]?$', fs.fileTemplToRe('??'));
    assert_equal('[^/\\]*%.lua$', fs.fileTemplToRe('*.lua'));
    assert_equal('[^/\\]?[^/\\]*$', fs.fileTemplToRe('?*'));
    assert_equal('[^/\\]*[^/\\]?$', fs.fileTemplToRe('*?'));
    assert_equal('/dir/%([^/\\]?[^/\\]?[^/\\]?[^/\\]*%.[^/\\]*%)%)$', fs.fileTemplToRe('/dir/(???*.*))'));
end

--------------------------------------------------------------------------------------------------------------
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
        assert_equal(expected[i], actual[i]);
    end
    actual = fs.excludeFiles(expected, '*.t.cpp');
    expected = {'file.cpp'};
    for i = 1, #expected do
        assert_equal(expected[i], actual[i]);
    end

    expected = {'file.luac', 'file.lua', 'file.t.lua', };
    actual = fs.includeFiles(fileNames, '*.lua?');
    for _, path in pairs(expected) do
        assert_true(luaExt.findValue(actual, path));
    end
    actual = fs.excludeFiles(fileNames, '*c');
    expected = {'file.lua', 'file.t.lua', };
    for _, path in pairs(expected) do
        assert_true(luaExt.findValue(actual, path));
    end

    expected = {'file.c', 'file.cpp', 'file.cxx', };
    actual = fs.includeFiles(fileNames, '*.c*');
    for _, path in pairs(expected) do
        assert_true(luaExt.findValue(actual, path));
    end
end

--------------------------------------------------------------------------------------------------------------
function filePathByTemplateTest()
    assert_true(fs.includeFile('main.h', '*.h'));
    assert_true(fs.includeFile('main.cpp', '*.cpp'));
    assert_false(fs.includeFile('main.h ', '*.h'));

    assert_true(fs.includeFile('main.h', '*.?'));
    assert_true(fs.includeFile('main.c', '*.?'));
    assert_true(fs.includeFile('main.c', '*.??'));

    assert_true(fs.includeFile('main.t.cpp', '*.cpp'));
    assert_true(fs.includeFile('main.h.cpp', '*.cpp'));
    assert_false(fs.includeFile('main.h.cpp', '*.h'));

    assert_true(fs.includeFile('./main.h', '*.h'));
    assert_true(fs.includeFile('../main.h', '*.h'));
    assert_true(fs.includeFile('d:/main.cpp/main.h', '*.h'));
    assert_false(fs.includeFile('d:/main.cpp/main.h', '*.cpp'));
end

--------------------------------------------------------------------------------------------------------------
module("filesystem_test_files", lunit.testcase, package.seeall)
--------------------------------------------------------------------------------------------------------------

local tmpDir;

function setup()
    tmpDir = fs.tmpDirName();
    assert_not_nil(tmpDir);
    local curDir = fs.currentdir();
    assert_not_nil(curDir);
    assert_nil(fs.chdir(tmpDir));
    assert_true(fs.mkdir(tmpDir));
    assert_true(fs.chdir(tmpDir));
    assert_true(fs.chdir(curDir));
end

function teardown()
    assert_not_nil(tmpDir);
    assert_true(fs.chdir(tmpDir .. '..'))
    assert_true(fs.rmdir(tmpDir));
end

--------------------------------------------------------------------------------------------------------------
function mkAndRmDirTest()
    assert_true(fs.chdir(tmpDir));
    -- delete empty directory
    do
        local tmpSubdir = tmpDir .. os.tmpname();
        assert_true(fs.mkdir(tmpSubdir));
        assert_true(fs.chdir(tmpSubdir));
        assert_true(fs.chdir(tmpDir));
        assert_true(fs.rmdir(tmpSubdir));
    end
    -- delete directory with empty text file
    do
        local tmpSubdir = tmpDir .. os.tmpname() .. fs.slash();
        assert_nil(fs.chdir(tmpSubdir))
        assert_true(fs.mkdir(tmpSubdir))
        assert_true(fs.chdir(tmpSubdir))
        local tmpFilePath = tmpSubdir .. 'tmp.file'
        local tmpFile = io.open(tmpFilePath, 'w')
        assert_not_nil(tmpFile)
        tmpFile:close()
        assert_true(fs.chdir(tmpDir))
        assert_true(fs.rmdir(tmpSubdir))
    end
    -- delete directory with NOT empty text file
    do
        local tmpSubdir = tmpDir .. os.tmpname() .. fs.slash();
        assert_nil(fs.chdir(tmpSubdir))
        assert_true(fs.mkdir(tmpSubdir))
        assert_true(fs.chdir(tmpSubdir))

        local tmpFilePath = tmpSubdir .. 'tmp.file'
        local tmpFile = io.open(tmpFilePath, 'w')
        assert_not_nil(tmpFile)
        tmpFile:write('some\nsimple\ntext\n')
        tmpFile:close()

        assert_true(fs.chdir(tmpDir))
        assert_true(fs.rmdir(tmpSubdir))
    end
    -- delete directory with empty subdirectory
    do
        local tmpSubdir = tmpDir .. os.tmpname() .. fs.slash();
        assert_nil(fs.chdir(tmpSubdir))
        assert_true(fs.mkdir(tmpSubdir))
        assert_true(fs.chdir(tmpSubdir))

        local tmpSubSubdir = tmpSubdir .. 'subdir' .. fs.slash();
        assert_nil(fs.chdir(tmpSubSubdir));
        assert_true(fs.mkdir(tmpSubSubdir));
        assert_true(fs.chdir(tmpSubSubdir));
        assert_true(fs.chdir(tmpDir));

        assert_true(fs.rmdir(tmpSubdir));
    end
    -- delete directory with subdirectory with NOT empty text file
    do
        local tmpSubdir = tmpDir .. os.tmpname() .. fs.slash();
        assert_nil(fs.chdir(tmpSubdir))
        assert_true(fs.mkdir(tmpSubdir))
        assert_true(fs.chdir(tmpSubdir))

        local tmpSubSubdir = tmpSubdir .. 'subdir' .. fs.slash();
        assert_nil(fs.chdir(tmpSubSubdir));
        assert_true(fs.mkdir(tmpSubSubdir));
        assert_true(fs.chdir(tmpSubSubdir));

        local tmpFilePath = tmpSubSubdir .. 'tmp.file'
        local tmpFile = io.open(tmpFilePath, 'w')
        assert_not_nil(tmpFile)
        tmpFile:write('some\nsimple\ntext\n')
        tmpFile:close()

        assert_true(fs.chdir(tmpDir));
        assert_true(fs.rmdir(tmpSubdir));
    end
end

--------------------------------------------------------------------------------------------------------------
function createTextFileWithContentTest()
    local tmpFilePath = tmpDir .. 'tmp.file';
    local text = 'some\nsimple\ntext\n';
    assert_true(fs.createTextFileWithContent(tmpFilePath, text));

    local tmpFile = io.open(tmpFilePath, 'r');
    assert_not_nil(tmpFile);
    assert_equal(text, tmpFile:read("*a"));
    tmpFile:close();
end

--------------------------------------------------------------------------------------------------------------
function isNetworkPathTest()
    assert_true(fs.isNetworkPath([[\\172.22.3.20\folder\]]));
    assert_true(fs.isNetworkPath([[\\alias\folder\]]));

    assert_false(fs.isNetworkPath('c:/'));
    assert_false(fs.isNetworkPath('../'));
    assert_false(fs.isNetworkPath('./'));
    assert_false(fs.isNetworkPath('/'));
    assert_false(fs.isNetworkPath('\\'));

    assert_true(fs.isNetworkPath([[\\172.22.3.20\folder\file.ext]]));
    assert_true(fs.isNetworkPath([[\\alias\folder\file.ext]]));
    
    assert_false(fs.isNetworkPath('c:/file.ext'));
    assert_false(fs.isNetworkPath('../file.ext'));
    assert_false(fs.isNetworkPath('./file.ext'));
    assert_false(fs.isNetworkPath('/file.ext'));
    assert_false(fs.isNetworkPath('\\file.ext'));
end

--------------------------------------------------------------------------------------------------------------
function isLocalFullPathTest()
    assert_true(fs.isLocalFullPath('c:/'));
    assert_true(fs.isLocalFullPath('/'));
    assert_true(fs.isLocalFullPath('\\'));

    assert_true(fs.isLocalFullPath('c:/file.ext'));
    assert_true(fs.isLocalFullPath('/file.ext'));
    assert_true(fs.isLocalFullPath('\\file.ext'));

    assert_false(fs.isLocalFullPath([[\\172.22.3.20\folder\]]));
    assert_false(fs.isLocalFullPath([[\\alias\folder\]]));
end

--------------------------------------------------------------------------------------------------------------
function isLocalPathTest()
    assert_true(fs.isLocalPath('c:/'));
    assert_true(fs.isLocalPath('../'));
    assert_true(fs.isLocalPath('./'));
    assert_true(fs.isLocalPath('/'));
    assert_true(fs.isLocalPath('\\'));

    assert_true(fs.isLocalPath('c:/file.ext'));
    assert_true(fs.isLocalPath('../file.ext'));
    assert_true(fs.isLocalPath('./file.ext'));
    assert_true(fs.isLocalPath('/file.ext'));
    assert_true(fs.isLocalPath('\\file.ext'));
    
    assert_false(fs.isLocalPath([[\\172.22.3.20\folder\]]));
    assert_false(fs.isLocalPath([[\\alias\folder\]]));
    
    assert_false(fs.isLocalPath([[\\172.22.3.20\folder\file.ext]]));
    assert_false(fs.isLocalPath([[\\alias\folder\file.ext]]));
end


--------------------------------------------------------------------------------------------------------------
function dirBypassTest()
--     local fileNames =
--     {
--         'file.cpp', 'file.h', 'file.t.cpp',
--         'file.lua', 'file.t.lua', 'file.luac',
--         'file.cxx', 'file.c', 'file.hpp',
--         'file.txt', 'file', 'FILE',
--     };
    local slash = fs.slash();
    -- Test defining if it is directory or not
    assert_true(fs.isDir(tmpDir));
    local tmpFilePath = tmpDir .. 'tmp.file';
    assert_true(fs.createTextFileWithContent(tmpFilePath));
    assert_false(fs.isDir(tmpFilePath))

    local dirname = tmpDir;
    local pathes = {};

    table.insert(pathes, tmpFilePath);

    dirname = dirname..'dir'..slash;
    assert_true(fs.mkdir(dirname));
    assert_true(fs.createTextFileWithContent(dirname .. 'file.1'));
    table.insert(pathes, dirname .. 'file.1');

    dirname = dirname..'subdir'..slash;
    assert_true(fs.mkdir(dirname));
    assert_true(fs.createTextFileWithContent(dirname .. 'file.2'));
    table.insert(pathes, dirname .. 'file.2');
--[=[
    tmp.file
    dir/file.1
    dir/subdir/file.2
--]=]
    --[[
    local files = fs.ls(tmpDir, {recursive = true, fullPath = true, onlyFiles = true});
    --]]
    local files = fs.ls(tmpDir, {recursive = true, fullPath = true, showDirs = false, showFiles = true});
    assert_equal(#pathes, #files);

    for _, file in ipairs(pathes) do
        assert_true(luaExt.findValue(files, file));
    end
-- test by Gorokhov
    files = fs.ls(tmpDir, {recursive = false, fullPath = true, showDirs = true, showFiles = true});
    assert_equal(2, #files);

    files = fs.ls(tmpDir, {recursive = true, fullPath = true, showDirs = true, showFiles = false});
    assert_equal(2, #files);

end

--------------------------------------------------------------------------------------------------------------
function absPathOnFullFilePathsTest()
    assert_equal('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/./dir2/file.txt'));
    assert_equal('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/./dir2/./file.txt'));
    assert_equal('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/././dir2/file.txt'));
    assert_equal('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/dir2/dir3/../file.txt'));
    assert_equal('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/dir2/./dir3/../file.txt'));
    assert_equal('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/dir2/dir3/.././file.txt'));
    assert_equal('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/dir2/dir3/./../file.txt'));
    assert_equal('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/dir2/dir3/./.././file.txt'));
    assert_equal('d:/dir1/file.txt', fs.absPath('d:/dir1/dir2/../dir3/../file.txt'));

    assert_equal('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\.\\dir2\\file.txt'));
    assert_equal('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\.\\dir2\\.\\file.txt'));
    assert_equal('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\.\\.\\dir2\\file.txt'));
    assert_equal('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\dir2\\dir3\\..\\file.txt'));
    assert_equal('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\dir2\\.\\dir3\\..\\file.txt'));
    assert_equal('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\dir2\\dir3\\..\\.\\file.txt'));
    assert_equal('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\dir2\\dir3\\.\\..\\file.txt'));
    assert_equal('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\dir2\\dir3\\.\\..\\.\\file.txt'));
    assert_equal('d:/dir1/file.txt', fs.absPath('d:\\dir1\\dir2\\..\\dir3\\..\\file.txt'));
end

--------------------------------------------------------------------------------------------------------------
function absPathOnRelativePathsTest()
    assert_equal(fs.currentdir() .. 'dir1/', fs.absPath('./dir1/'));
end

local function trace()
    -- empty for disable output
end

--------------------------------------------------------------------------------------------------------------
function copyTest()
    local text = 'some\nsimple\ntext\n';
    local srcFilePath = tmpDir .. 'tmp.txt.1';
    local dstFilePath = tmpDir .. 'tmp.txt.2';
    fs.createTextFileWithContent(srcFilePath, text);
    assert_not_equal(srcFilePath, dstFilePath);
    -- copy text file
    assert_true(fs.copy(srcFilePath, dstFilePath));

    assert_true(fs.isExist(srcFilePath));
    assert_true(fs.isExist(dstFilePath));

    assert_true(fs.isFile(srcFilePath));
    assert_true(fs.isFile(dstFilePath));
end

--------------------------------------------------------------------------------------------------------------
--~ function copyDirTest()
--~     fs.mkdir(tmpDir .. '1/');
--~     fs.mkdir(tmpDir .. '2/');

--~     local text = 'some\nsimple\ntext\n';
--~     fs.createTextFileWithContent(tmpDir .. '1/' .. 'tmp.txt', text);

--~     assert_true(fs.copyDir(tmpDir .. '1/', tmpDir .. '2/'));

--~     assert_true(fs.isExist(tmpDir .. '1/2/'));
--~     assert_true(fs.isDir(tmpDir .. '1/2/'));

--~     assert_true(fs.isExist(tmpDir .. '1/2/' .. 'tmp.txt'));
--~     assert_true(fs.isFile(tmpDir .. '1/2/' .. 'tmp.txt'));
--~ end

--------------------------------------------------------------------------------------------------------------
function relativePathTest()
    assert_equal('subdir/', fs.relativePath('c:/path/to/dir/subdir/', 'c:/path/to/dir/'));
    assert_equal('subdir\\', fs.relativePath('c:\\path\\to\\dir\\subdir\\', 'c:\\path\\to\\dir\\'));
end

--------------------------------------------------------------------------------------------------------------
function applyOnFilesTest()
    local slash = fs.slash();
    -- Test defining if it is directory or not
    assert_true(fs.isDir(tmpDir));
    local tmpFilePath = tmpDir .. 'tmp.file';
    assert_true(fs.createTextFileWithContent(tmpFilePath));
    assert_false(fs.isDir(tmpFilePath))

    local dirname = tmpDir;
    local pathes = {};

    dirname = dirname..'dir'..slash;
    assert_true(fs.mkdir(dirname));
    assert_true(fs.createTextFileWithContent(dirname .. 'file.1'));
    table.insert(pathes, dirname .. 'file.1');

    dirname = dirname..'subdir'..slash;
    assert_true(fs.mkdir(dirname));
    assert_true(fs.createTextFileWithContent(dirname .. 'file.2'));
    table.insert(pathes, dirname .. 'file.2');
    
    table.insert(pathes, tmpFilePath);

--[=[
    tmp.file
    dir/file.1
    dir/subdir/file.2
--]=]

    do    
        local files = {};
        local function savePath(path, state)
            if not fs.isDir(path) then
                table.insert(state, path);
            end
        end
        
        fs.applyOnFiles(tmpDir, {handler = savePath, state = files, recursive = true});
        
        assert_equal(#pathes, #files);
        assert_true(table.isEqual(pathes, files));
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
        assert_equal(#pathes, #files);
        assert_true(table.isEqual(pathes, files));
    end
end

function bytesToTest()
    assert_equal(1, fs.bytesTo(1024, 'k'));
    assert_equal(1, fs.bytesTo(1024, 'K'));
    assert_equal(1, fs.bytesTo(1024 * 1024, 'M'));
    assert_equal(1024 * 1024, fs.bytesTo(1024 * 1024, 'm'));
end

function fileLastModTimeTest()
    local filetime = fs.fileLastModTime('c:/windows/system32/cmd.exe');
    local curTime = os.time();
    assert_true(os.time(filetime) < os.time());
    assert_true(os.difftime(curTime, os.time(filetime)) > 0);
end

function rmfileTest()
    local tmpFilePath = tmpDir .. 'file.tmp';
    assert_true(fs.createTextFileWithContent(tmpFilePath));
    assert_true(fs.isFile(tmpFilePath));
    assert_true(fs.rmfile(tmpFilePath));
    assert_false(fs.isExist(tmpFilePath));
end

--------------------------------------------------------------------------------------------------------------
function localPathToFormatOfNetworkPathTest()
end

--------------------------------------------------------------------------------------------------------------
function fileContentAsStringTest()
    local path = tmpDir .. 'file.txt';
    local content = '1st line\r\n2nd line\n  ';
    assert_true(fs.createTextFileWithContent(path, content));
    assert_equal(content, fs.fileContentAsString(path));
end

--------------------------------------------------------------------------------------------------------------
function fileContentAsLinesTest()
    local path = tmpDir .. 'file.txt';
    do
        local content = {'1st line', '2nd line', '  '};
        assert_true(fs.createTextFileWithContent(path, table.concat(content, '\n')));
        assert_true(table.isEqual(content, fs.fileContentAsLines(path)));
    end
    do
        local content = {'1st line\r', '2nd line\r', '  '};
        assert_true(fs.createTextFileWithContent(path, table.concat(content, '\n')));
        assert_true(table.isEqual(content, fs.fileContentAsLines(path)));
    end
end