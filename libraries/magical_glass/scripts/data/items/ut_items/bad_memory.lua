local item, super = Class(HealItem, "mg_item/bad_memory")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Bad Memory"
    self.short_name = "BadMemory"

    -- Item type (item, key, weapon, armor)
    self.type = "item"
    -- Whether this item is for the light world
    self.light = true

    -- Default shop sell price
    self.sell_price = 300
    -- Whether the item can be sold
    self.can_sell = true

    -- Item description text (unused by light items outside of debug menu)
    self.description = "?????"

    -- Light world check text
    self.check = "Hurts 1 HP\n* ?????"

    -- Consumable target mode (ally, party, enemy, enemies, or none)
    self.target = "ally"
    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil
    -- Will this item be instantly consumed in battles?
    self.instant = false
end

function item:getWorldUseSound(target)
    if target:getHealth() > 3 then
        return "hurt"
    else
        return "power"
    end
end

function item:getLightBattleUseSound(user, target)
    if target.chara:getHealth() > 3 then
        return "hurt"
    else
        return "power"
    end
end

function item:getWorldUseText(target)
    if target:getHealth() > 3 then
        return "* "..target:getNameOrYou().." consume the Bad Memory.\n* "..target:getNameOrYou().." lost 1HP."
    else
        local heal_text
        if target.id == Game.party[1].id then
            heal_text = "Your HP was maxed out."
        else
            heal_text = target:getNameOrYou().."'s HP was maxed out."
        end
        return "* "..target:getNameOrYou().." consume the Bad Memory.\n" .. heal_text
    end
end

function item:onWorldUse(target)
    self:playWorldUseSound(target)
    Game.world:showText(self:getWorldUseText(target))

    if target:getHealth() > 3 then
        target:setHealth(target:getHealth() - 1)
    else
        target:setHealth(target:getStat("health"))
    end

    return true
end

function item:getLightBattleText(user, target)
    if target.chara:getHealth() > 3 then
        return "* "..target.chara:getNameOrYou().." consume the Bad Memory.\n* "..target.chara:getNameOrYou().." lost 1HP."
    else
        local heal_text
        if target.chara.id == Game.battle.party[1].chara.id then
            heal_text = "Your HP was maxed out."
        else
            heal_text = target.chara:getNameOrYou().."'s HP was maxed out."
        end
        return "* "..target.chara:getNameOrYou().." consume the Bad Memory.\n" .. heal_text
    end
end

function item:onLightBattleUse(user, target)
    if target.chara:getHealth() > 3 then
        target:heal(target.chara:getStat("health"), false)
    else
        target:removeHealth(1)
    end

    self:playLightBattleUseSound(user, target)
    Game.battle:battleText(self:getLightBattleText(user, target))
    return true
end

return item