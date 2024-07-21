local bandage, super = Class(LightEquipItem, "mg_item/bandage")

function bandage:init()
    super.init(self)

    -- Display name
    self.name = "Bandage"

    -- Item type (item, key, weapon, armor)
    self.type = "armor"
    -- Whether this item is for the light world
    self.light = true

    -- Default shop sell price
    self.sell_price = 150
    -- Whether the item can be sold
    self.can_sell = true

    self.flee_bonus = 100

    -- Item description text (unused by light items outside of debug menu)
    self.description = "It has already been used several times."

    -- Light world check text
    self.check = "Heals 10 HP\n* It has already been used\nseveral times."

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    self.swap_equip = false
end

function bandage:onWorldUse(target)
    Assets.stopAndPlaySound("power")
    local heal_amount = self:applyWorldHealBonuses(10)
    Game.world:heal(target, heal_amount, "* "..target:getNameOrYou().." re-applied the bandage.", self)
    return true
end

function bandage:getLightWorldHealingText(target, amount, maxed)
    if target then
        if self.target == "ally" then
            maxed = target:getHealth() >= target:getStat("health")
        end
    end
    local message
    if target.id == Game.party[1].id and maxed then
        message = "* Your HP was maxed out."
    elseif maxed then
        message = "* " .. target:getName() .. "'s HP was maxed out."
    else
        message = "* " .. target:getNameOrYou() .. " recovered " .. amount .. " HP!"
    end
    return message
end

function bandage:getLightBattleText(user, target, amount)
    return "* You re-applied the bandage.\n" .. self:getLightBattleHealingText(user, target, amount)
end

function bandage:onLightBattleUse(user, target)
    Assets.stopAndPlaySound("power")
    local heal_amount = self:applyBattleHealBonuses(user, 10)
    target:heal(heal_amount)
    Game.battle:battleText(self:getLightBattleText(user, target, heal_amount))
end

function bandage:getLightBattleHealingText(user, target, amount)
    local maxed
    if target then
        if self.target == "ally" then
            maxed = target.chara:getHealth() >= target.chara:getStat("health")
        elseif self.target == "enemy" then
            maxed = target.health >= target.max_health
        end
    end

    local message
    if self.target == "ally" then
        if target.chara.id == Game.battle.party[1].chara.id and maxed then
            message = "* Your HP was maxed out."
        elseif maxed then
            message = "* " .. target.chara:getName() .. "'s HP was maxed out."
        else
            message = "* " .. target.chara:getNameOrYou() .. " recovered " .. amount .. " HP!"
        end
    end
    return message
end

return bandage