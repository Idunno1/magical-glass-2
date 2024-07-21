local YellowSoulShot, super = Class(Object)

function YellowSoulShot:init(x, y, angle)
    super.init(self, x, y)

    self.layer = BATTLE_LAYERS["above_bullets"]
    self.rotation = angle or 0

    self:setOrigin(0, 0.5)
    self:setSprite("player/shot/shot")
    self:setHitbox(1, 1, 25, 9)

    self.physics = {
        speed = 16,
        match_rotation = true
    }

    self.damage = 1
    self.hit_bullets = {}
end

function YellowSoulShot:setSprite(sprite)
    if self.sprite then
        self.sprite:remove()
    end
    self.sprite = Sprite(sprite, 0, 0)
    self:addChild(self.sprite)
    self:setSize(self.sprite:getSize())
end

function YellowSoulShot:destroy(anim)
    anim = anim or "player/shot/hit/a"
    if string.len(anim) == 1 then
        anim = "player/shot/hit/"..anim
    end
    local sprite = Sprite(anim, self.x + self.width, self.y)
    sprite:setOrigin(0.5, 0.5)
    sprite.layer = BATTLE_LAYERS["above_bullets"]
    sprite:play(0.1, false, function()
        sprite:remove()
    end)
    Game.battle:addChild(sprite)
    self:remove()
end

function YellowSoulShot:update()
    super.update(self)

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
                if type(result) == "string" then
                    self:destroy(result)
                else
                    self:remove()
                end
                break
            end
        end
    end
end

function YellowSoulShot:draw()
    super.draw(self)

    if DEBUG_RENDER then
        self.collider:draw(1,0,0)
    end
end

return YellowSoulShot