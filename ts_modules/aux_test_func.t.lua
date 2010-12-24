 -- -*- coding: utf-8 -*-

-- Documentation

--- \fn createTextFileWithContent(path, content)
--- \brief создает файл с указанным текстовым содержимым
--- \param[in] path путь к создаваемому файлу (ВНИМАНИЕ! Существующий файл с тем же именем будет перезаписан)
--- \param[in] содержимое, к-ое необходимо записать в созданный файл
--- \return true, если все прошло без ошибок, иначе - false


local lfs = require ('lfs')
local fs = require("filesystem")
local luaExt = require('lua_ext')
local atf = require('aux_test_func')

local luaUnit = require('testunit.luaunit');
module('aux_test_func.t', luaUnit.testmodule, package.seeall);


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

TEST_CASE_EX{"createTextFileWithContentTest", "UseTestTmpDirFixture", function(self)
    local tmpFilePath = self.tmpDir .. fs.osSlash() .. 'tmp.file';
    local text = 'some\nsimple\ntext\n';
    ASSERT_TRUE(atf.createTextFileWithContent(tmpFilePath, text));

    local tmpFile = io.open(tmpFilePath, 'r');
    ASSERT_IS_NOT_NIL(tmpFile);
    ASSERT_EQUAL(text, tmpFile:read("*a"));
    tmpFile:close();
end
};

TEST_CASE_EX{"fileContentAsStringTest", "UseTestTmpDirFixture", function(self)
    local path = self.tmpDir .. 'file.txt';
    local content = '1st line\r\n2nd line\n  ';
    ASSERT_TRUE(atf.createTextFileWithContent(path, content));
    ASSERT_EQUAL(content, atf.fileContentAsString(path));
end
};


TEST_CASE_EX{"fileContentAsLinesTest", "UseTestTmpDirFixture", function(self)
    local path = self.tmpDir .. 'file.txt';
    do
        local content = {'1st line', '2nd line', '  '};
        ASSERT_TRUE(atf.createTextFileWithContent(path, table.concat(content, '\n')));
        ASSERT_TRUE(table.isEqual(content, atf.fileContentAsLines(path)));
    end
    do
        local content = {'1st line\r', '2nd line\r', '  '};
        ASSERT_TRUE(atf.createTextFileWithContent(path, table.concat(content, '\n')));
        ASSERT_TRUE(table.isEqual(content, atf.fileContentAsLines(path)));
    end
end
};