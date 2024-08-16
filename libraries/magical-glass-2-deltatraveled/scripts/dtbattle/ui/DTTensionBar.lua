local DTTensionBar, super = Class(Object, "DTTensionBar")

function DTTensionBar:init(x, y)
    super.init(self, x or -25, y or 40)

    self.layer = BATTLE_LAYERS["ui"] - 1
    self.parallax_y = 0

    self.fill_tex = Assets.getTexture("ui/dtbattle/tp_bar_fill")
    self.outline_tex = Assets.getTexture("ui/dtbattle/tp_bar_outline")

    self.fill_width = self.fill_tex:getWidth()
    self.fill_height = self.fill_tex:getHeight()
    self.width = self.outline_tex:getWidth()
    self.height = self.outline_tex:getHeight()

    self.tp_font = Assets.getFont("namelv", 24)
    self.font = Assets.getFont("main")

    self.fill_amount = 0
    self.tension_preview = 0

    self.maxed = false

    self.tween = false
end

function DTTensionBar:getTension250()
    return self:getPercentageFor(Game:getTension()) * 250
end

function DTTensionBar:setTensionPreview(amount)
    self.tension_preview = amount
end

function DTTensionBar:getPercentageFor(variable)
    return variable / Game:getMaxTension()
end

function DTTensionBar:getPercentageFor250(variable)
    return variable / 250
end

function DTTensionBar:processTension()
    if not Utils.roughEqual(self.fill_amount, self:getTension250()) then
        if self.tween then Game.battle.timer:cancel(self.tween) end
        self.tween = Game.battle.timer:tween(9/30, self, {fill_amount = self:getTension250()}, "out-expo")
    end
    self.maxed = Game:getTension() >= Game:getMaxTension()
end

function DTTensionBar:update()
    self:processTension()
    super.update(self)
end

function DTTensionBar:draw()
    Draw.setColor(COLORS.white)
    Draw.draw(self.outline_tex, 0, 0)

    love.graphics.setFont(self.tp_font)
    Draw.setColor(COLORS.black)
    love.graphics.print("T", -20 + 1, 0)
    love.graphics.print("P", -20 + 1, 21)
    Draw.setColor(COLORS.white)
    love.graphics.print("T", -20, 0)
    love.graphics.print("P", -20, 21)

    self:drawBack()
    self:drawFill()
    self:drawText()

    super.draw(self)
end

function DTTensionBar:drawBack()
    local w, h = self.fill_width, self.fill_height
    Draw.setColor(PALETTE["tension_back"])
    Draw.pushScissor()
    Draw.scissorPoints(0, 0, w, h - (self:getPercentageFor250(self.fill_amount) * h) + 1)
    Draw.draw(self.fill_tex, 0, 0)
    Draw.popScissor()
end

function DTTensionBar:drawFill()
    local w, h = self.fill_width, self.fill_height

    Draw.setColor(PALETTE["tension_fill"])
    if (self.maxed) then
        Draw.setColor(COLORS.yellow)
    end
    Draw.pushScissor()
    Draw.scissorPoints(0, h - (self:getPercentageFor250(self.fill_amount) * h) + 1, w, h)
    Draw.draw(self.fill_tex, 0, 0)
    Draw.popScissor()
end

function DTTensionBar:drawText()
    love.graphics.setFont(self.font)
    if not self.maxed then
        Draw.setColor(COLORS.white)
        local tp = math.floor(Game:getTension())
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf(tostring(tp) .. "%", self.x - 38, self.height - 4, 50, "center")
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(tostring(tp) .. "%", self.x - 39, self.height - 5, 50, "center")
    else
        love.graphics.setColor(COLORS.black)
        love.graphics.print("MAX", self.x - 36, self.height - 4)
        Draw.setColor(COLORS.yellow)
        love.graphics.print("MAX", self.x - 37, self.height - 5)
    end
end

return DTTensionBar