local DTBattleEnemySelectItem, super = Class(Object, "DTBattleEnemySelectItem")

function DTBattleEnemySelectItem:init(x, y, options)
    super.init(self, x, y)

    options = options or {}

    self.name = DynamicGradientText("", 0, 0, {font = options["name_font"] or "main_mono"})
    self.name.debug_rect = {0, 0, 0, 0}
    self:addChild(self.name)

    -- todo: comments (hell since they get offsets)

    -- deltatravelerify
    --self.shake = options["shake"] or MagicalGlass.light_battle_text_shake
    self.shake = true
    self.shake_power = options["shake_power"] or 1

    self.gauge_font = Assets.getFont("battlehud")

    self.spare_star = Assets.getTexture("ui/battle/sparestar")
    self.tired_mark = Assets.getTexture("ui/battle/tiredmark")

    self.health = nil
    self.max_health = nil

    self.mercy = nil

    self.sparable = nil
    self.tired = nil
end

function DTBattleEnemySelectItem:getDebugRectangle()
    return {0, 0, SCREEN_WIDTH, 32}
end

function DTBattleEnemySelectItem:setName(name)
    name = "* " .. name

    if self.shake then
        self.name:setText("[ut_shake:"..self.shake_power.."]"..name)
    else
        self.name:setText(name)
    end
end

function DTBattleEnemySelectItem:setColors(colors)
    if #colors > 1 then
        self.name:setGradientColors(colors)
    else
        self.name:setColor(Utils.unpackColor(colors[1]))
    end
end

function DTBattleEnemySelectItem:clear()
    self.name:setText("")

    self.health = nil
    self.max_health = nil

    self.mercy = nil

    self.sparable = nil
    self.tired = nil
end

function DTBattleEnemySelectItem:draw()
    if self.health then
        self:drawHPGauge(312, 11)
    end
    if self.mercy then
        self:drawMercyGauge(402, 11)
    end

    self:drawIcons()

    super.draw(self)
end

function DTBattleEnemySelectItem:drawHPGauge(x, y)
    local gauge_width = 75
    local health_percent = (self.health / self.max_health) * gauge_width

    Draw.setColor(COLORS.red)
    Draw.rectangle("fill", x, y, gauge_width, 17)
    Draw.setColor(COLORS.lime)
    Draw.rectangle("fill", x, y, health_percent, 17)

    Draw.setColor(COLORS.black)
    love.graphics.setFont(self.gauge_font)
    love.graphics.printf(((self.health / self.max_health) * 100) .. "%", x + 2 + 1, 10 + 1, gauge_width, "center")
    Draw.setColor(COLORS.white)
    love.graphics.printf(((self.health / self.max_health) * 100) .. "%", x + 2, 10, gauge_width, "center")
end

function DTBattleEnemySelectItem:drawMercyGauge(x, y)
    local gauge_width = 75
    local mercy_percent = (self.mercy / 100) * gauge_width

    Draw.setColor(1, 94/255, 27/255)
    Draw.rectangle("fill", x, y, gauge_width, 17)
    Draw.setColor(COLORS.yellow)
    Draw.rectangle("fill", x, y, mercy_percent, 17)

    Draw.setColor(COLORS.black)
    love.graphics.setFont(self.gauge_font)
    love.graphics.printf(self.mercy .. "%", x + 2 + 1, 10 + 1, gauge_width, "center")
    Draw.setColor(142/255, 12/255, 0)
    love.graphics.printf(self.mercy .. "%", x + 2, 10, gauge_width, "center")
end

function DTBattleEnemySelectItem:drawIcons()
    Draw.setColor(COLORS.white)
    local x = self.name:getTextWidth()
    if self.sparable then
        Draw.draw(self.spare_star, x + 21, 8)
    end
    if self.tired then
        Draw.draw(self.tired_mark, x + 41, 8)
    end
end

return DTBattleEnemySelectItem