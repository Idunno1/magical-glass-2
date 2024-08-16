Utils.hook(Registry.getPartyMember("noelle"), "init", function(orig, self)
    orig(self)
    self.dt_battle_offset = -2
end)