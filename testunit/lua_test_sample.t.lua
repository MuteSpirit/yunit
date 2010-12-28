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

sampleFixture = 
{
    setUp = function(self)
        q_:initialize();
    end
    ;
    tearDown = function(self)
        q_:release();
    end
    ;
};

function simpleTest()
    local q = 2;
    areEq(4, q + 2);
end

function sampleFixture.addTest()
    isTrue(q_:add(""));
end
