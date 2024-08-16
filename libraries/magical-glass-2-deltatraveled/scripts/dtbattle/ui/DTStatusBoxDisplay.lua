local DTStatusBoxDisplay, super = Class(Object, "DTStatusBoxDisplay")

function DTStatusBoxDisplay:init(box)
    super.init(self)

    self.font = Assets.getFont("namelv")

    self.box = box
    self.battler = self.box.battler
end

function DTStatusBoxDisplay:draw()
    self:drawName(3, 10)
    self:drawHPGauge(60, 12)
    self:drawHPText(109, 10)

    super.draw(self)
end

function DTStatusBoxDisplay:drawName(x, y)
    local name = self.battler.chara:getName()
    love.graphics.setFont(self.font)
    Draw.setColor(self:getNameColor())

    local offset = 0
    if #self.battler.chara:getName() > 5 then
        offset = 4
    end

    self:printOutline(name, x + offset, y)
end

function DTStatusBoxDisplay:drawHPGauge(x, y)
    local current_health = self.battler.chara:getHealth()
    local max_health = self.battler.chara:getStat("health")

    local current_width = (current_health / max_health) * 45

    local name_offset = 1
    if #self.battler.chara:getName() == 5 then
        name_offset = 7
    elseif #self.battler.chara:getName() == 6 then
        name_offset = 13
    end

    -- paletteify
    Draw.setColor(COLORS.red)
    love.graphics.rectangle("fill", x + name_offset, y, 45, 10)
    if current_width > 0 then
        Draw.setColor(COLORS.yellow)
        love.graphics.rectangle("fill", x + name_offset, y, current_width, 10)
    end
end

function DTStatusBoxDisplay:drawHPText(x, y)
    local current_health = self.battler.chara:getHealth()
    local max_health = self.battler.chara:getStat("health")

    local name_offset = 0
    if #self.battler.chara:getName() == 5 then
        name_offset = 6
    elseif #self.battler.chara:getName() == 6 then
        name_offset = 9
    end

    if current_health < 10 and current_health >= 0 then
        current_health = "0" .. tostring(current_health)
    end
    if max_health < 10 and max_health >= 0 then
        max_health = "0" .. tostring(max_health)
    end

    Draw.setColor(self:getHPTextColor())
    self:printOutline(current_health.."/"..max_health, x + name_offset, y)
end

function DTStatusBoxDisplay:getNameColor()
    if self.battler.is_down then
        return COLORS.gray
    elseif self.battler.action then
        return COLORS.yellow
    else
        return COLORS.white
    end
end

function DTStatusBoxDisplay:getHPTextColor()
    if self.battler.is_down then
        return COLORS.red
    elseif Game.battle:hasAction(self.battler) and Game.battle:getActionBy(self.battler).action == "DEFEND" then
        return COLORS.aqua
    else
        return COLORS.white
    end
end

function DTStatusBoxDisplay:printOutline(string, x, y, color, outline_color)
    Draw.setColor(outline_color or COLORS.black)
    -- vomit 2
    love.graphics.printf(string, x - 1, y + 1, 63, "center")
    love.graphics.printf(string, x + 1, y - 1, 63, "center")
    love.graphics.printf(string, x + 1, y - 1, 63, "center")
    love.graphics.printf(string, x - 1, y + 1, 63, "center")

    love.graphics.printf(string, x - 1, y - 1, 63, "center")
    love.graphics.printf(string, x + 1, y + 1, 63, "center")
    love.graphics.printf(string, x - 1, y - 1, 63, "center")
    love.graphics.printf(string, x + 1, y + 1, 63, "center")

    Draw.setColor(color or COLORS.white)
    love.graphics.printf(string, x, y, 63, "center")
end

return DTStatusBoxDisplay