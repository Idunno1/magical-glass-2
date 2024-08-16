local DTStatusBox, super = Class(Object, "DTStatusBox")

function DTStatusBox:init(x, y, index, battler)
    super.init(self, x, y, 180, 45)

    self.draw_children_below = 0
    self.cutout_bottom = -2

    self.index = index
    self.battler = battler

    self.sprite = nil

    self.display = DTStatusBoxDisplay(self)
    self:addChild(self.display)

    self.state = "CENTER"
    self.sprite_up = false

    self.down_states = {"ENEMYDIALOGUE", "DEFENDING", "DEFENDINGBEGIN"}

    self.tween = nil
    self.display_tween = nil
    self.sprite_tween = nil

    self:setActor(self.battler.actor)
end

function DTStatusBox:setActor(actor)
    if type(actor) == "string" then
        self.actor = Registry.createActor(actor)
    else
        self.actor = actor
    end

    if self.sprite then self:removeChild(self.sprite) end

    self.sprite = actor:createSprite()
    self.sprite:setPosition(self:getRelativePos(self.width/2, self.height/2, self))
    self.sprite:setScale(2)
    self.sprite:setOrigin(0.5, 0)
    self.sprite.layer = -1
    self:addChild(self.sprite)
end

function DTStatusBox:update()
    if self:shouldBeUp() then
        self:transitionUp()
    elseif self:shouldBeDown() then
        self:transitionDown()
    else
        self:transitionCenter()
    end

    if self:spriteShouldBeUp() then
        self:showSprite()
    else
        self:hideSprite()
    end

    super.update(self)
end

function DTStatusBox:shouldBeUp()
    return (Game.battle.current_selecting_index == self.index)
end

function DTStatusBox:shouldBeDown()
    return (Utils.containsValue(self.down_states, Game.battle.state))
end

function DTStatusBox:spriteShouldBeUp()
    return (self.sprite and
            self.state == "UP")
end

function DTStatusBox:battlerHasAction()
    local action = false
    if Game.battle:hasAction(self.battler) then
        action = true
    end
    for _,iaction in ipairs(Game.battle.current_actions) do
        if iaction.party and Utils.containsValue(iaction.party, self.battler.chara.id) then
            action = true
        end
    end
    return action
end

function DTStatusBox:transitionUp()
    if self.state ~= "UP" then
        self:cancelTweens()
        self.tween = Game.battle.timer:tween(9/30, self, {y = self.init_y - 8}, "out-expo")
        self.display_tween = Game.battle.timer:tween(9/30, self.display, {y = self.display.init_y}, "out-expo")
        self.state = "UP"
    end
end

function DTStatusBox:transitionCenter()
    if self.state ~= "CENTER" then
        self:cancelTweens()
        self.tween = Game.battle.timer:tween(9/30, self, {y = self.init_y}, "out-expo")
        self.display_tween = Game.battle.timer:tween(9/30, self.display, {y = self.display.init_y}, "out-expo")
        self.state = "CENTER"
    end
end

function DTStatusBox:transitionDown()
    if self.state ~= "DOWN" then
        self:cancelTweens()
        self.tween = Game.battle.timer:tween(8/30, self, {y = self.init_y + 125}, "out-expo")
        self.display_tween = Game.battle.timer:tween(9/30, self.display, {y = self.display.init_y + 9}, "out-expo")
        self.state = "DOWN"
    end
end

function DTStatusBox:showSprite()
    if not self.sprite_up then
        if self.sprite_tween then Game.battle.timer:cancel(self.sprite_tween) end
        local offset = self.battler.chara:getDTBattleOffset()
        local target_y = Utils.round(self.sprite.init_y - ((self.battler.actor:getHeight() * 1.2) + offset))
        self.sprite_tween = Game.battle.timer:tween(11/30, self.sprite, {y = target_y}, "out-expo")
        self.sprite_up = true
    end
end

function DTStatusBox:hideSprite()
    if self.sprite_up then
        if self.sprite_tween then Game.battle.timer:cancel(self.sprite_tween) end
        self.sprite_tween = Game.battle.timer:tween(2/30, self.sprite, {y = self.sprite.init_y}, "out-expo")
        self.sprite_up = false
    end
end

function DTStatusBox:cancelTweens()
    if self.tween then Game.battle.timer:cancel(self.tween) end
    if self.display_tween then Game.battle.timer:cancel(self.display_tween) end
end

function DTStatusBox:draw()
    -- boxes are also darkened during the defending phase and the battler isn't being attacked
    -- see spinning robo's spin act or mondo mole's grab attack
    Draw.setColor(COLORS.black)
    Draw.rectangle("fill", 0, 0, self.width, self.height)

    if self.battler.is_down then
        Draw.setColor(COLORS.gray)
    else
        Draw.setColor(self.battler.chara:getLightColor())
    end
    love.graphics.setLineWidth(5)
    Draw.rectangle("line", 0, 0, self.width, self.height)

    super.draw(self)
end

return DTStatusBox