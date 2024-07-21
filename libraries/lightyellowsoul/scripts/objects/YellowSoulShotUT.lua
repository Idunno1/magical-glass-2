local YellowSoulShotUT, super = Class(Object)

function YellowSoulShotUT:init(x, y, angle)
    super.init(self, x, y)

    self.layer = BATTLE_LAYERS["above_bullets"]
    self.rotation = angle or 0

    self:setOrigin(0, 0.5)
    self:setSprite("player/shot/shot_ut")
    self:setHitbox(0, 0, 16, 10)

    self.physics = {
        speed = 16,
        match_rotation = true
    }

    self.damage = 1
    self.hit_bullets = {}
end

function YellowSoulShotUT:setSprite(sprite)
    if self.sprite then
        self.sprite:remove()
    end
    self.sprite = Sprite(sprite, 0, 0)
    self:addChild(self.sprite)
    self:setSize(self.sprite:getSize())
end

function YellowSoulShotUT:update()
    super.update(self)

    self.scale_x = self.scale_x + (0.2 * DTMULT)

    if (self.x > SCREEN_WIDTH + self.width) or (self.x < self.width) or
       (self.y > SCREEN_HEIGHT + self.height) or (self.y < self.height) then
        self:remove()
    end

    local bullets = Utils.filter(Game.stage:getObjects(Bullet), function(object)
        if self.hit_bullets[object] then return false end
        return object.onYellowShot
    end)
    for _,bullet in ipairs(bullets) do
        if self:collidesWith(bullet) then
            self.hit_bullets[bullet] = true
            local result,_ = bullet:onYellowShot(self, self.damage)
            if result then
                self:remove()
                break
            end
        end
    end
end

function YellowSoulShotUT:draw()
    super.draw(self)

    if DEBUG_RENDER then
        self.collider:draw(1,0,0)
    end
end

return YellowSoulShotUT