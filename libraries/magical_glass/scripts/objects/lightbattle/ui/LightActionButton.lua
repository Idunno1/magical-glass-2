local LightActionButton, super = Class(Object, "LightActionButton")

function LightActionButton:init(x, y, type)
    super.init(self, x, y)

    self.type = type

    self.tex = Assets.getTexture("ui/lightbattle/btn/" .. type)
    self.hover_tex = Assets.getTexture("ui/lightbattle/btn/" .. type .. "_h")
    self.special_tex = Assets.getTexture("ui/lightbattle/btn/" .. type .. "_a")

    self.width = self.tex:getWidth()
    self.height = self.tex:getHeight()

    self:setOriginExact(self.width / 2, 13)

    self.hovered = false
    self.selectable = true

    self.highlight = Kristal.getLibConfig("magical-glass", "action_button_flash")
end

function LightActionButton:hasSpecial()
    if self.highlight then
        if self.type == "spell" then
            if self.battler then
                local has_tired = false
                for _, enemy in ipairs(Game.battle:getActiveEnemies()) do
                    if enemy.tired then
                        has_tired = true
                        break
                    end
                end
                if has_tired then
                    local has_pacify = false
                    for _, spell in ipairs(self.battler.chara:getSpells()) do
                        if spell and spell:hasTag("spare_tired") then
                            has_pacify = true
                            break
                        end
                    end
                    return has_pacify
                end
            end
        elseif self.type == "mercy" then
            for _, enemy in ipairs(Game.battle:getActiveEnemies()) do
                if enemy.mercy >= 100 then
                    return true
                end
            end
        end
    end
    return false
end

function LightActionButton:draw()
    if self.selectable and self.hovered then
        love.graphics.draw(self.hover_tex or self.tex)
    else
        love.graphics.draw(self.tex)
        if self.selectable and self.special_tex and self:hasSpecial() then
            local r, g, b, a = self:getDrawColor()
            love.graphics.setColor(r, g, b, a * (0.4 + math.sin((Kristal.getTime() * 30) / 6) * 0.4))
            love.graphics.draw(self.special_tex)
        end
    end

    super.draw(self)
end

return LightActionButton