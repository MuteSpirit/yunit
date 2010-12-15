local luaUnit = require("lua_unit");

module("lua_test_sample", luaUnit.testmodule, package.seeall);

TEST_FIXTURE("SampleFixture")
{
    setUp = function(self)
        self.q_.initialize();
    end
    ;
    tearDown = function(self)
        self.q_.release();
    end
    ;
    q_ = 
    {
        initialize = function() end;
        release = function() end;
        add = 
            function(self, value)
                table.insert(self.list, value);
                if self.list[#self.list] then
                    return true;
                end
            end;
        list = {};
    };
};


TEST_SUITE("SampleTestSuite")
{
    TEST_CASE_EX{"addTest", "SampleFixture", function(self)
        ASSERT_TRUE(self.q_:add(""));
    end
    };
    
    TEST_CASE{"simpleTest", function(self)
        local q = 2;
        ASSERT_EQUAL(4, q + 2);
    end
    };
};
