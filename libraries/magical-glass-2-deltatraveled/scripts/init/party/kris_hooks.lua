Utils.hook(Registry.getPartyMember("kris"), "init", function(orig, self)
    orig(self)
    self.dt_battle_offset = -1
end)