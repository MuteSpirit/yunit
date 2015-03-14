## Lua Unit Test Syntax ##
```
local qq =
{
    initialize = function() end;
    release = function() end;
    add = 
        function(self, value)
            table.insert(self.list, value)
            if self.list[#self.list] then
                return true
            end
        end;
    list = {};
};

sampleFixture = 
{
    setUp = function()
        qq:initialize()
    end
    ;
    tearDown = function()
        qq:release()
    end
    ;
};

function simpleTest()
    local q = 2
    areEq(4, q + 2)
end

-- sampleFixture:setUp() will be executed BEFORE 'addTest'
-- sampleFixture:tearDown() will be executed AFTER 'addTest'
function sampleFixture.addTest()
    isTrue(qq:add(""))
end
```

## Assert functions ##

  1. Check logical expression with:
    1. isTrue(actual)
    1. isFalse(actual)
  1. Check for (non)equation:
    1. areEq(expected, actual)
    1. areNotEq(expected, actual)
  1. Check for raising exceptions:
    1. noThrow(functionForRun, ...)
    1. willThrow(functionForRun, ...)
  1. Check type correspondence:
    1. isFunction(actual)
    1. isTable(actual)
    1. isNumber(actual)
    1. isString(actual)
    1. isBoolean(actual)
    1. isBoolean(actual)
    1. isNil(actual)
  1. Check type discrepancy:
    1. isNotFunction(actual)
    1. isNotTable(actual)
    1. isNotNumber(actual)
    1. isNotString(actual)
    1. isNotBoolean(actual)
    1. isNotBoolean(actual)
    1. isNotNil(actual)