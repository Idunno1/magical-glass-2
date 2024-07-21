local LightBlueSoul, super = Class(LightSoul)

function LightBlueSoul:init(x, y)
    super.init(self, x, y)

    self.color = COLORS.blue

    self.jump_velocity = 6

    self.up_direction = 0
    self.up_vector = Utils.getFacingVector(self.up_direction)

    self.jumping = false

    self.platform_collider = Hitbox(self, -self.width/2, -self.height/2, self.width, self.height)
end

function LightBlueSoul:toggle(active)
    self:setUpAngle(0)
    self:resetPhysics()

    self.last_collided_x = false
    self.last_collided_y = false
    self.jumping = false

    super.toggle(self, active)
end

function LightBlueSoul:setUpAngle(angle)
    self.up_angle = angle
    self.rotation = angle
end

function LightBlueSoul:doMovement(x, y, speed)
    local speed = self.speed

    -- Do speed calculations here if required.

    local move_x = 0

    -- Keyboard input:
    if Input.down("up")    then self:jump() end
    if Input.down("left")  then move_x = move_x - 1 end
    if Input.down("right") then move_x = move_x + 1 end

    self.moving_x = move_x

    if move_x ~= 0 or move_y ~= 0 then
        if not self:move(move_x, 0, speed * DTMULT) then
            self.moving_x = 0
            self.moving_y = 0
        end
    end
end

function LightBlueSoul:jump()
    self.physics.speed_x = 0

    if not self.jumping then
        self.physics.speed_y = -6
        self.jumping = true
    end
end

function LightBlueSoul:update()
    super.update(self)

    if not self.noclip and Game.battle.state == "DEFENDING" then
        if not self.jumping then
            self.physics.speed_y = 0
        end
        self.jumping = not self.last_collided_y or self.last_collided_y == 0
    end

    if self.jumping then
        if Input.released("up") and self.physics.speed_y <= 1 then
            self.physics.speed_y = -1
        end

        if self.physics.speed_y > 0.5 and self.physics.speed_y < 8 then
            self.physics.speed_y = self.physics.speed_y + 0.6 * DTMULT
        end

        if self.physics.speed_y > -1 and self.physics.speed_y <= 0.5 then
            self.physics.speed_y = self.physics.speed_y + 0.2 * DTMULT
        end

        if self.physics.speed_y > -4 and self.physics.speed_y <= -1 then
            self.physics.speed_y = self.physics.speed_y + 0.5 * DTMULT
        end

        if self.physics.speed_y <= 0.4 then
            self.physics.speed_y = self.physics.speed_y + 0.2 * DTMULT
        end
    else
        Object.startCache()
        local collided_platforms = {}
        for _,platform in ipairs(Game.stage:getObjects(BlueSoulPlatform)) do
            if platform:collidesWith(self.platform_collider) then
                table.insert(collided_platforms, platform)
            end
        end
        for _,col_platform in ipairs(collided_platforms) do

        end
        Object.endCache()
    end
end

function LightBlueSoul:draw()
    super.draw(self)

    if DEBUG_RENDER then
        self.platform_collider:draw(COLORS.green)
    end
end

return LightBlueSoul