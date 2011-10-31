 -- -*- coding: utf-8 -*-

-- Documentation

--- \fn createTextFileWithContent(path, content)
--- \brief создает файл с указанным текстовым содержимым
--- \param[in] path путь к создаваемому файлу (ВНИМАНИЕ! Существующий файл с тем же именем будет перезаписан)
--- \param[in] содержимое, к-ое необходимо записать в созданный файл
--- \return true, если все прошло без ошибок, иначе - false


local lfs = require "yunit.lfs"
local fs = require "yunit.filesystem"
local luaExt = require "yunit.lua_ext"
local atf = require "yunit.aux_test_func"

local luaUnit = require('yunit.luaunit');



local function trace()
    -- empty for disable output
end

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

function useTestTmpDirFixture.createTextFileWithContentTest()
    local tmpFilePath = tmpDir .. fs.osSlash() .. 'tmp.file';
    local text = 'some\nsimple\ntext\n';
    isTrue(atf.createTextFileWithContent(tmpFilePath, text));

    local tmpFile = io.open(tmpFilePath, 'r');
    isNotNil(tmpFile);
    areEq(text, tmpFile:read("*a"));
    tmpFile:close();
end

function useTestTmpDirFixture.fileContentAsStringTest()
    local path = tmpDir .. 'file.txt';
    local content = '1st line\r\n2nd line\n  ';
    isTrue(atf.createTextFileWithContent(path, content));
    areEq(content, atf.fileContentAsString(path));
end


function useTestTmpDirFixture.fileContentAsLinesTest()
    local path = tmpDir .. 'file.txt';
    do
        local content = {'1st line', '2nd line', '  '};
        isTrue(atf.createTextFileWithContent(path, table.concat(content, '\n')));
        isTrue(table.isEqual(content, atf.fileContentAsLines(path)));
    end
    do
        local content = {'1st line\r', '2nd line\r', '  '};
        isTrue(atf.createTextFileWithContent(path, table.concat(content, '\n')));
        isTrue(table.isEqual(content, atf.fileContentAsLines(path)));
    end
end
