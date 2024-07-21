local BlueSoulPlatform, super = Class(Object)

function BlueSoulPlatform:init(width)
    super.init(self, 0, 0, width, 6)

    self.layer = BATTLE_LAYERS["below_soul"]

    self:setOrigin(0.5, 0)

    local cx, cy, cw, ch = 2, 2, self.width - 2, self.height - 4
    self.collider = Hitbox(self, cx, cy, cw, ch)
end

function BlueSoulPlatform:update()
    super.update(self)
    self:checkCollision()
end

function BlueSoulPlatform:checkCollision()
    local soul = Game.battle.soul
    if soul and soul:includes(LightBlueSoul) then
        Object.startCache()
        if self.collider:collidesWith(soul.platform_collider) then
            if soul.physics.speed_y >= 0 and soul.y <= self.y then
                soul.y = (self.y - soul.height / 2) + 2
                soul.physics.speed_y = 0
                soul.jumping = false
            end
        end
        Object.endCache()
    end
end

function BlueSoulPlatform:draw()
    love.graphics.setLineWidth(1)
    Draw.setColor(COLORS.white)
    Draw.rectangle("line", 0, 0, self.width, self.height)
    Draw.setColor(COLORS.green)
    Draw.rectangle("line", 0, -4, self.width, self.height)

    super.draw(self)

    if DEBUG_RENDER then
        self.collider:draw(COLORS.red)
    end
end

return BlueSoulPlatform