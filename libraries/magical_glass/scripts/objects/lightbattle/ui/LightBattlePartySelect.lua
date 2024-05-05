local LightBattlePartySelect, super = Class(Object, "LightBattlePartySelect")

function LightBattlePartySelect:init()
    super.init(self)

    self.members = {}

    self.current_member = nil

    self.memory = {}
end

function LightBattlePartySelect:setup(party)

end

function LightBattlePartySelect:onKeyPressed(key)

end

return LightBattlePartySelect