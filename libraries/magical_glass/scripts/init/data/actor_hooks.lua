Utils.hook(Actor, "init", function(orig, self)
    orig(self)

    self.light_enemy_sprite = false

    self.light_enemy_parts = {}
    self.light_enemy_width = 0
    self.light_enemy_height = 0
end)

Utils.hook(Actor, "getLightEnemyWidth", function(orig, self)
    return self.light_enemy_width
end)

Utils.hook(Actor, "getLightEnemyHeight", function(orig, self)
    return self.light_enemy_height
end)

Utils.hook(Actor, "onLightEnemySpriteInit", function(orig, self, sprite) end)

Utils.hook(Actor, "preResetLightEnemySprite", function(orig, self, sprite) end)
Utils.hook(Actor, "onResetLightEnemySprite", function(orig, self, sprite) end)

Utils.hook(Actor, "preLightEnemySpriteUpdate", function(orig, self, sprite) end)
Utils.hook(Actor, "onLightEnemySpriteUpdate", function(orig, self, sprite) end)

Utils.hook(Actor, "preLightEnemySpriteDraw", function(orig, self, sprite) end)
Utils.hook(Actor, "onLightEnemySpriteDraw", function(orig, self, sprite) end)

Utils.hook(Actor, "preLightEnemySet", function(orig, self, sprite, overlay, texture, keep_anim) end)
Utils.hook(Actor, "onLightEnemySet", function(orig, self, sprite, overlay, texture, keep_anim) end)
Utils.hook(Actor, "preLightEnemySetAnim", function(orig, self, sprite, overlay, anim, callback) end)
Utils.hook(Actor, "onLightEnemySetAnim", function(orig, self, sprite, overlay, anim, callback) end)
Utils.hook(Actor, "preLightEnemySetSprite", function(orig, self, sprite, overlay, texture, keep_anim) end)
Utils.hook(Actor, "onLightEnemySetSprite", function(orig, self, sprite, overlay, texture, keep_anim) end)
Utils.hook(Actor, "preLightEnemySetAnim", function(orig, self, sprite, overlay, anim, callback) end)
Utils.hook(Actor, "onLightEnemySetAnim", function(orig, self, sprite, overlay, anim, callback) end)

Utils.hook(Actor, "addLightEnemyPart", function(orig, self, id, ...)
    local varg = {...}
    local real_args = {}
    for k,v in pairs(varg) do
        for a,b in pairs(v) do
            real_args[a] = b
        end
    end
    real_args.functions = varg.functions or {}
    self.light_enemy_parts[id] = {}
    self.light_enemy_parts[id]._create     = real_args.create
    self.light_enemy_parts[id]._offset     = real_args.offset
    self.light_enemy_parts[id]._init       = real_args.functions["init"]   or function() end
    self.light_enemy_parts[id]._update     = real_args.functions["update"] or function() end
    self.light_enemy_parts[id]._draw       = real_args.functions["draw"]   or function() end
    self.light_enemy_parts[id]._extra_func = real_args.extra_func or {}
    self.light_enemy_parts[id].__parent_id = real_args.parent_id

    print(self.light_enemy_parts[id]._create)
end)

Utils.hook(Actor, "createLightEnemySprite", function(orig, self)
    return LightEnemySprite(self)
end)