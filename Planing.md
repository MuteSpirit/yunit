# Introduction #

Google Code has only bug tracker, but there are no ERP system. I will add tasks and plans into this document.
Tasks with normal font is Planned.
Tasks with strikeout font is Done.
Tasks with bold font is In Progress.

# Works #
| № | № | Title | Cost (in hours) | Status | Comment |
|:----|:----|:------|:----------------|:-------|:--------|
| w0001 |  | ~~Move all opened tasks into Planing page~~ | 1h |  |
| w0002 |  | Opportunity to keep test with same name in different .t.cpp files | h |  |
| w0003 |  | Add opportunity to form environment for tests | h |  |
| w0004 |  | Add build/test configuration, depend on OS and Lua version (5.1 or 5.2) | h |  |
| w0005 |  | ~~[issue 12](https://code.google.com/p/yunit/issues/detail?id=12). Add 'mine' for test process to avoid infinite tests~~ | h |  |
|  | w0014 | ~~Implement for Windows~~ | 2h |  |
|  | w0015 | ~~Implement for Linux (using pthreads library~~ | 3h |  |
|  | w0016 | ~~Add 'mine' usage into TestRunner~~ | <1h |  |
|  | w0023 | ~~Fix bug with stopping mine thread~~ | 1h |  |
| w0006 |  | Show last added tests after test run finish | h |  |
| w0007 |  | ~~Add work\_in\_netbeans.lua~~ | < 1h |  |
| w0008 |  | Add work\_in\_console.lua and colorize messages | h |  |
| w0009 |  | ~~Escape dependency on windows header files into yUnit headers~~ | h |  |
| w0010 |  | ~~Fix usage #pragma once~~ | <1h |  |
| w0011 |  | Replace in Lua code new() usage with functions a'la constructors | h |  |
| w0012 |  | Add/edit documentation for beginners in TDD | h |  |
| w0013 |  | Design integration with COVTOOL | h |  |
| w0018 |  | ~~Make command line or yUnit start more simple~~ |  |  |
|  | w0019 | ~~Replace "-l yunit.default\_test\_run" with "-l yunit"~~ | 2h |  |
|  | w0017 | ~~Detect parent process (Visual Studio, SciTE, Netbeans, console, etc.) and auto choose error message format~~ | 4h |  |
<a href='Hidden comment: 
On Linux use getppid() function, then readlink ("/proc/$PPID/exe", path, dest_len)
For get all proccess tree you need see all /proc, see ppid in /proc/$PID/status file

On Windows use
NtQueryInformationProcess(NtCurrentProcess(), ProcessBasicInformation, &basicInfo, sizeof(basicInfo), NULL);
// My parent PID (*) is in basicInfo.InheritedFromUniqueProcessId
or
CreateToolhelp32Snapshot and Process32First (using them you may constract all proccess tree)
'></a>
| w0020 |  | Make optional of adding setUp and/or tearDown method into fixtures in yunit.cppunit | h |  |
| w0021 |  | Make optional to finish fixture definition with semicolon (;) in yunit.cppunit | h |  |
| w0022 |  | ~~Combine run and runFrom functions from default\_test\_run. Detect type (file of dir) inside.~~ | 1h |  |
| w0024 |  | ~~Inspert and fix description on project main page~~ | h |  |
| w0025 |  | Add yunit.pythonunit component | h |  |
| w0026 |  | ~~Refactor test result handlers (editorSpecifiedErrorLine)~~ | <1h |  |
| w0027 |  | Add #define with yUnit version number (for using in condition compilation) | h |  |

<a href='Hidden comment: 
|| || w0028|| || h || ||
'></a>

# Plans #

Test iteration period is 1 month. I have no enough time for develop yUnit with full power.