Utils.hook(Actor, "init", function(orig, self)
    orig(self)

    self.light_battle_sprite = false
    self.light_battle_width = 0
    self.light_battle_height = 0

    self.light_battle_parts = {}

    -- part id, animation speed
    -- should call the play function on the part whenever this actor speaks
    self.talk_parts = {}
end)

Utils.hook(Actor, "getWidth", function(orig, self)
    if self.light_battle_sprite and (Game.state == "BATTLE" and MagicalGlass:getCurrentBattleSystem() == "undertale") then
        return self.light_battle_width or self.width
    else
        return self.width
    end
end)

Utils.hook(Actor, "getHeight", function(orig, self)
    if self.light_battle_sprite and (Game.state == "BATTLE" and MagicalGlass:getCurrentBattleSystem() == "undertale") then
        return self.light_battle_height or self.height
    else
        return self.height
    end
end)

Utils.hook(Actor, "hasTalkPart", function(orig, self, part)
    return self.talk_parts[part] ~= nil
end)

Utils.hook(Actor, "getTalkPartSpeed", function(orig, self, part)
    return self.talk_parts[part] or 0.2
end)

Utils.hook(Actor, "addLightBattlerPart", function(orig, self, id, create, parent_id, init, update, draw)
    self.light_battle_parts[id] = {}
    self.light_battle_parts[id]._create     = create
    self.light_battle_parts[id].__parent_id = parent_id
    self.light_battle_parts[id]._init       = init
    self.light_battle_parts[id]._update     = update
    self.light_battle_parts[id]._draw       = draw
end)

Utils.hook(Actor, "getLightBattlerPart", function(orig, self, id)
    return self.light_battle_parts[id]
end)

Utils.hook(Actor, "createLightBattleSprite", function(orig, self)
    return LightEnemySprite(self)
end)