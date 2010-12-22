 -- -*- coding: utf-8 -*-

-- Documentation


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

local fs = require("filesystem")
local luaExt = require('lua_ext')

local luaUnit = require('testunit.luaunit');
module('filesystem.t', luaUnit.testmodule, package.seeall);


local function trace()
    -- empty for disable output
end


TEST_FIXTURE("UseTestTmpDirFixture")
{
    setUp = function(self)
        self.tmpDir = fs.tmpDirName();
        ASSERT_NOT_NIL(self.tmpDir);
        local curDir = fs.currentdir();
        ASSERT_NOT_NIL(curDir);
        ASSERT_NIL(fs.chdir(self.tmpDir));
        ASSERT_TRUE(fs.mkdir(self.tmpDir));
        ASSERT_TRUE(fs.chdir(self.tmpDir));
        ASSERT_TRUE(fs.chdir(curDir));
    end
    ;

    teardown = function(self)
        ASSERT_NOT_NIL(self.tmpDir);
        ASSERT_TRUE(fs.chdir(self.tmpDir .. '..'))
        ASSERT_TRUE(fs.rmdir(self.tmpDir));
    end
    ;
};

TEST_SUITE("filesystem_test_common")
{


TEST_CASE{"whatOsTest", function(self)
    ASSERT_EQUAL('win', fs.whatOs())
end
};


TEST_CASE{"canonizePathTest", function(self)
    local slash = '/';
    ASSERT_EQUAL('c:/path/to/dir/', fs.canonizePath('c:/path/to/dir/', slash))
    ASSERT_EQUAL('c:/path/to/dir/', fs.canonizePath('c:\\path\\to\\dir\\', slash))
    ASSERT_EQUAL('c:/path/to/dir/subdir', fs.canonizePath('c:\\path/to//dir\\\\subdir', slash))
    ASSERT_EQUAL('\\\\host1/path/to/dir/subdir', fs.canonizePath('\\\\host1\\path/to//dir\\\\subdir'))
    ASSERT_EQUAL('//host2/path/to/dir/subdir', fs.canonizePath('//host2\\path/to//dir\\\\subdir'))
end
};


TEST_CASE{"filenameTest", function(self)
    local name, ext, dir;
    name, ext = fs.filename('c:/readme.txt');
    ASSERT_NOT_NIL(name);
    ASSERT_NOT_NIL(ext);
    ASSERT_EQUAL('txt', ext);
    ASSERT_EQUAL('readme', name);

    name, ext = fs.filename('/tmp/readme.txt');
    ASSERT_NOT_NIL(name);
    ASSERT_NOT_NIL(ext);
    ASSERT_EQUAL('txt', ext);
    ASSERT_EQUAL('readme', name);

    name, ext = fs.filename('./readme.txt');
    ASSERT_NOT_NIL(name);
    ASSERT_NOT_NIL(ext);
    ASSERT_EQUAL('txt', ext);
    ASSERT_EQUAL('readme', name);

    name, ext = fs.filename('c:/readme.txt.bak');
    ASSERT_NOT_NIL(name);
    ASSERT_NOT_NIL(ext);
    ASSERT_EQUAL('bak', ext);
    ASSERT_EQUAL('readme.txt', name);

    name, ext = fs.filename('c:/README');
    ASSERT_NOT_NIL(name);
    ASSERT_NOT_NIL(ext);
    ASSERT_EQUAL(ext, '');
    ASSERT_EQUAL(name, 'README');

    name, ext = fs.filename('c:/');
    ASSERT_NOT_NIL(name);
    ASSERT_NOT_NIL(ext);
    ASSERT_EQUAL(ext, '');
    ASSERT_EQUAL(name, '');

    name, ext = fs.filename('c:/readme.txt ');
    ASSERT_NOT_NIL(name);
    ASSERT_NOT_NIL(ext);
    ASSERT_EQUAL('txt', ext);
    ASSERT_EQUAL('readme', name);

    name, ext = fs.filename('c:/readme_again.tx_t');
    ASSERT_NOT_NIL(name);
    ASSERT_NOT_NIL(ext);
    ASSERT_EQUAL('tx_t', ext);
    ASSERT_EQUAL('readme_again', name);

    name, ext = fs.filename('c:\\path\\to\\dir\\readme_again.tx_t');
    ASSERT_NOT_NIL(name);
    ASSERT_NOT_NIL(ext);
    ASSERT_EQUAL('tx_t', ext);
    ASSERT_EQUAL('readme_again', name);

    name, ext = fs.filename('d:/svn_wv_rpo_trunk/.svn/dir-prop-base');
    ASSERT_NOT_NIL(name);
    ASSERT_NOT_NIL(ext);
    ASSERT_EQUAL('', ext);
    ASSERT_EQUAL('dir-prop-base', name);

    name, ext = fs.filename('d:/svn_wv_rpo_trunk/.svn/dir-prop-base');
    ASSERT_NOT_NIL(name);
    ASSERT_NOT_NIL(ext);
    ASSERT_EQUAL('', ext);
    ASSERT_EQUAL('dir-prop-base', name);

    name, ext, dir = fs.filename('d:/svn_wv_rpo_trunk/dir-prop-base/.svn/dir-prop-base');
    ASSERT_NOT_NIL(name);
    ASSERT_NOT_NIL(ext);
    ASSERT_EQUAL('', ext);
    ASSERT_EQUAL('dir-prop-base', name);
    ASSERT_EQUAL('d:/svn_wv_rpo_trunk/dir-prop-base/.svn/', dir);

    name, ext = fs.filename('d:/svn_wv_rpo_trunk/.svn');
    ASSERT_NOT_NIL(name);
    ASSERT_NOT_NIL(ext);
    ASSERT_EQUAL('svn', ext);
    ASSERT_EQUAL('', name);

    name, ext, dir = fs.filename('d:/svn_wv_rpo_trunk/.svn/.svn');
    ASSERT_NOT_NIL(name);
    ASSERT_NOT_NIL(ext);
    ASSERT_EQUAL('svn', ext);
    ASSERT_EQUAL('', name);
    ASSERT_EQUAL('d:/svn_wv_rpo_trunk/.svn/', dir);

    name, ext, dir = fs.filename('gepart_ac.ini');
    ASSERT_NOT_NIL(name);
    ASSERT_NOT_NIL(ext);
    ASSERT_EQUAL('gepart_ac', name);
    ASSERT_EQUAL('ini', ext);
    ASSERT_EQUAL('', dir);

    name, ext, dir = fs.filename('test spaces.ini');
    ASSERT_NOT_NIL(name);
    ASSERT_NOT_NIL(ext);
    ASSERT_EQUAL('test spaces', name);
    ASSERT_EQUAL('ini', ext);
    ASSERT_EQUAL('', dir);

end
};


TEST_CASE{"isExistTest", function(self)
    ASSERT_TRUE(fs.isExist(fs.currentdir()), fs.currentdir() .. ' is not exist');
    ASSERT_TRUE(fs.isExist('c:/'));
    ASSERT_TRUE(fs.isExist('c:'));
end
};

TEST_CASE{"isDirTest", function(self)
    ASSERT_TRUE(fs.isDir(fs.currentdir()), fs.currentdir() .. ' is not exist');
    ASSERT_TRUE(fs.isDir('c:/'));
    ASSERT_TRUE(fs.isDir('c:'));
end
};


TEST_CASE{"dirnameTest", function(self)
    ASSERT_EQUAL('c:/', fs.dirname('c:/'));
    ASSERT_EQUAL('c:/path/to/dir/', fs.dirname('c:/path/to/dir/file.ext'));
    ASSERT_EQUAL('c:/', fs.dirname('c:/file'));
    ASSERT_EQUAL('c:/dir/', fs.dirname('c:/dir/'));
end
};


TEST_CASE{"isFullPathTest", function(self)
    local OS = fs.whatOs();
    if 'win' == OS then
        ASSERT_TRUE(fs.isFullPath('c:/dir'));
        ASSERT_TRUE(fs.isFullPath('C:/dir'));
        ASSERT_TRUE(fs.isFullPath('\\\\host/dir'));
        ASSERT_FALSE(fs.isFullPath('../dir'));
        ASSERT_FALSE(fs.isFullPath('1:/dir'));
        ASSERT_FALSE(fs.isFullPath('abc:/dir'));
        ASSERT_FALSE(fs.isFullPath('д:/dir'));
        ASSERT_TRUE(fs.isFullPath('/etc/fstab'));
    elseif 'unix' == OS then
        ASSERT_TRUE(fs.isFullPath('/etc/fstab'));
        ASSERT_TRUE(fs.isFullPath('~/dir'));
        ASSERT_FALSE(fs.isFullPath('./configure'));
    else
        ASSERT_TRUE(false, "Unknown operative system");
    end
end
};


TEST_CASE{"isRelativePathTest", function(self)
    local OS = fs.whatOs();
    if 'win' == OS then
        ASSERT_TRUE(fs.isRelativePath('./dir'));
        ASSERT_TRUE(fs.isRelativePath('../dir'));

        ASSERT_FALSE(fs.isRelativePath('.../dir'));
        ASSERT_FALSE(fs.isRelativePath('c:/dir'));
        ASSERT_FALSE(fs.isRelativePath('\\\\host/dir'));
    elseif 'unix' == OS then
        ASSERT_TRUE(fs.isRelativePath('./configure'));
        ASSERT_TRUE(fs.isRelativePath('../dir'));

        ASSERT_FALSE(fs.isRelativePath('.../dir'));
        ASSERT_FALSE(fs.isRelativePath('/etc/fstab'));
        ASSERT_FALSE(fs.isRelativePath('~/dir'));
    else
        ASSERT_TRUE(false, "Unknown operative system");
    end
end
};


TEST_CASE{"filePathTemplatesToRePatternsTest", function(self)
    ASSERT_EQUAL('[^/\\]*$', fs.fileTemplToRe('*'));
    ASSERT_EQUAL('[^/\\]?$', fs.fileTemplToRe('?'));
    ASSERT_EQUAL('[^/\\]?[^/\\]?$', fs.fileTemplToRe('??'));
    ASSERT_EQUAL('[^/\\]*%.lua$', fs.fileTemplToRe('*.lua'));
    ASSERT_EQUAL('[^/\\]?[^/\\]*$', fs.fileTemplToRe('?*'));
    ASSERT_EQUAL('[^/\\]*[^/\\]?$', fs.fileTemplToRe('*?'));
    ASSERT_EQUAL('/dir/%([^/\\]?[^/\\]?[^/\\]?[^/\\]*%.[^/\\]*%)%)$', fs.fileTemplToRe('/dir/(???*.*))'));
end
};


TEST_CASE{"selectFilesByTemplatesTest", function(self)
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
        ASSERT_EQUAL(expected[i], actual[i]);
    end
    actual = fs.excludeFiles(expected, '*.t.cpp');
    expected = {'file.cpp'};
    for i = 1, #expected do
        ASSERT_EQUAL(expected[i], actual[i]);
    end

    expected = {'file.luac', 'file.lua', 'file.t.lua', };
    actual = fs.includeFiles(fileNames, '*.lua?');
    for _, path in pairs(expected) do
        ASSERT_TRUE(luaExt.findValue(actual, path));
    end
    actual = fs.excludeFiles(fileNames, '*c');
    expected = {'file.lua', 'file.t.lua', };
    for _, path in pairs(expected) do
        ASSERT_TRUE(luaExt.findValue(actual, path));
    end

    expected = {'file.c', 'file.cpp', 'file.cxx', };
    actual = fs.includeFiles(fileNames, '*.c*');
    for _, path in pairs(expected) do
        ASSERT_TRUE(luaExt.findValue(actual, path));
    end
end
};


TEST_CASE{"filePathByTemplateTest", function(self)
    ASSERT_TRUE(fs.includeFile('main.h', '*.h'));
    ASSERT_TRUE(fs.includeFile('main.cpp', '*.cpp'));
    ASSERT_FALSE(fs.includeFile('main.h ', '*.h'));

    ASSERT_TRUE(fs.includeFile('main.h', '*.?'));
    ASSERT_TRUE(fs.includeFile('main.c', '*.?'));
    ASSERT_TRUE(fs.includeFile('main.c', '*.??'));

    ASSERT_TRUE(fs.includeFile('main.t.cpp', '*.cpp'));
    ASSERT_TRUE(fs.includeFile('main.h.cpp', '*.cpp'));
    ASSERT_FALSE(fs.includeFile('main.h.cpp', '*.h'));

    ASSERT_TRUE(fs.includeFile('./main.h', '*.h'));
    ASSERT_TRUE(fs.includeFile('../main.h', '*.h'));
    ASSERT_TRUE(fs.includeFile('d:/main.cpp/main.h', '*.h'));
    ASSERT_FALSE(fs.includeFile('d:/main.cpp/main.h', '*.cpp'));
end
};


};

