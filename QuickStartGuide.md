# yUnit 0.3.10 #
## Installation ##
Install dependencies:
  1. On Linux
```
sudo apt-get install liblua5.1-0 liblua5.1-0-dev  lua5.1 liblua5.1-filesystem0
```
  1. On Windows
    * download LuaForWindows v5.1.4 (http://code.google.com/p/luaforwindows/)
    * install LuaForWindows (use Full Installation and Default Installatin directory)

Download sutable for your OS installer from yUnit Download Page (http://code.google.com/p/yunit/downloads/list). Simply execute exe file or use dpkg for install deb file.


## Get blank project ##
Download http://yunit.googlecode.com/files/yunit_blank_project.zip. Make new directory, extract archive content into it and use CMake to generate appropriate project file (Visual Studio project file, Makefile, etc). For example, for Visual Studio 2010:
```
# yunit_blank_project.zip was previously extract into 'yunit_sample' directory
# 'yunit_sample' is current directory
cd ..
mkdir yunit_sample_build
cd yunit_sample_build
cmake ..\yunit_sample -G "Visual Studio 10"
# cmake will generate sample.t.vcxproj
```

# yUnit 0.3.7 #
## Installation ##
  1. Download installer setup\_yunit.msi from Download Page (http://yunit.googlecode.com/files/setup_yunit.msi).
  1. Execute it
  1. Follow Install Wizard advises

For installation you need administer privileges.
If there is previously installed Lua on your computer, you should although minimally uninstall it:
  1. Remove path to file lua5.1.exe from environment variable PATH
  1. Delete environment variables LUA\_PATH and LUA\_CPATH

## Get template project file ##
Download sample.t.vcxproj from Download Page (http://yunit.googlecode.com/files/sample.t.vcxproj)

# Write tests #

## First C++ test ##

  1. Create new directory
  1. Get/generate project file
  1. Open it with Visual Studio 2010
  1. Write next code into file
```
#include <yunit/test.h>

test(testA)
{
    isTrue(false != true);
}
```
  1. Build project
  1. In the Output Window you will see:
```
[.]
Execution of tests has been completed:
			Failed:      0
			Errors:      0
			Ignored:     0
			Successful:  1
			Total:       1
```
So our new test has been executed successfully
  1. Add a couple of new unit tests:
```
test(failedTest)
    isTrue(false)
end

_test(ignoredTest)
    isTrue(false)
end
```
  1. Build project and see in Output:
```
[I.F]
Execution of tests has been completed:
			Failed:      1	(0_-) BUGS !!!
			Errors:      0
			Ignored:     1	o(^_^)o ?
			Successful:  1
			Total:       3
----Errors----
cpp_sample.t.cpp::failedTest
	cpp_sample.t.cpp(8) : false != true
----Ignored----
cpp_sample.t.cpp(12) : cpp_sample.t.cpp::_ignoredTest
```
You can see, that 1st test was ignored (status I), 2nd was success (status .) and 3rd was failed (status F). If you make double click on line
```
cpp_sample.t.lua(8) : false != true
```
cursor will be moved on line with failed assert

## First Lua test ##

Now we describe creating unit test for Lua programming language using SciTE text editor.

  1. Create new file with extension `*.t.lua`, for example `lua_sample.t.lua`
  1. Open it with SciTE
  1. Add text
```
function testA()
    isTrue(false ~= true);
end
```
  1. Save file
  1. Open SciTE local properties file (menu "Options" -> "Open Local Options File")
  1. Add follow and save
```
command.go.*.t.lua=lua5.1.exe -l yunit.work_in_scite -l yunit.lua_test_run -e "run([[$(FileNameExt)]])"
```
  1. Switch to `lua_sample.t.lua` tab
  1. Push F5
  1. Next message will appear into Output Panel
```
[.]
Execution of tests has been completed:
			Failed:      0
			Errors:      0
			Ignored:     0
			Successful:  1
		        Total:       1
```
So test was success
  1. Add two more unit tests
```
function failedTest()
    isTrue(false)
end

function _ignoredTest()
    isTrue(false)
end
```
  1. Save and push F5
  1. You will see
```
[I.F]
Execution of tests has been completed:
			Failed:      1	(0_-) BUGS !!!
			Errors:      0
			Ignored:     1	o(^_^)o ?
			Successful:  1
			Total:       3
----Errors----
lua_sample.t.lua::failedTest
	lua_sample.t.lua : 6 : true expected but was nil or false
----Ignored----
lua_sample.t.lua : 10 : lua_sample.t.lua::_ignoredTest
```
You can see, that 1st test was ignored (status I), 2nd was success (status .) and 3rd was failed (status F). If you make double click on line
```
lua_sample.t.lua : 6 : true expected but was nil or false
```
cursor will be moved on line with failed assert