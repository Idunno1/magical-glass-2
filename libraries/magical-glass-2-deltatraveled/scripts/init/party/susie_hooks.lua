Utils.hook(Registry.getPartyMember("susie"), "init", function(orig, self)
    orig(self)
    self.dt_battle_offset = -7
end)