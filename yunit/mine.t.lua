local yMine = require "yunit.mine"

 function mine_not_boom_if_deactivated()
    local mine = Mine()
    mine:setTimer(1)
    mine:turnoff()
    yMine.sleep(1)
end