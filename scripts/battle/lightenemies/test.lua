local test, super = Class(LightEnemyBattler)

function test:init()
    super.init(self)

    self.name = "test"
    self:setActor("dummy_ut")

    self:registerAct("a", nil, {"susie"})
    self:registerAct("b", nil)
    self:registerAct("c", nil)
    self:registerAct("d", nil)
    self:registerAct("e", nil)
    self:registerAct("f", nil)

    self.exp = 200

    self.text = {
        "* h"
    }

    self.waves = {
        "basic"
    }

    self.dialogue = {
        "Board the platforms"
    }

    self.flip_dialogue = true
end

function test:onAct(battler, name)
    if name == "hi" then
        self:addMercy(100)
        return "* hi"
    elseif name == "Standard" then
        self:addMercy(50)
        return "* Standard"
    end

    return super.onAct(self, battler, name)
end

return test