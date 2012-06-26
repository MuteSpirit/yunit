local ym = require "yunit.mine"

 function test_mine()
    local mine = Mine()
    mine.setTimer(1)
    mine.turnoff()
    mine.sleep(1)
end