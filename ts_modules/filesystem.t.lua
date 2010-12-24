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

local lfs = require ('lfs')
local fs = require("filesystem")
local luaExt = require('lua_ext')
local atf = require('aux_test_func')

local luaUnit = require('testunit.luaunit');
module('filesystem.t', luaUnit.testmodule, package.seeall);


local function trace()
    -- empty for disable output
end

TEST_FIXTURE("UseTestTmpDirFixture")
{
    setUp = function(self)
        self.tmpDir = fs.tmpDirName();
        ASSERT_IS_NOT_NIL(self.tmpDir);
        local curDir = lfs.currentdir();
        ASSERT_IS_NOT_NIL(curDir);
        ASSERT_IS_NIL(lfs.chdir(self.tmpDir));
        ASSERT_TRUE(lfs.mkdir(self.tmpDir));
        ASSERT_TRUE(lfs.chdir(self.tmpDir));
        ASSERT_TRUE(lfs.chdir(curDir));
    end
    ;

    tearDown = function(self)
        ASSERT_IS_NOT_NIL(self.tmpDir);
        ASSERT_TRUE(lfs.chdir(self.tmpDir .. fs.osSlash() .. '..'))
        local status, msg = fs.rmdir(self.tmpDir)
        ASSERT_EQUAL(nil, msg)
        ASSERT_TRUE(status)
    end
    ;
};

local function winBackslash()
    return '\\';
end

local function unixSlash()
    return '/';
end

TEST_FIXTURE("UseWinPathDelimiterFixture")
{
    setUp = function(self)
        self.osSlash = fs.osSlash
        fs.osSlash = winBackslash
    end
    ;

    teardown = function(self)
        fs.osSlash = self.osSlash
    end
    ;
}

TEST_FIXTURE("UseUnixPathDelimiterFixture")
{
    setUp = function(self)
        self.osSlash = fs.osSlash
        fs.osSlash = unixSlash
    end
    ;

    teardown = function(self)
        fs.osSlash = self.osSlash
    end
    ;
}

