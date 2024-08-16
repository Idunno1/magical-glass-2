Utils.hook(PartyMember, "init", function(orig, self)
    orig(self)
    self.dt_hurt_color = nil

    self.dt_battle_offset = 0
end)

Utils.hook(PartyMember, "getDTHurtColor", function(orig, self)
    if self.dt_hurt_color then
        return Utils.unpackColor(self.dt_hurt_color)
    else
        return self:getDamageColor()
    end
end)

Utils.hook(PartyMember, "getDTBattleOffset", function(orig, self)
    return self.dt_battle_offset or 0
end)