TEST_SUITE("filesystem_test_files")
{




TEST_CASE_EX{"mkAndRmDirTest", "UseTestTmpDirFixture", function(self)
    ASSERT_TRUE(fs.chdir(self.tmpDir));
    -- delete empty directory
    do
        local tmpSubdir = self.tmpDir .. os.tmpname();
        ASSERT_TRUE(fs.mkdir(tmpSubdir));
        ASSERT_TRUE(fs.chdir(tmpSubdir));
        ASSERT_TRUE(fs.chdir(self.tmpDir));
        ASSERT_TRUE(fs.rmdir(tmpSubdir));
    end
    -- delete directory with empty text file
    do
        local tmpSubdir = self.tmpDir .. os.tmpname() .. fs.slash();
        ASSERT_NIL(fs.chdir(tmpSubdir))
        ASSERT_TRUE(fs.mkdir(tmpSubdir))
        ASSERT_TRUE(fs.chdir(tmpSubdir))
        local tmpFilePath = tmpSubdir .. 'tmp.file'
        local tmpFile = io.open(tmpFilePath, 'w')
        ASSERT_NOT_NIL(tmpFile)
        tmpFile:close()
        ASSERT_TRUE(fs.chdir(self.tmpDir))
        ASSERT_TRUE(fs.rmdir(tmpSubdir))
    end
    -- delete directory with NOT empty text file
    do
        local tmpSubdir = self.tmpDir .. os.tmpname() .. fs.slash();
        ASSERT_NIL(fs.chdir(tmpSubdir))
        ASSERT_TRUE(fs.mkdir(tmpSubdir))
        ASSERT_TRUE(fs.chdir(tmpSubdir))

        local tmpFilePath = tmpSubdir .. 'tmp.file'
        local tmpFile = io.open(tmpFilePath, 'w')
        ASSERT_NOT_NIL(tmpFile)
        tmpFile:write('some\nsimple\ntext\n')
        tmpFile:close()

        ASSERT_TRUE(fs.chdir(self.tmpDir))
        ASSERT_TRUE(fs.rmdir(tmpSubdir))
    end
    -- delete directory with empty subdirectory
    do
        local tmpSubdir = self.tmpDir .. os.tmpname() .. fs.slash();
        ASSERT_NIL(fs.chdir(tmpSubdir))
        ASSERT_TRUE(fs.mkdir(tmpSubdir))
        ASSERT_TRUE(fs.chdir(tmpSubdir))

        local tmpSubSubdir = tmpSubdir .. 'subdir' .. fs.slash();
        ASSERT_NIL(fs.chdir(tmpSubSubdir));
        ASSERT_TRUE(fs.mkdir(tmpSubSubdir));
        ASSERT_TRUE(fs.chdir(tmpSubSubdir));
        ASSERT_TRUE(fs.chdir(self.tmpDir));

        ASSERT_TRUE(fs.rmdir(tmpSubdir));
    end
    -- delete directory with subdirectory with NOT empty text file
    do
        local tmpSubdir = self.tmpDir .. os.tmpname() .. fs.slash();
        ASSERT_NIL(fs.chdir(tmpSubdir))
        ASSERT_TRUE(fs.mkdir(tmpSubdir))
        ASSERT_TRUE(fs.chdir(tmpSubdir))

        local tmpSubSubdir = tmpSubdir .. 'subdir' .. fs.slash();
        ASSERT_NIL(fs.chdir(tmpSubSubdir));
        ASSERT_TRUE(fs.mkdir(tmpSubSubdir));
        ASSERT_TRUE(fs.chdir(tmpSubSubdir));

        local tmpFilePath = tmpSubSubdir .. 'tmp.file'
        local tmpFile = io.open(tmpFilePath, 'w')
        ASSERT_NOT_NIL(tmpFile)
        tmpFile:write('some\nsimple\ntext\n')
        tmpFile:close()

        ASSERT_TRUE(fs.chdir(self.tmpDir));
        ASSERT_TRUE(fs.rmdir(tmpSubdir));
    end
end
};


TEST_CASE_EX{"createTextFileWithContentTest", "UseTestTmpDirFixture", function(self)
    local tmpFilePath = self.tmpDir .. 'tmp.file';
    local text = 'some\nsimple\ntext\n';
    ASSERT_TRUE(fs.createTextFileWithContent(tmpFilePath, text));

    local tmpFile = io.open(tmpFilePath, 'r');
    ASSERT_NOT_NIL(tmpFile);
    ASSERT_EQUAL(text, tmpFile:read("*a"));
    tmpFile:close();
end
};


TEST_CASE_EX{"isNetworkPathTest", "UseTestTmpDirFixture", function(self)
    ASSERT_TRUE(fs.isNetworkPath([[\\172.22.3.20\folder\]]));
    ASSERT_TRUE(fs.isNetworkPath([[\\alias\folder\]]));

    ASSERT_FALSE(fs.isNetworkPath('c:/'));
    ASSERT_FALSE(fs.isNetworkPath('../'));
    ASSERT_FALSE(fs.isNetworkPath('./'));
    ASSERT_FALSE(fs.isNetworkPath('/'));
    ASSERT_FALSE(fs.isNetworkPath('\\'));

    ASSERT_TRUE(fs.isNetworkPath([[\\172.22.3.20\folder\file.ext]]));
    ASSERT_TRUE(fs.isNetworkPath([[\\alias\folder\file.ext]]));
    
    ASSERT_FALSE(fs.isNetworkPath('c:/file.ext'));
    ASSERT_FALSE(fs.isNetworkPath('../file.ext'));
    ASSERT_FALSE(fs.isNetworkPath('./file.ext'));
    ASSERT_FALSE(fs.isNetworkPath('/file.ext'));
    ASSERT_FALSE(fs.isNetworkPath('\\file.ext'));
end
};


TEST_CASE_EX{"isLocalFullPathTest", "UseTestTmpDirFixture", function(self)
    ASSERT_TRUE(fs.isLocalFullPath('c:/'));
    ASSERT_TRUE(fs.isLocalFullPath('/'));
    ASSERT_TRUE(fs.isLocalFullPath('\\'));

    ASSERT_TRUE(fs.isLocalFullPath('c:/file.ext'));
    ASSERT_TRUE(fs.isLocalFullPath('/file.ext'));
    ASSERT_TRUE(fs.isLocalFullPath('\\file.ext'));

    ASSERT_FALSE(fs.isLocalFullPath([[\\172.22.3.20\folder\]]));
    ASSERT_FALSE(fs.isLocalFullPath([[\\alias\folder\]]));
end
};


TEST_CASE_EX{"isLocalPathTest", "UseTestTmpDirFixture", function(self)
    ASSERT_TRUE(fs.isLocalPath('c:/'));
    ASSERT_TRUE(fs.isLocalPath('../'));
    ASSERT_TRUE(fs.isLocalPath('./'));
    ASSERT_TRUE(fs.isLocalPath('/'));
    ASSERT_TRUE(fs.isLocalPath('\\'));

    ASSERT_TRUE(fs.isLocalPath('c:/file.ext'));
    ASSERT_TRUE(fs.isLocalPath('../file.ext'));
    ASSERT_TRUE(fs.isLocalPath('./file.ext'));
    ASSERT_TRUE(fs.isLocalPath('/file.ext'));
    ASSERT_TRUE(fs.isLocalPath('\\file.ext'));
    
    ASSERT_FALSE(fs.isLocalPath([[\\172.22.3.20\folder\]]));
    ASSERT_FALSE(fs.isLocalPath([[\\alias\folder\]]));
    
    ASSERT_FALSE(fs.isLocalPath([[\\172.22.3.20\folder\file.ext]]));
    ASSERT_FALSE(fs.isLocalPath([[\\alias\folder\file.ext]]));
end
};



TEST_CASE_EX{"dirBypassTest", "UseTestTmpDirFixture", function(self)
--     local fileNames =
--     {
--         'file.cpp', 'file.h', 'file.t.cpp',
--         'file.lua', 'file.t.lua', 'file.luac',
--         'file.cxx', 'file.c', 'file.hpp',
--         'file.txt', 'file', 'FILE',
--     end
--~     };
    local slash = fs.slash();
    -- Test defining if it is directory or not
    ASSERT_TRUE(fs.isDir(self.tmpDir));
    local tmpFilePath = self.tmpDir .. 'tmp.file';
    ASSERT_TRUE(fs.createTextFileWithContent(tmpFilePath));
    ASSERT_FALSE(fs.isDir(tmpFilePath))

    local dirname = self.tmpDir;
    local pathes = {};

    table.insert(pathes, tmpFilePath);

    dirname = dirname..'dir'..slash;
    ASSERT_TRUE(fs.mkdir(dirname));
    ASSERT_TRUE(fs.createTextFileWithContent(dirname .. 'file.1'));
    table.insert(pathes, dirname .. 'file.1');

    dirname = dirname..'subdir'..slash;
    ASSERT_TRUE(fs.mkdir(dirname));
    ASSERT_TRUE(fs.createTextFileWithContent(dirname .. 'file.2'));
    table.insert(pathes, dirname .. 'file.2');
--[=[
    tmp.file
    dir/file.1
    dir/subdir/file.2
--]=]
    --[[
    local files = fs.ls(self.tmpDir, {recursive = true, fullPath = true, onlyFiles = true});
    --]]
    local files = fs.ls(self.tmpDir, {recursive = true, fullPath = true, showDirs = false, showFiles = true});
    ASSERT_EQUAL(#pathes, #files);

    for _, file in ipairs(pathes) do
        ASSERT_TRUE(luaExt.findValue(files, file));
    end
-- test by Gorokhov
    files = fs.ls(self.tmpDir, {recursive = false, fullPath = true, showDirs = true, showFiles = true});
    ASSERT_EQUAL(2, #files);

    files = fs.ls(self.tmpDir, {recursive = true, fullPath = true, showDirs = true, showFiles = false});
    ASSERT_EQUAL(2, #files);

end
};


TEST_CASE_EX{"absPathOnFullFilePathsTest", "UseTestTmpDirFixture", function(self)
    ASSERT_EQUAL('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/./dir2/file.txt'));
    ASSERT_EQUAL('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/./dir2/./file.txt'));
    ASSERT_EQUAL('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/././dir2/file.txt'));
    ASSERT_EQUAL('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/dir2/dir3/../file.txt'));
    ASSERT_EQUAL('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/dir2/./dir3/../file.txt'));
    ASSERT_EQUAL('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/dir2/dir3/.././file.txt'));
    ASSERT_EQUAL('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/dir2/dir3/./../file.txt'));
    ASSERT_EQUAL('d:/dir1/dir2/file.txt', fs.absPath('d:/dir1/dir2/dir3/./.././file.txt'));
    ASSERT_EQUAL('d:/dir1/file.txt', fs.absPath('d:/dir1/dir2/../dir3/../file.txt'));

    ASSERT_EQUAL('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\.\\dir2\\file.txt'));
    ASSERT_EQUAL('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\.\\dir2\\.\\file.txt'));
    ASSERT_EQUAL('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\.\\.\\dir2\\file.txt'));
    ASSERT_EQUAL('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\dir2\\dir3\\..\\file.txt'));
    ASSERT_EQUAL('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\dir2\\.\\dir3\\..\\file.txt'));
    ASSERT_EQUAL('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\dir2\\dir3\\..\\.\\file.txt'));
    ASSERT_EQUAL('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\dir2\\dir3\\.\\..\\file.txt'));
    ASSERT_EQUAL('d:/dir1/dir2/file.txt', fs.absPath('d:\\dir1\\dir2\\dir3\\.\\..\\.\\file.txt'));
    ASSERT_EQUAL('d:/dir1/file.txt', fs.absPath('d:\\dir1\\dir2\\..\\dir3\\..\\file.txt'));
