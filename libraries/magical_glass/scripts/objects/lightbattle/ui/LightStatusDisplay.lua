local LightBattleStatusDisplay, super = Class(Object, "LightBattleStatusDisplay")

function LightBattleStatusDisplay:init(x, y, battler)
    super.init(self, x, y)

    self.battler = battler

    self.font = Assets.getFont("namelv", 24)
    self.hp_texture = Assets.getTexture("ui/lightbattle/hp")

    self.hp_gauge_limit = Kristal.getLibConfig("magical-glass", "lightBattleHPGaugeLimit")
end

function LightBattleStatusDisplay:drawStatus()
    local name = self.battler.chara:getName()
    local level = Game:isLight() and self.battler.chara:getLightLV() or self.battler.chara:getLevel()

    local current_health = self.battler.chara:getHealth()
    local max_health = self.battler.chara:getStat("health")

    local current_amount = current_health * 1.25
    local max_amount = max_health * 1.25

    love.graphics.setFont(self.font)
    Draw.setColor(COLORS.white)

    love.graphics.print(name .. "   LV " .. level, x, y)

    Draw.draw(self.hp_texture, 214, 5)
    self:drawHPGauge(245, 0, current_amount, max_amount)

    self:drawHPText((245 + max_amount) + 14, 0, current_health, max_health)
end

function LightBattleStatusDisplay:drawHPGauge(x, y, current_amount, max_amount)
    if self.hp_gauge_limit then
        current_amount = Utils.clamp(current_amount, 0, self.hp_gauge_limit)
        max_amount = Utils.clamp(max_amount, 0, self.hp_gauge_limit)
    end

    Draw.setColor(MagicalGlass.PALETTE["hp_back"])
    Draw.rectangle("fill", x, y, max_amount, 21)
    Draw.setColor(MagicalGlass.PALETTE["hp"])
    Draw.rectangle("fill", x, y, current_amount, 21)
end

function LightBattleStatusDisplay:drawHPText(x, y, current_health, max_health)
    if max_health < 10 and max_health >= 0 then
        max_health = "0" .. tostring(max_health)
    end

    if current_health < 10 and current_health >= 0 then
        current_health = "0" .. tostring(current_health)
    end

    local color = COLORS.white
--[[     if not self.battler.is_down then
        if Game.battle:hasAction(self.battler) and Game.battle:getActionBy(self.battler).action == "DEFEND" then
            color = COLORS.aqua
        end
    end ]]

    Draw.setColor(color)
    love.graphics.print(current_health .. " / " .. max_health, x, y)
end

function LightBattleStatusDisplay:draw()
    self:drawStatus()

    super.draw(self)
end

return LightBattleStatusDisplay