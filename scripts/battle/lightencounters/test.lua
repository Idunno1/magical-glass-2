local test, super = Class(LightEncounter)

function test:init()
    super.init(self)

    self:addEnemy("test")
end

return test