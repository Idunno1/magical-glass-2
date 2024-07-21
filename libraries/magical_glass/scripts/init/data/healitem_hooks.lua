Utils.hook(HealItem, "init", function(orig, self)
    orig(self)

    self.use_method = "use"
    self.use_method_other = "uses"

    self.swallow_sound = true
    self.use_sound = "power"
end)

Utils.hook(HealItem, "getUseMethod", function(orig, self, target)
    if type(target) == "string" then
        if target == "other" and self.use_method_other then
            return self.use_method_other
        end
    elseif isClass(target) then
        if (not target.you and self.use_method_other and self.target ~= "party") then
            return self.use_method_other
        end
    end
    return self.use_method
end)

Utils.hook(HealItem, "onWorldUse", function(orig, self, target)
    local text = self:getWorldUseText(target)
    if self.target == "ally" then
        self:playWorldUseSound(target)
        local amount = self:getWorldHealAmount(target.id)
        amount = self:applyWorldHealBonuses(amount)
        Game.world:heal(target, amount, text, self)
        return true
    elseif self.target == "party" then
        self:playWorldUseSound(target)
        for _,party_member in ipairs(target) do
            local amount = self:getWorldHealAmount(party_member.id)
            amount = self:applyWorldHealBonuses(amount)
            Game.world:heal(party_member, amount, text, self)
        end
        return true
    else
        return false
    end
end)

Utils.hook(HealItem, "getWorldUseText", function(orig, self, target)
    if self.target == "ally" then
        return "* " .. target:getNameOrYou() .. " "..self:getUseMethod(target).." the " .. self:getUseName() .. "."
    elseif self.target == "party" then
        if #Game.party > 1 then
            return "* Everyone "..self:getUseMethod("other").." the " .. self:getUseName() .. "."
        else
            return "* You "..self:getUseMethod("self").." the " .. self:getUseName() .. "."
        end
    end
end)

Utils.hook(HealItem, "playWorldUseSound", function(orig, self, target)
    if self.swallow_sound then
        Game.world.timer:script(function(wait)
            Assets.stopAndPlaySound("swallow")
            wait(10/30)
            Assets.stopAndPlaySound(self.use_sound)
        end)
    else
        Assets.stopAndPlaySound(self.use_sound)
    end
end)

Utils.hook(HealItem, "onLightBattleUse", function(orig, self, user, target)
    local text = self:getLightBattleText(user, target)

    if self.target == "ally" then
        self:playLightBattleUseSound(user, target)
        local amount = self:getBattleHealAmount(target.chara.id)
        amount = self:applyBattleHealBonuses(user, amount)
        target:heal(amount)
        text = text .. "\n" .. self:getLightBattleHealingText(user, target, amount)
        Game.battle:battleText(text)
        return true
    elseif self.target == "party" then
        self:playLightBattleUseSound(user, target)
        for _,battler in ipairs(target) do
            local amount = self:getBattleHealAmount(battler.chara.id)
            amount = self:applyBattleHealBonuses(user, amount)
            battler:heal(amount)
        end
        Game.battle:battleText(text)
        return true
    elseif self.target == "enemy" then
        self:playLightBattleUseSound(user, target)
        local amount = self:getHealAmount()
        amount = self:applyBattleHealBonuses(user, amount)
        target:heal(amount)
        Game.battle:battleText(text)
        return true
    elseif self.target == "enemies" then
        self:playLightBattleUseSound(user, target)
        for _,enemy in ipairs(target) do
            local amount = self:getHealAmount()
            amount = self:applyBattleHealBonuses(user, amount)
            enemy:heal(amount)
        end
        Game.battle:battleText(text)
        return true
    else
        -- No target or enemy target (?), do nothing
        return false
    end
end)

Utils.hook(HealItem, "getLightBattleHealingText", function(orig, self, user, target, amount)
    if target then
        if self.target == "ally" then
            maxed = target.chara:getHealth() >= target.chara:getStat("health")
        end
    end

    local message
    if self.target == "ally" then
        if target.chara.you and maxed then
            message = "* Your HP was maxed out."
        elseif maxed then
            message = "* " .. target.chara:getNameOrYou() .. "'s HP was maxed out."
        else
            message = "* " .. target.chara:getNameOrYou() .. " recovered " .. amount .. " HP!"
        end
    end
    return message
end)

Utils.hook(HealItem, "playLightBattleUseSound", function(orig, self, user, target)
    if self.swallow_sound then
        Game.battle.timer:script(function(wait)
            Assets.stopAndPlaySound("swallow")
            wait(10/30)
            Assets.stopAndPlaySound(self.use_sound)
        end)
    else
        Assets.stopAndPlaySound(self.use_sound)
    end
end)