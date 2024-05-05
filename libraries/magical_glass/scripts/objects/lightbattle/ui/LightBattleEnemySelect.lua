local LightBattleEnemySelect, super = Class(Object, "LightBattleEnemySelect")

function LightBattleEnemySelect:init()
    super.init(self)

    self.enemies = {}

    self.current_enemy = nil

    self.memory = {}
end

function LightBattleEnemySelect:setup(enemies)

end

function LightBattleEnemySelect:onKeyPressed(key)

end

return LightBattleEnemySelect