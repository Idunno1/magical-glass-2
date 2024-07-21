local YellowSoulBigShot, super = Class(Object)

function YellowSoulBigShot:init(x, y, angle)
    super.init(self, x, y)

    self.layer = BATTLE_LAYERS["above_bullets"]
    self.rotation = angle or 0

    self:setOrigin(0, 0.5)
    self:setSprite("player/shot/bigshot")
    self:setScale(0.1, 2)
    self:setHitbox(1, 1, 25, 9)

    self.alpha = 0.5
    self.collider = CircleCollider(self, 30, 14, 14)

    self.physics = {
        speed = 9,
        friction = -0.4,
        match_rotation = true
    }

    self.damage = 4
    self.hit_bullets = {}
end

function YellowSoulBigShot:setSprite(sprite)
    if self.sprite then
        self.sprite:remove()
    end
    self.sprite = Sprite(sprite, 0, 0)
    self:addChild(self.sprite)
    self:setSize(self.sprite:getSize())
end

function YellowSoulBigShot:destroy(anim)
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

function YellowSoulBigShot:update()
    super.update(self)

    if self.scale_x < 1 then
        self.scale_x = Utils.approach(self.scale_x, 1, 0.2 * DTMULT)
    end
    if self.scale_y > 1 then
        self.scale_y = Utils.approach(self.scale_y, 1, 0.2 * DTMULT)
    end
    if self.alpha < 1 then
        self.alpha = Utils.approach(self.alpha, 1, 0.2 * DTMULT)
    end

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
            local _,result = bullet:onYellowShot(self, self.damage)
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

function YellowSoulBigShot:draw()
    super.draw(self)

    if DEBUG_RENDER then
        self.collider:draw(1,0,0)
    end
end

return YellowSoulBigShot