local burnt_pan, super = Class(LightEquipItem, "mg_item/burnt_pan")

function burnt_pan:init()
    super.init(self)

    -- Display name
    self.name = "Burnt Pan"

    -- Item type (item, key, weapon, armor)
    self.type = "weapon"
    -- Whether this item is for the light world
    self.light = true

    -- Item description text (unused by light items outside of debug menu)
    self.description = "Damage is rather consistent.\nConsumable items heal 4 more HP."

    -- Light world check text
    self.check = "Weapon AT 10\n* Damage is rather consistent.\n* Consumable items heal 4 more HP."

    -- Default shop sell price
    self.sell_price = 100
    -- Whether the item can be sold
    self.can_sell = true

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    self.bonuses = {
        attack = 10
    }

    self.heal_bonus = 4

    self.bolt_count = 4
    self.bolt_speed = 10
    self.bolt_speed_variance = nil
    self.bolt_start = -80
    self.bolt_miss_threshold = 2
    self.bolt_direction = "left"

    self.multibolt_variance = {{0, 25, 50}, {100, 125, 150}, {200}}

    self.attack_sound = "frypan"
end

function burnt_pan:onLightBattleAttack(battler, enemy, damage, stretch, attack, crit)
    local after_func = function()
        Game.battle:finishActionBy(battler)
    end

    local color = COLORS.white
    if crit then
        color = {1, 1, 130/255, 1}
    end

    local x, y = enemy:getRelativePos(enemy.width / 2, enemy.height / 2)
    local anim = BurntPanAnim(x, y, crit, {sound = self:getAttackSound(), after = after_func, color = color})
    Game.battle:addChild(anim)

    return false, damage
end

return burnt_pan