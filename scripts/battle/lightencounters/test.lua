local test, super = Class(LightEncounter)

function test:init()
    super.init(self)

    self:addEnemy("test")
    self:addEnemy("test")

end

function test:onStickUse()
    return "* You stick                  \n              \n it up your ass"
end

--[[ function test:onBattleStart()
    --Game.battle:swapSoul(LightYellowSoul())
    --Game.battle:swapSoul(LightBlueSoul())
end ]]

return test