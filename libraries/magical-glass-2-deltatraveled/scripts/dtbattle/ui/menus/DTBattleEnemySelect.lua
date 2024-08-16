local DTBattleEnemySelect, super = Class(LightBattleEnemySelect, "DTBattleEnemySelect")

function DTBattleEnemySelect:init(x, y)
    super.init(self, x, y, true)

    self.font = Assets.getFont("main")
end

function DTBattleEnemySelect:createText()
    for i = 0, 2 do
        local text = DTBattleEnemySelectItem(0, i * 32)
        table.insert(self.text, text)
        self:addChild(text)
    end
end

-- for when the help window gets added
function DTBattleEnemySelect:refreshText()
    for i, text in ipairs(self.text) do
        local enemies_per_page = LightBattleEnemySelect.ENEMIES_PER_PAGE
        local enemy_index = (i - enemies_per_page) + self.page * enemies_per_page
        local enemy = self.enemies[enemy_index]

        if enemy then
            if Game.battle.encounter.enemy_count[enemy.id] > 1 and enemy.identifier then
                text:setName(enemy.name .. " " .. enemy.identifier)
            else
                text:setName(enemy.name)
            end

            if #enemy.colors > 0 then
                text:setColors(enemy.colors)
            end

            if self.show_x_acts then
                local member = Game.battle:getCurrentlySelectingMember()
                text:setXAction(enemy.data:getXAction(member), {member.chara:getXActColor()})
            end

            text.health = enemy.health
            text.max_health = enemy.max_health

            text.mercy = enemy.mercy

            text.sparable = enemy.data:canSpare()
            text.tired = enemy.data.tired
        else
            text:clear()
        end
    end
end

function DTBattleEnemySelect:draw()
    self:drawHPAndMercyText()
    super.draw(self)
end

function DTBattleEnemySelect:drawHPAndMercyText()
    Draw.setColor(COLORS.white)
    love.graphics.setFont(self.font)
    love.graphics.print("HP", 312, -15, 0, 1, 0.75)
    love.graphics.print("MERCY", 402, -15, 0, 1, 0.75)
end

return DTBattleEnemySelect