local item, super = Class(HealItem, "mg_item/dream")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Dream"
    self.short_name = "LastDream"

    -- Item type (item, key, weapon, armor)
    self.type = "item"
    -- Whether this item is for the light world
    self.light = true

    self.heal_amount = 12

    -- Default shop sell price
    self.sell_price = 250
    -- Whether the item can be sold
    self.can_sell = true

    -- Item description text (unused by light items outside of debug menu)
    self.description = "The goal of \"Determination.\""

    -- Light world check text
    self.check = "Heals 12 HP\n* The goal of \"Determination.\""

    -- Consumable target mode (ally, party, enemy, enemies, or none)
    self.target = "ally"
    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil
    -- Will this item be instantly consumed in battles?
    self.instant = false
end

function item:onWorldUse(target)
    super.onWorldUse(self, target)
    Game:setFlag("mg#dream_used", true)
end

function item:getWorldUseText(target)
    if not Game:getFlag("mg#dream_used") then
        return "* Through DETERMINATION,[wait:10] the\ndream became true."
    else
        return "* The dream came true!"
    end
end

function item:onLightBattleUse(user, target)
    super.onLightBattleUse(self, user, target)
    Game:setFlag("mg#dream_used", true)
end

function item:getLightBattleText(user, target)
    if not Game:getFlag("mg#dream_used") then
        return "* Through DETERMINATION,[wait:10] the\ndream became true."
    else
        return "* The dream came true!"
    end
end

return item