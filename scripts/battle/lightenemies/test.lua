local test, super = Class(LightEnemyBattler)

function test:init()
    super.init(self)

    self.name = "test"
    self:setActor("dummy")
end

return test