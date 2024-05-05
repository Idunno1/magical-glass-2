local LightBattleStoryStatusDisplay, super = Class(Object, "LightBattleStoryStatusDisplay")

function LightBattleStoryStatusDisplay:init(x, y, battler)
    super.init(self, x, y)

    self.battler = battler
end

return LightBattleStoryStatusDisplay