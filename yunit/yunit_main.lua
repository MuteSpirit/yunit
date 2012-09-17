--testEnginePaths
--testContainerPaths

local testEngines = {}

for _, path in pairs(testEnginePaths) do
    local testEngine, errMsg = TestEngine(path)
    if testEngine then
        table.insert(testEngines, testEngine)
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
        local tests = testEngine:load(path)
        for _, test in pairs(tests) do
            print(test)
        end
    end
end
