local ballet_shoes, super = Class(LightEquipItem, "mg_item/ballet_shoes")

function ballet_shoes:init()
    super.init(self)

    -- Display name
    self.name = "Ballet Shoes"
    self.short_name = "BallShoes"
    self.serious_name = "Shoes"

    -- Item type (item, key, weapon, armor)
    self.type = "weapon"
    -- Whether this item is for the light world
    self.light = true

    -- Default shop sell price
    self.sell_price = 80
    -- Whether the item can be sold
    self.can_sell = true

    -- Item description text (unused by light items outside of debug menu)
    self.description = "These used shoes make you feel extra dangerous."

    -- Light world check text
    self.check = "Weapon AT 7\n* These used shoes make you feel\nextra dangerous."

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    self.bonuses = {
        attack = 7
    }

    self.bolt_count = 3
    self.bolt_speed = 10
    self.bolt_speed_variance = nil
    self.bolt_start = -90
    self.bolt_miss_threshold = 2
    self.bolt_direction = "right"

    self.multibolt_variance = {{0, 25, 50}, {100, 125, 150}}

    self.attack_sound = "punchstrong"
end

function ballet_shoes:showEquipText(target)
    Game.world:showText("* " .. target:getNameOrYou() .. " equipped Ballet Shoes.")
end

function ballet_shoes:getLightBattleText(user, target)
    return "* " .. target.chara:getNameOrYou() .. " equipped Ballet Shoes."
end

function ballet_shoes:onLightBattleAttack(battler, enemy, damage, stretch, attack, crit)
    local after_func = function()
        Game.battle:finishActionBy(battler)
    end

    local color = COLORS.white
    if crit then
        color = {1, 1, 130/255, 1}
    end

    local x, y = enemy:getRelativePos(enemy.width / 2, enemy.height / 2)
    local anim = HyperAttackAnim(x, y, nil, {sound = self:getAttackSound(), crit = crit, after = after_func, color = color})
    Game.battle:addChild(anim)

    return false
end

return ballet_shoes