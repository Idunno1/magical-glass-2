local butterscotch_pie, super = Class(HealItem, "mg_item/butterscotch_pie")

function butterscotch_pie:init()
    super.init(self)

    -- Display name
    self.name = "Butterscotch Pie"
    self.short_name = "ButtsPie"
    self.serious_name = "Pie"

    -- Item type (item, key, weapon, armor)
    self.type = "item"
    -- Whether this item is for the light world
    self.light = true

    -- Default shop sell price
    self.sell_price = 180
    -- Whether the item can be sold
    self.can_sell = true

    -- Item description text (unused by light items outside of debug menu)
    self.description = "Butterscotch-cinnamon pie, one slice."

    -- Light world check text
    self.check = "All HP\n* Butterscotch-cinnamon\npie,[wait:10] one slice."

    -- Consumable target mode (ally, party, enemy, enemies, or none)
    self.target = "ally"
    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil
    -- Will this item be instantly consumed in battles?
    self.instant = false
end

function butterscotch_pie:onWorldUse(target)
    self:playWorldUseSound(target)
    target:setHealth(target:getStat("health"))
    Game.world:showText(self:getLightWorldHealingText(target).."\n"..self:getLightWorldHealingText(target))
    return true
end

function butterscotch_pie:onLightBattleUse(user, target)
    self:playLightBattleUseSound(user, target)
    target.chara:setHealth(target.chara:getStat("health"))
    Game.battle:battleText(self:getLightBattleText(user, target).."\n"..self:getLightBattleHealingText(user, target))
    return true
end

return butterscotch_pie