TEST_SUITE("filesystem_test_common")
{

TEST_CASE{"whatOsTest", function(self)
    local tmp = os.getenv('TMP');
    if string.match(tmp, '^%w:') then
        ASSERT_EQUAL('win', fs.whatOs())
    else
        ASSERT_EQUAL('unix', fs.whatOs())
    end
end
};


TEST_CASE_EX{"unixCanonizePath", "UseUnixPathDelimiterFixture", function(self)
    ASSERT_EQUAL('c:/path/to/dir', fs.canonizePath('c:/path/to/dir/'))
    ASSERT_EQUAL('c:/path/to/dir', fs.canonizePath('c:\\path\\to\\dir\\'))
    ASSERT_EQUAL('c:/path/to/dir/subdir', fs.canonizePath('c:\\path/to//dir\\\\subdir'))
    ASSERT_EQUAL('\\\\host1/path/to/dir/subdir', fs.canonizePath('\\\\host1\\path/to//dir\\\\subdir'))
    ASSERT_EQUAL('//host2/path/to/dir/subdir', fs.canonizePath('//host2\\path/to//dir\\\\subdir'))
    ASSERT_EQUAL('c:/', fs.canonizePath('c:'));
    ASSERT_EQUAL('c:/', fs.canonizePath('c:/'));
    ASSERT_EQUAL('/', fs.canonizePath('/'));
end
};

TEST_CASE_EX{"winCanonizePath", "UseWinPathDelimiterFixture", function(self)
    ASSERT_EQUAL('c:\\path\\to\\dir', fs.canonizePath('c:/path/to/dir/'))
    ASSERT_EQUAL('c:\\path\\to\\dir', fs.canonizePath('c:\\path\\to\\dir\\'))
    ASSERT_EQUAL('c:\\path\\to\\dir\\subdir', fs.canonizePath('c:\\path/to//dir\\\\subdir'))
    ASSERT_EQUAL('\\\\host1\\path\\to\\dir\\subdir', fs.canonizePath('\\\\host1\\path/to//dir\\\\subdir'))
    ASSERT_EQUAL('//host2\\path\\to\\dir\\subdir', fs.canonizePath('//host2\\path/to//dir\\\\subdir'))
    ASSERT_EQUAL('c:\\', fs.canonizePath('c:'));
    ASSERT_EQUAL('c:\\', fs.canonizePath('c:\\'));
    ASSERT_EQUAL('\\', fs.canonizePath('\\'));
end
};

TEST_CASE_EX{"splitFullPathTest", "UseUnixPathDelimiterFixture", function(self)
    local head, tail;
    head, tail = fs.split('c:/dir/file.ext')
    ASSERT_EQUAL('c:/dir', head)
    ASSERT_EQUAL('file.ext', tail)

    head, tail = fs.split('c:/dir/file')
    ASSERT_EQUAL('c:/dir', head)
    ASSERT_EQUAL('file', tail)
    
    head, tail = fs.split('c:/dir/')
    ASSERT_EQUAL('c:/dir', head)
    ASSERT_EQUAL('', tail)
    
    head, tail = fs.split('c:/dir')
    ASSERT_EQUAL('c:/', head)
    ASSERT_EQUAL('dir', tail)
end
};

TEST_CASE_EX{"splitRootPathsTest", "UseUnixPathDelimiterFixture", function(self)
    local head, tail;
    head, tail = fs.split('c:/')
    ASSERT_EQUAL('c:/', head)
    ASSERT_EQUAL('', tail)

    head, tail = fs.split('c:')
    ASSERT_EQUAL('c:/', head)
    ASSERT_EQUAL('', tail)

    head, tail = fs.split('/')
    ASSERT_EQUAL('/', head)
    ASSERT_EQUAL('', tail)
end
};

TEST_CASE_EX{"splitRelativePathsTest", "UseUnixPathDelimiterFixture", function(self)
    local head, tail;
    
    head, tail = fs.split('file.ext')
    ASSERT_EQUAL('', head)
    ASSERT_EQUAL('file.ext', tail)

    head, tail = fs.split('./')
    ASSERT_EQUAL('.', head)
    ASSERT_EQUAL('', tail)

    head, tail = fs.split('./file.ext')
    ASSERT_EQUAL('.', head)
    ASSERT_EQUAL('file.ext', tail)
    
    head, tail = fs.split('../')
    ASSERT_EQUAL('..', head)
    ASSERT_EQUAL('', tail)
    
    head, tail = fs.split('../file.ext')
    ASSERT_EQUAL('..', head)
    ASSERT_EQUAL('file.ext', tail)
end
};

TEST_CASE_EX{"splitNetworkPathsTest", "UseUnixPathDelimiterFixture", function(self)
    local head, tail;
    head, tail = fs.split('\\\\pc-1')
    ASSERT_EQUAL('\\\\pc-1', head)
    ASSERT_EQUAL('', tail)

    head, tail = fs.split('\\\\pc-1/file.ext')
    ASSERT_EQUAL('\\\\pc-1', head)
    ASSERT_EQUAL('file.ext', tail)
end
};
    
TEST_CASE_EX{"filenameTest", "UseUnixPathDelimiterFixture", function(self)
    local name, ext, dir;
    name, ext = fs.filename('c:/readme.txt');
    ASSERT_IS_NOT_NIL(name);
    ASSERT_IS_NOT_NIL(ext);
    ASSERT_EQUAL('txt', ext);
    ASSERT_EQUAL('readme', name);

    name, ext = fs.filename('/tmp/readme.txt');
    ASSERT_IS_NOT_NIL(name);
    ASSERT_IS_NOT_NIL(ext);
    ASSERT_EQUAL('txt', ext);
    ASSERT_EQUAL('readme', name);

    name, ext = fs.filename('./readme.txt');
    ASSERT_IS_NOT_NIL(name);
    ASSERT_IS_NOT_NIL(ext);
    ASSERT_EQUAL('txt', ext);
    ASSERT_EQUAL('readme', name);

    name, ext = fs.filename('c:/readme.txt.bak');
    ASSERT_IS_NOT_NIL(name);
    ASSERT_IS_NOT_NIL(ext);
    ASSERT_EQUAL('bak', ext);
    ASSERT_EQUAL('readme.txt', name);

    name, ext = fs.filename('c:/README');
    ASSERT_IS_NOT_NIL(name);
    ASSERT_IS_NOT_NIL(ext);
    ASSERT_EQUAL(ext, '');
    ASSERT_EQUAL(name, 'README');

    name, ext = fs.filename('c:/');
    ASSERT_IS_NOT_NIL(name);
    ASSERT_IS_NOT_NIL(ext);
    ASSERT_EQUAL(ext, '');
    ASSERT_EQUAL(name, '');

    name, ext = fs.filename('c:/readme.txt ');
    ASSERT_IS_NOT_NIL(name);
    ASSERT_IS_NOT_NIL(ext);
    ASSERT_EQUAL('txt', ext);
    ASSERT_EQUAL('readme', name);

    name, ext = fs.filename('c:/readme_again.tx_t');
    ASSERT_IS_NOT_NIL(name);
    ASSERT_IS_NOT_NIL(ext);
    ASSERT_EQUAL('tx_t', ext);
    ASSERT_EQUAL('readme_again', name);

    name, ext = fs.filename('c:\\path\\to\\dir\\readme_again.tx_t');
    ASSERT_IS_NOT_NIL(name);
    ASSERT_IS_NOT_NIL(ext);
    ASSERT_EQUAL('tx_t', ext);
    ASSERT_EQUAL('readme_again', name);

    name, ext = fs.filename('d:/svn_wv_rpo_trunk/.svn/dir-prop-base');
    ASSERT_IS_NOT_NIL(name);
    ASSERT_IS_NOT_NIL(ext);
    ASSERT_EQUAL('', ext);
    ASSERT_EQUAL('dir-prop-base', name);

    name, ext = fs.filename('d:/svn_wv_rpo_trunk/.svn/dir-prop-base');
    ASSERT_IS_NOT_NIL(name);
    ASSERT_IS_NOT_NIL(ext);
    ASSERT_EQUAL('', ext);
    ASSERT_EQUAL('dir-prop-base', name);

    name, ext= fs.filename('d:/svn_wv_rpo_trunk/dir-prop-base/.svn/dir-prop-base');
    ASSERT_IS_NOT_NIL(name);
    ASSERT_IS_NOT_NIL(ext);
    ASSERT_EQUAL('', ext);
    ASSERT_EQUAL('dir-prop-base', name);

    name, ext = fs.filename('d:/svn_wv_rpo_trunk/.svn');
    ASSERT_IS_NOT_NIL(name);
    ASSERT_IS_NOT_NIL(ext);
    ASSERT_EQUAL('svn', ext);
    ASSERT_EQUAL('', name);

    name, ext = fs.filename('d:/svn_wv_rpo_trunk/.svn/.svn');
    ASSERT_IS_NOT_NIL(name);
    ASSERT_IS_NOT_NIL(ext);
    ASSERT_EQUAL('svn', ext);
    ASSERT_EQUAL('', name);

    name, ext = fs.filename('gepart_ac.ini');
    ASSERT_IS_NOT_NIL(name);
    ASSERT_IS_NOT_NIL(ext);
    ASSERT_EQUAL('gepart_ac', name);
    ASSERT_EQUAL('ini', ext);

    name, ext = fs.filename('test spaces.ini');
    ASSERT_IS_NOT_NIL(name);
    ASSERT_IS_NOT_NIL(ext);
    ASSERT_EQUAL('test spaces', name);
    ASSERT_EQUAL('ini', ext);
end
};


TEST_CASE{"isExistTest", function(self)
    ASSERT_TRUE(fs.isExist(lfs.currentdir()));
    ASSERT_TRUE(fs.isExist('c:/'));
    ASSERT_TRUE(fs.isExist('c:'));
end
};

TEST_CASE{"isDirTest", function(self)
    local path;
    
    ASSERT_TRUE(fs.isDir(lfs.currentdir()));
    ASSERT_TRUE(fs.isDir('c:/'));
    ASSERT_TRUE(fs.isDir('c:'));
    
    path = '/';
    ASSERT_EQUAL('directory', lfs.attributes(path, 'mode'));
    ASSERT_TRUE(fs.isDir(path));
    
    ASSERT_TRUE(fs.isDir('\\'));
end
};


TEST_CASE_EX{"dirnameTest", "UseUnixPathDelimiterFixture", function(self)
    ASSERT_EQUAL('c:/', fs.dirname('c:/'));
    ASSERT_EQUAL('c:/path/to/dir', fs.dirname('c:/path/to/dir/file.ext'));
    ASSERT_EQUAL('c:/', fs.dirname('c:/file'));
    ASSERT_EQUAL('c:/', fs.dirname('c:/dir'));
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
    ASSERT_EQUAL('[^/\\]*$', fs.fileWildcardToRe('*'));
    ASSERT_EQUAL('[^/\\]?$', fs.fileWildcardToRe('?'));
    ASSERT_EQUAL('[^/\\]?[^/\\]?$', fs.fileWildcardToRe('??'));
    ASSERT_EQUAL('[^/\\]*%.lua$', fs.fileWildcardToRe('*.lua'));
    ASSERT_EQUAL('[^/\\]?[^/\\]*$', fs.fileWildcardToRe('?*'));
    ASSERT_EQUAL('[^/\\]*[^/\\]?$', fs.fileWildcardToRe('*?'));
    ASSERT_EQUAL('/dir/%([^/\\]?[^/\\]?[^/\\]?[^/\\]*%.[^/\\]*%)%)$', fs.fileWildcardToRe('/dir/(???*.*))'));
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




TEST_CASE_EX{"DeleteEmptyDirectory", "UseTestTmpDirFixture", function(self)
    local tmpSubdir = self.tmpDir .. fs.osSlash() .. os.tmpname();
    ASSERT_TRUE(lfs.mkdir(tmpSubdir));
    ASSERT_TRUE(lfs.chdir(tmpSubdir));
    ASSERT_TRUE(lfs.chdir(self.tmpDir));
    local status, msg = fs.rmdir(tmpSubdir)
    ASSERT_EQUAL(nil, msg)
    ASSERT_TRUE(status)
end;
};
    
TEST_CASE_EX{"DeleteDirectoryWithEmptyTextFile", "UseTestTmpDirFixture", function(self)
    local tmpSubdir = self.tmpDir .. fs.osSlash() .. os.tmpname();
    ASSERT_IS_NIL(lfs.chdir(tmpSubdir))
    ASSERT_TRUE(lfs.mkdir(tmpSubdir))
    ASSERT_TRUE(lfs.chdir(tmpSubdir))
    local tmpFilePath = tmpSubdir .. fs.osSlash() .. 'tmp.file'
    local tmpFile = io.open(tmpFilePath, 'w')
    ASSERT_IS_NOT_NIL(tmpFile)
    tmpFile:close()
    ASSERT_TRUE(lfs.chdir(self.tmpDir))
    local status, msg = fs.rmdir(tmpSubdir)
    ASSERT_EQUAL(nil, msg)
    ASSERT_TRUE(status)
end;
};

TEST_CASE_EX{"DeleteDirectoryWithNotEmptyTextFile", "UseTestTmpDirFixture", function(self)
    local tmpSubdir = self.tmpDir .. fs.osSlash() .. os.tmpname();
    ASSERT_IS_NIL(lfs.chdir(tmpSubdir))
    ASSERT_TRUE(lfs.mkdir(tmpSubdir))
    ASSERT_TRUE(lfs.chdir(tmpSubdir))

    local tmpFilePath = tmpSubdir .. fs.osSlash() .. 'tmp.file'
    local tmpFile = io.open(tmpFilePath, 'w')
    ASSERT_IS_NOT_NIL(tmpFile)
    tmpFile:write('some\nsimple\ntext\n')
    tmpFile:close()

    ASSERT_TRUE(lfs.chdir(self.tmpDir))
    local status, msg = fs.rmdir(tmpSubdir)
    ASSERT_EQUAL(nil, msg)
    ASSERT_TRUE(status)
end;
};

TEST_CASE_EX{"DeleteDirectoryWithEmptySubdirectory", "UseTestTmpDirFixture", function(self)
    local tmpSubdir = self.tmpDir .. fs.osSlash() .. os.tmpname();
    ASSERT_IS_NIL(lfs.chdir(tmpSubdir))
    ASSERT_TRUE(lfs.mkdir(tmpSubdir))
    ASSERT_TRUE(lfs.chdir(tmpSubdir))

    local tmpSubSubdir = tmpSubdir .. fs.osSlash() .. 'subdir';
    ASSERT_IS_NIL(lfs.chdir(tmpSubSubdir));
    ASSERT_TRUE(lfs.mkdir(tmpSubSubdir));
    ASSERT_TRUE(lfs.chdir(tmpSubSubdir));
    ASSERT_TRUE(fs.isExist(tmpSubSubdir));
    ASSERT_TRUE(lfs.chdir(self.tmpDir));
    
    local status, msg = fs.rmdir(tmpSubdir)
    ASSERT_EQUAL(nil, msg)
    ASSERT_TRUE(status)
end;
};

TEST_CASE_EX{"DeleteDirectoryWithSubdirectoryWithNotEmptyTextFile", "UseTestTmpDirFixture", function(self)
local tmpSubdir = self.tmpDir .. fs.osSlash() .. os.tmpname();
ASSERT_IS_NIL(lfs.chdir(tmpSubdir))
ASSERT_TRUE(lfs.mkdir(tmpSubdir))
ASSERT_TRUE(lfs.chdir(tmpSubdir))

local tmpSubSubdir = tmpSubdir .. fs.osSlash() .. 'subdir';
ASSERT_IS_NIL(lfs.chdir(tmpSubSubdir));
ASSERT_TRUE(lfs.mkdir(tmpSubSubdir));
ASSERT_TRUE(lfs.chdir(tmpSubSubdir));

local tmpFilePath = tmpSubSubdir .. fs.osSlash() .. 'tmp.file'
local tmpFile = io.open(tmpFilePath, 'w')
ASSERT_IS_NOT_NIL(tmpFile)
tmpFile:write('some\nsimple\ntext\n')
tmpFile:close()

ASSERT_TRUE(lfs.chdir(self.tmpDir));
local status, msg = fs.rmdir(tmpSubdir)
ASSERT_EQUAL(nil, msg)
ASSERT_TRUE(status)
end;
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
    local slash = fs.osSlash();
    -- Test defining if it is directory or not
    ASSERT_TRUE(fs.isDir(self.tmpDir));
    local tmpFilePath = self.tmpDir .. slash .. 'tmp.file';
    ASSERT_TRUE(atf.createTextFileWithContent(tmpFilePath));
    ASSERT_FALSE(fs.isDir(tmpFilePath))

    local dirname = self.tmpDir;
    local pathes = {};

    table.insert(pathes, tmpFilePath);

    dirname = dirname .. slash .. 'dir';
    ASSERT_TRUE(lfs.mkdir(dirname));
    ASSERT_TRUE(atf.createTextFileWithContent(dirname .. slash .. 'file.1'));
    table.insert(pathes, dirname .. slash .. 'file.1');

    dirname = dirname .. slash .. 'subdir';
    ASSERT_TRUE(lfs.mkdir(dirname));
    ASSERT_TRUE(atf.createTextFileWithContent(dirname .. slash .. 'file.2'));
    table.insert(pathes, dirname .. slash .. 'file.2');
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


TEST_CASE_EX{"absPathOnFullFilePaths", "UseUnixPathDelimiterFixture", function(self)
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


TEST_CASE_EX{"absPathOnRelativePaths", "UseUnixPathDelimiterFixture", function(self)
    ASSERT_EQUAL(fs.canonizePath(lfs.currentdir()) .. fs.osSlash() .. 'dir1', fs.absPath('./dir1/'));
    ASSERT_EQUAL('c:/dir1', fs.absPath('./dir1/', 'c:/'));
end
};

TEST_CASE_EX{"copyDirWithFileTest", "UseTestTmpDirFixture", function(self)
    local total = 0
    local path

    for n = 0, 10 do
        path = self.tmpDir .. fs.osSlash() .. n .. '.txt'
        atf.createTextFileWithContent(path, string.rep(' ', n));
        ASSERT_EQUAL(n, fs.du(path))
        total = total + n
    end
    ASSERT_EQUAL(total, fs.du(self.tmpDir))
end
};


TEST_CASE_EX{"copyFileToAnotherPlaceTest", "UseTestTmpDirFixture", function(self)
    local text = 'some\nsimple\ntext\n';
    local src = self.tmpDir .. fs.osSlash() .. 'src.txt';
    local dst = self.tmpDir .. fs.osSlash() .. 'dst.txt';

    atf.createTextFileWithContent(src, text);
    ASSERT_NOT_EQUAL(src, dst);

    ASSERT_TRUE(fs.copyFile(src, dst));

    ASSERT_TRUE(fs.isExist(src));
    ASSERT_TRUE(fs.isExist(dst));

    ASSERT_TRUE(fs.isFile(src));
    ASSERT_TRUE(fs.isFile(dst));
    
    ASSERT_EQUAL(text, atf.fileContentAsString(dst))
end
};

TEST_CASE_EX{"copyFileIntoItselfTest", "UseTestTmpDirFixture", function(self)
    local text = 'some\nsimple\ntext\n';
    local src = self.tmpDir .. fs.osSlash() .. 'src.txt';
    local dst = src;

    atf.createTextFileWithContent(src, text)

    ASSERT_IS_NIL(fs.copyFile(src, dst))
end
};

TEST_CASE_EX{"copyDirWithCopyFileFuncTest", "UseTestTmpDirFixture", function(self)
    local srcDir = self.tmpDir .. fs.osSlash() .. '1';
    local srcFile = srcDir .. fs.osSlash() .. 'tmp.txt';
    local dstDir = self.tmpDir .. fs.osSlash() .. '2';
    local dstFile = dstDir .. fs.osSlash() .. 'tmp.txt';

    lfs.mkdir(srcDir);
    lfs.mkdir(dstDir);
    local text = 'some\nsimple\ntext\n';
    atf.createTextFileWithContent(srcFile, text);
    
    ASSERT_IS_NIL(fs.copyFile(srcDir, dstDir))
    ASSERT_IS_NIL(fs.copyFile(srcFile, dstDir))
    ASSERT_IS_NIL(fs.copyFile(srcDir, dstFile))
end
};

TEST_CASE_EX{"copyDirWithFileTest", "UseTestTmpDirFixture", function(self)
    local src = self.tmpDir .. fs.osSlash() .. '1'
    local dst = self.tmpDir .. fs.osSlash() .. '2'
    lfs.mkdir(src);
    lfs.mkdir(dst);

    local text = 'some\nsimple\ntext\n';
    atf.createTextFileWithContent(src .. fs.osSlash() .. 'tmp.txt', text);

    local status, errMsg = fs.copyDir(src, dst)
    ASSERT_EQUAL(nil, errMsg)
    ASSERT_TRUE(status);

    local dstSubDir = dst .. fs.osSlash() .. '1'

    ASSERT_TRUE(fs.isExist(dstSubDir));
    ASSERT_TRUE(fs.isDir(dstSubDir));

    ASSERT_TRUE(fs.isExist(dstSubDir .. fs.osSlash() .. 'tmp.txt'));
    ASSERT_TRUE(fs.isFile(dstSubDir .. fs.osSlash() .. 'tmp.txt'));
end
};

TEST_CASE_EX{"copyDirWithSubdirWithFileTest", "UseTestTmpDirFixture", function(self)
    local src = self.tmpDir .. fs.osSlash() .. '1'
    local srcFile = src .. fs.osSlash() .. 'src.txt'
    local srcSubdir = src .. fs.osSlash() .. 'subdir'
    local srcFileInSubdir = srcSubdir .. fs.osSlash() .. 'tmp.txt'
    
    local dst = self.tmpDir .. fs.osSlash() .. '2'
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
    ASSERT_EQUAL(nil, errMsg)
    ASSERT_TRUE(status);

    ASSERT_TRUE(fs.isExist(srcDirInDstDir));
    ASSERT_TRUE(fs.isDir(srcDirInDstDir));

    ASSERT_TRUE(fs.isExist(dstSubdir));
    ASSERT_TRUE(fs.isDir(dstSubdir));

    ASSERT_TRUE(fs.isExist(dstFile));
    ASSERT_TRUE(fs.isFile(dstFile));

    ASSERT_TRUE(fs.isExist(srcFileInDstSubdir));
    ASSERT_TRUE(fs.isFile(srcFileInDstSubdir));
end
};

TEST_CASE_EX{"copyFilesWithCopyDirFuncTest", "UseTestTmpDirFixture", function(self)
    local srcDir = self.tmpDir .. fs.osSlash() .. '1';
    local srcFile = srcDir .. fs.osSlash() .. 'tmp.txt';
    local dstDir = self.tmpDir .. fs.osSlash() .. '2';
    local dstFile = dstDir .. fs.osSlash() .. 'tmp.txt';

    lfs.mkdir(srcDir);
    lfs.mkdir(dstDir);
    local text = 'some\nsimple\ntext\n';
    atf.createTextFileWithContent(srcFile, text);
    
    ASSERT_IS_NIL(fs.copyDir(srcFile, dstDir))
    ASSERT_IS_NIL(fs.copyDir(srcDir, dstFile))
end
};

TEST_CASE_EX{"copyTest", "UseTestTmpDirFixture", function(self)
end
};



TEST_CASE_EX{"relativePathTest", "UseTestTmpDirFixture", function(self)
    ASSERT_EQUAL('subdir/', fs.relativePath('c:/path/to/dir/subdir/', 'c:/path/to/dir/'));
    ASSERT_EQUAL('subdir\\', fs.relativePath('c:\\path\\to\\dir\\subdir\\', 'c:\\path\\to\\dir\\'));
end
};


TEST_CASE_EX{"applyOnFilesTest", "UseTestTmpDirFixture", function(self)
    local slash = fs.osSlash();
    -- Test defining if it is directory or not
    ASSERT_TRUE(fs.isDir(self.tmpDir));
    local tmpFilePath = self.tmpDir .. slash .. 'tmp.file';
    ASSERT_TRUE(atf.createTextFileWithContent(tmpFilePath));
    ASSERT_FALSE(fs.isDir(tmpFilePath))

    local dirname = self.tmpDir;
    local pathes = {};

    dirname = dirname  .. slash .. 'dir';
    ASSERT_TRUE(lfs.mkdir(dirname));
    ASSERT_TRUE(atf.createTextFileWithContent(dirname .. slash .. 'file.1'));
    table.insert(pathes, dirname .. slash .. 'file.1');

    dirname = dirname .. slash .. 'subdir';
    ASSERT_TRUE(lfs.mkdir(dirname));
    ASSERT_TRUE(atf.createTextFileWithContent(dirname .. slash .. 'file.2'));
    table.insert(pathes, dirname .. slash .. 'file.2');
    
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
    local filetime = os.date('*t', lfs.attributes('c:/windows/system32/cmd.exe', 'change'))
    local curTime = os.time()
    ASSERT_TRUE(os.time(filetime) < os.time())
    ASSERT_TRUE(os.difftime(curTime, os.time(filetime)) > 0)
end
};

TEST_CASE_EX{"lfsTest", "UseTestTmpDirFixture", function(self)
    local size = lfs.attributes('c:/windows/system32/cmd.exe', 'size')
    local size2 = lfs.attributes('c:/windows/system32/cmd21234534538490.exe', 'size')
    ASSERT_TRUE(size > 0);
    ASSERT_IS_NIL(size2)
end
};

TEST_CASE_EX{"localPathToFormatOfNetworkPathTest", "UseTestTmpDirFixture", function(self)
end
};
};