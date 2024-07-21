local torn_notebook, super = Class(LightEquipItem, "mg_item/torn_notebook")

function torn_notebook:init()
    super.init(self)

    -- Display name
    self.name = "Torn Notebook"
    self.short_name = "TorNotbo"
    self.serious_name = "Notebook"

    -- Item type (item, key, weapon, armor)
    self.type = "weapon"
    -- Whether this item is for the light world
    self.light = true

    -- Shop description
    self.shop = "Invincible\nlonger"
    -- Default shop price (sell price is halved)
    self.price = 55
    -- Default shop sell price
    self.sell_price = 50
    -- Whether the item can be sold
    self.can_sell = true

    -- Item description text (unused by light items outside of debug menu)
    self.description = "Contains illegible scrawls."

    -- Light world check text
    self.check = {
        "Weapon AT 2\n* Contains illegible scrawls.\n* Increases INV by 6.",
        "* (After you get hurt by an\nattack,[wait:10] you stay invulnerable\nfor longer.)" -- doesn't show up in UT???
    }

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    self.bonuses = {
        attack = 2
    }

    self.bolt_count = 2
    self.bolt_speed = 10
    self.bolt_speed_variance = nil
    self.bolt_start = {-50, -25} 
    self.bolt_miss_threshold = 2
    self.bolt_direction = "left"
    self.multibolt_variance = {{0, 25, 50}}

    self.inv_bonus = 15/30

    self.attack_sound = "bookspin"
    self.attack_pitch = 0.9
end

function torn_notebook:onLightBattleAttack(battler, enemy, damage, stretch, attack, crit)
    local after_func = function()
        Game.battle:finishActionBy(battler)
    end

    local color = COLORS.white
    if crit then
        color = {1, 1, 130/255, 1}
    end

    local x, y = enemy:getRelativePos(enemy.width / 2, enemy.height / 2)
    local anim = TornNotebookAnim(x, y, crit, {sound = self:getAttackSound(), after = after_func, color = color})
    Game.battle:addChild(anim)

    return false
end

return torn_notebook