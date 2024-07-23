local test, super = Class(LightEnemyBattler)

function test:init()
    super.init(self)

    self.name = "test"
    self:setActor("dummy_ut")

    self:registerAct("Red Buster", nil, {"susie"}, 60)
    self:registerAct("dumbass", "", {"susie", "noelle"})

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
    if name == "Red Buster" then
        Game.battle:powerAct("red_buster", "kris", "susie", self)
    end

    return super.onAct(self, battler, name)
end

return test