end
};


TEST_CASE_EX{"absPathOnRelativePathsTest", "UseTestTmpDirFixture", function(self)
    ASSERT_EQUAL(fs.currentdir() .. 'dir1/', fs.absPath('./dir1/'));
end
};

TEST_CASE_EX{"copyTest", "UseTestTmpDirFixture", function(self)
    local text = 'some\nsimple\ntext\n';
    local srcFilePath = self.tmpDir .. 'tmp.txt.1';
    local dstFilePath = self.tmpDir .. 'tmp.txt.2';
    fs.createTextFileWithContent(srcFilePath, text);
    ASSERT_NOT_EQUAL(srcFilePath, dstFilePath);
    -- copy text file
    ASSERT_TRUE(fs.copy(srcFilePath, dstFilePath));

    ASSERT_TRUE(fs.isExist(srcFilePath));
    ASSERT_TRUE(fs.isExist(dstFilePath));

    ASSERT_TRUE(fs.isFile(srcFilePath));
    ASSERT_TRUE(fs.isFile(dstFilePath));
end
};


--~ TEST_CASE_EX{"copyDirTest", "UseTestTmpDirFixture", function(self)
--~     fs.mkdir(self.tmpDir .. '1/');
--~     fs.mkdir(self.tmpDir .. '2/');

--~     local text = 'some\nsimple\ntext\n';
--~     fs.createTextFileWithContent(self.tmpDir .. '1/' .. 'tmp.txt', text);

--~     ASSERT_TRUE(fs.copyDir(self.tmpDir .. '1/', self.tmpDir .. '2/'));

--~     ASSERT_TRUE(fs.isExist(self.tmpDir .. '1/2/'));
--~     ASSERT_TRUE(fs.isDir(self.tmpDir .. '1/2/'));

--~     ASSERT_TRUE(fs.isExist(self.tmpDir .. '1/2/' .. 'tmp.txt'));
--~     ASSERT_TRUE(fs.isFile(self.tmpDir .. '1/2/' .. 'tmp.txt'));
--~ end


TEST_CASE_EX{"relativePathTest", "UseTestTmpDirFixture", function(self)
    ASSERT_EQUAL('subdir/', fs.relativePath('c:/path/to/dir/subdir/', 'c:/path/to/dir/'));
    ASSERT_EQUAL('subdir\\', fs.relativePath('c:\\path\\to\\dir\\subdir\\', 'c:\\path\\to\\dir\\'));
end
};


TEST_CASE_EX{"applyOnFilesTest", "UseTestTmpDirFixture", function(self)
    local slash = fs.slash();
    -- Test defining if it is directory or not
    ASSERT_TRUE(fs.isDir(self.tmpDir));
    local tmpFilePath = self.tmpDir .. 'tmp.file';
    ASSERT_TRUE(fs.createTextFileWithContent(tmpFilePath));
    ASSERT_FALSE(fs.isDir(tmpFilePath))

    local dirname = self.tmpDir;
    local pathes = {};

    dirname = dirname..'dir'..slash;
    ASSERT_TRUE(fs.mkdir(dirname));
    ASSERT_TRUE(fs.createTextFileWithContent(dirname .. 'file.1'));
    table.insert(pathes, dirname .. 'file.1');

    dirname = dirname..'subdir'..slash;
    ASSERT_TRUE(fs.mkdir(dirname));
    ASSERT_TRUE(fs.createTextFileWithContent(dirname .. 'file.2'));
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
        
        fs.applyOnFiles(self.tmpDir, {handler = savePath, state = files, recursive = true});
        
        ASSERT_EQUAL(#pathes, #files);
        ASSERT_TRUE(table.isEqual(pathes, files));
    end
    do
        local function fileFilter(path)
            return not fs.isDir(path);
        end
        
        local function savePath(path, state)
            table.insert(state, path);
        end

        local files = {};
        
        fs.applyOnFiles(self.tmpDir, {handler = savePath, filter = fileFilter, state = files, recursive = true});
        ASSERT_EQUAL(#pathes, #files);
        ASSERT_TRUE(table.isEqual(pathes, files));
    end
end
};

TEST_CASE_EX{"bytesToTest", "UseTestTmpDirFixture", function(self)
    ASSERT_EQUAL(1, fs.bytesTo(1024, 'k'));
    ASSERT_EQUAL(1, fs.bytesTo(1024, 'K'));
    ASSERT_EQUAL(1, fs.bytesTo(1024 * 1024, 'M'));
    ASSERT_EQUAL(1024 * 1024, fs.bytesTo(1024 * 1024, 'm'));
end
};

TEST_CASE_EX{"fileLastModTimeTest", "UseTestTmpDirFixture", function(self)
    local filetime = fs.fileLastModTime('c:/windows/system32/cmd.exe');
    local curTime = os.time();
    ASSERT_TRUE(os.time(filetime) < os.time());
    ASSERT_TRUE(os.difftime(curTime, os.time(filetime)) > 0);
end
};

TEST_CASE_EX{"rmfileTest", "UseTestTmpDirFixture", function(self)
    local tmpFilePath = self.tmpDir .. 'file.tmp';
    ASSERT_TRUE(fs.createTextFileWithContent(tmpFilePath));
    ASSERT_TRUE(fs.isFile(tmpFilePath));
    ASSERT_TRUE(fs.rmfile(tmpFilePath));
    ASSERT_FALSE(fs.isExist(tmpFilePath));
end
};


TEST_CASE_EX{"localPathToFormatOfNetworkPathTest", "UseTestTmpDirFixture", function(self)
end
};


TEST_CASE_EX{"fileContentAsStringTest", "UseTestTmpDirFixture", function(self)
    local path = self.tmpDir .. 'file.txt';
    local content = '1st line\r\n2nd line\n  ';
    ASSERT_TRUE(fs.createTextFileWithContent(path, content));
    ASSERT_EQUAL(content, fs.fileContentAsString(path));
end
};


TEST_CASE_EX{"fileContentAsLinesTest", "UseTestTmpDirFixture", function(self)
    local path = self.tmpDir .. 'file.txt';
    do
        local content = {'1st line', '2nd line', '  '};
        ASSERT_TRUE(fs.createTextFileWithContent(path, table.concat(content, '\n')));
        ASSERT_TRUE(table.isEqual(content, fs.fileContentAsLines(path)));
    end
    do
        local content = {'1st line\r', '2nd line\r', '  '};
        ASSERT_TRUE(fs.createTextFileWithContent(path, table.concat(content, '\n')));
        ASSERT_TRUE(table.isEqual(content, fs.fileContentAsLines(path)));
    end
end
};
};