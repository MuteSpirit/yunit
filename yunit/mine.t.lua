local mine = require "yunit.mine"

 function test_mine()
    mine.setTimer(1)
    mine.turnoff()
    mine.sleep(1)
end