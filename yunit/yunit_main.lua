-- Execution environment:
-- (1) Variables:
--  (var) program            (string) Path for executable file, used to run current process 
--  (var) testEnginePaths    (table)  List of path to test engine files
--  (var) testContainerPaths (table)  List of path to test container files
-- all standart Lua libraries are loaded

--[[
    Problem 1:
        Every Test Engine is build as Dynamic Link Library. 
        Every may be linked with other Dynamic Link Libraries.
        There is not zero opportunity, that two (or more) Test Engine are linked with library of the same name.
        So conflict will occure, if we load both Test Engine simultaneously.
    
    Problem 2:
    
    How defence from problems:
      * work only with one Test Engine in the same time. Unload DLL after using
      * change working directory to Test Engine file directory
--]]

--[[
    Problem 3:
        Several Test Engines may support 
--]]

local testEngine, errMsg

for _, path in pairs(testEnginePaths) do
    testEngine, errMsg = TestEngine(path)
    if testEngine then
        print('TestEngine: ' .. tostring(testEngine))

        for _, path in pairs(testContainerPaths) do
            print(path)
            
            local unitTests = testEngine:load(path)
            print('unitTests = ', unitTests)
            print(#unitTests)
            
            for _, unitTest in pairs(unitTests) do
                unitTest:start(logger)
                unitTest:test(logger)
            end
        end
    else
        print(errMsg)
    end
    testEngine:unload()
    testEngine = nil
end

