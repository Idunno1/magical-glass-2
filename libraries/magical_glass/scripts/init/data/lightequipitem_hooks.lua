Utils.hook(LightEquipItem, "init", function(orig, self)
    LightEquipItem.__super.init(self)

    self.target = "ally"

    self.equip_display_name = nil

    self.heal_bonus = 0
    self.flee_bonus = 0
    self.inv_bonus = 0

    self.bolt_count = 1

    self.bolt_speed = 11
    self.bolt_speed_variance = 2

    self.bolt_start = -16 -- number or table of where the bolt spawns. if it's a table, a value is chosen randomly
    self.multibolt_variance = 50
    self.relative_multibolt_variance = false

    self.bolt_direction = "right" -- "right", "left", or "random"

    self.attack_sprite = "effects/attack/strike"
    self.attack_sound = "laz_c"
    self.attack_pitch = 1

    self.swap_equip = true
end)

Utils.hook(LightEquipItem, "getEquipDisplayName", function(orig, self)
    if self.equip_display_name then
        return self.equip_display_name
    else
        return self:getName()
    end
end)

Utils.hook(LightEquipItem, "getBoltCount", function(orig, self)
    return self.bolt_count
end)

Utils.hook(LightEquipItem, "getBoltSpeed", function(orig, self)
    return self.bolt_speed + Utils.random(0, self:getBoltSpeedVariance(), 1)
end)

Utils.hook(LightEquipItem, "getBoltSpeedVariance", function(orig, self)
    return self.bolt_speed_variance
end)

Utils.hook(LightEquipItem, "getBoltStartOffset", function(orig, self)
    if type(self.bolt_start) == "table" then
        return Utils.pick(self.bolt_start)
    elseif type(self.bolt_start) == "number" then
        return self.bolt_start
    end
end)

Utils.hook(LightEquipItem, "getBoltDirection", function(orig, self)
    if self.bolt_direction == "random" then
        return Utils.pick({"right", "left"})
    else
        return self.bolt_direction
    end
end)

Utils.hook(LightEquipItem, "getMultiboltVariance", function(orig, self)
    return self.multibolt_variance
end)

Utils.hook(LightEquipItem, "getAttackSprite", function(orig, self)
    return self.attack_sprite
end)

Utils.hook(LightEquipItem, "getAttackSound", function(orig, self)
    return self.attack_sound
end)

Utils.hook(LightEquipItem, "getAttackPitch", function(orig, self)
    return self.attack_pitch
end)

Utils.hook(LightEquipItem, "applyHealBonus", function(orig, self, amount) return amount or 0 + self.heal_bonus end)
Utils.hook(LightEquipItem, "applyFleeBonus", function(orig, self, amount) return amount or 0 + self.flee_bonus end)
Utils.hook(LightEquipItem, "applyInvBonus", function(orig, self, amount) return amount or 0 + self.inv_bonus end)

Utils.hook(LightEquipItem, "onWorldUse", function(orig, self, target)
    self:playWorldUseSound(target)
    local replacing = nil
    if self.type == "weapon" then
        if target:getWeapon() then
            replacing = target:getWeapon()
            replacing:onUnequip(target, self)
            Game.inventory:replaceItem(self, replacing)
        end
        target:setWeapon(self)
    elseif self.type == "armor" then
        if target:getArmor(1) then
            replacing = target:getArmor(1)
            replacing:onUnequip(target, self)
            Game.inventory:replaceItem(self, replacing)
        end
        target:setArmor(1, self)
    else
        error("LightEquipItem "..self.id.." invalid type: "..self.type)
    end

    self:onEquip(target, replacing)
    self:showEquipText(target)
    return false
end)

Utils.hook(LightEquipItem, "showEquipText", function(orig, self, target)
    Game.world:showText("* " .. target:getNameOrYou() .. " equipped the " .. self:getName() .. ".")
end)

Utils.hook(LightEquipItem, "onLightBattleNextTurn", function(orig, self, battler, turn) end)

Utils.hook(LightEquipItem, "onLightBattleUse", function(orig, self, user, target)
    self:playLightBattleUseSound(user, target)
    Game.battle:battleText(self:getLightBattleText(user, target))
end)

Utils.hook(LightEquipItem, "getLightBattleText", function(orig, self, user, target)
    return "* " .. target.chara:getNameOrYou() .. " equipped the " .. self:getUseName() .. "."
end)

Utils.hook(LightEquipItem, "onLightBattleBoltHit", function(orig, self, battler, enemy, attack) end)
Utils.hook(LightEquipItem, "onLightBattleBoltMiss", function(orig, self, battler, enemy, attack) end)

Utils.hook(LightEquipItem, "onLightBattleAttack", function(orig, self, battler, enemy, damage, stretch, attack, crit)
    local after_func = function()
        Game.battle:finishActionBy(battler)
    end

    local x, y = enemy:getRelativePos((enemy.width / 2) - 5, (enemy.height / 2) - 5)
    local anim = BasicAttackAnim(x, y, nil, stretch, {sound = self:getAttackSound(), after = after_func})
    Game.battle:addChild(anim)

    -- should finish action automatically, damage override, don't damage enemy when the attack ends
    return false
end)

Utils.hook(LightEquipItem, "onLightBattleMiss", function(orig, self, battler, enemy) end)
    -- should finish action automatically, don't hit for 0 damage when the attack ends

Utils.hook(LightEquipItem, "playWorldUseSound", function(orig, self, target)
    Assets.playSound("item")
end)

Utils.hook(LightEquipItem, "playLightBattleUseSound", function(orig, self, user, target)
    Assets.playSound("item")
end)