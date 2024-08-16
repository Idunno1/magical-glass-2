local DTActionButton, super = Class(Object, "DTActionButton")

function DTActionButton:init(x, y, type, battler)
    super.init(self, x, y)

    self.type = type
    self.battler = battler

    self.tex = Assets.getTexture("ui/dtbattle/btn/" .. type)
    self.hover_tex = Assets.getTexture("ui/dtbattle/btn/" .. type .. "_h")

    self.width = self.tex:getWidth()
    self.height = self.tex:getHeight()

    self:setOriginExact(self.width / 2, 13)

    self.hovered = false
    self.selectable = true
end

function DTActionButton:select()
--[[     if Kristal.callEvent(MagicalGlass.EVENT.onLightBattleActionButtonSelect, self.battler, self, self.selectable) then return end
    if Game.battle.encounter:onActionButtonSelect(self.battler, self, self.selectable) then return end ]]

    if self.selectable then
        if self.type == "fight" then
            self:onFightSelected()
        elseif self.type == "act" then
            self:onActSelected()
        elseif self.type == "spell" then
            self:onSpellSelected()
        elseif self.type == "item" then
            self:onItemSelected()
        elseif self.type == "mercy" then
            self:onMercySelected()
        end
    end
end

function DTActionButton:onFightSelected()
    Game.battle:setState("ENEMYSELECT", "ATTACK")
end

function DTActionButton:onActSelected()
    Game.battle:setState("ENEMYSELECT", "ACT")
end

function DTActionButton:onSpellSelected()
    Game.battle:setState("MENUSELECT", "SPELL", {["user"] = self.battler})
end

function DTActionButton:onItemSelected()
    Game.battle:setState("MENUSELECT", "ITEM")
end

function DTActionButton:onMercySelected()
    Game.battle:setState("MENUSELECT", "MERCY")
end

function DTActionButton:draw()
    if self.hovered then
        Draw.setColor(MagicalGlassDeltatraveled:getHoveredButtonColor())
        love.graphics.draw(self.hover_tex or self.tex)
    else
        Draw.setColor(MagicalGlassDeltatraveled:getButtonColor())
        love.graphics.draw(self.tex)
    end

    super.draw(self)
end

return DTActionButton