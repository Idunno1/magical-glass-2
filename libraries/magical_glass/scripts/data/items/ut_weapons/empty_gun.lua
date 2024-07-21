local empty_gun, super = Class(LightEquipItem, "mg_item/empty_gun")

function empty_gun:init()
    super.init(self)

    -- Display name
    self.name = "Empty Gun"

    -- Item type (item, key, weapon, armor)
    self.type = "weapon"
    -- Whether this item is for the light world
    self.light = true

    -- Shop description
    self.shop = "Bullets NOT\nincluded."
    -- Default shop price (sell price is halved)
    self.price = 350
    -- Default shop sell price
    self.sell_price = 100
    -- Whether the item can be sold
    self.can_sell = true

    -- Item description text (unused by light items outside of debug menu)
    self.description = "An antique revolver.\nIt has no ammo."

    -- Light world check text
    self.check = {
        "Weapon AT 12\n* An antique revolver.[wait:10]\n* It has no ammo.",
        "* Must be used precisely, or\ndamage will be low."
    }

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    self.bonuses = {
        attack = 12
    }

    self.bolt_count = 4
    self.bolt_speed = 15
    self.bolt_speed_variance = nil
    self.bolt_start = 120
    self.bolt_direction = "right"

    self.multibolt_variance = {{180, 210, 240}, {300, 330, 360}, {400, 430, 460}}

    self.attack_sound = "gunshot"
end

function empty_gun:onLightBattleAttack(battler, enemy, damage, stretch, attack, crit)
    local after_func = function()
        Game.battle:finishActionBy(battler)
    end

    local color = COLORS.white
    if crit then
        color = {1, 1, 130/255, 1}
    end

    local x, y = enemy:getRelativePos(enemy.width / 2, enemy.height / 2)
    local anim = EmptyGunAnim(x, y, crit, {sound = self:getAttackSound(), after = after_func, color = color})
    Game.battle:addChild(anim)

    return false
end

return empty_gun