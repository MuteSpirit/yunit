--testEnginePaths
--testContainerPaths

local testEngines = {}

for _, path in pairs(testEnginePaths) do
    local testEngine, errMsg = TestEngine(path)
    if testEngine then
        table.insert(testEngines, testEngine)
        print('TestEngine: ' .. tostring(testEngine))
    else
        print(errMsg)
    end
end

local tcExt = {}
for _, testEngine in pairs(testEngines) do
    local exts = testEngine:supportedExtensions()
    for _, ext in pairs(exts) do
        tcExt[ext] = testEngine
        print(ext)
    end
end

for _, testEngine in pairs(testEngines) do
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
end
