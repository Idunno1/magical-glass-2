local LightYellowSoul, super = Class(LightSoul)

function LightYellowSoul:init(x, y, angle)
    super.init(self, x, y)

    self.rotation = (angle or 0) - math.pi
    self.color = COLORS.yellow

    -- customizable variables
    self.shot_sound = "heartshot"
    self.big_shot_sound = "chargeshot_fire"

    self.shot_type = YellowSoulShot
    self.big_shot_type = YellowSoulBigShot

    self.can_shoot = true -- whether the soul is allowed to shoot in general
    self.can_use_bigshot = true -- whether the soul can use bigshots
    self.can_use_shots = true -- whether the soul can use normal shots
    self.max_shots = 1 -- the amount of shots allowed on-screen. 3 in dr, 1 in ut
    self.cooldown = 14 -- the time it takes before another shot is allowed to be fired. 0 in dr, 14 in ut

    self.teaching = false -- whether big shots should charge slowly
    self.allow_cheat = Kristal.getLibConfig("lightyellowsoul", "allowcheat") -- whether the player is allowed to chain bigshots rapidly

    self.shot_allowed_states = {
        "DEFENDING"
    }

    -- internal variables
    self.hold_timer = 0
    self.cooldown_timer = 0
    self.charge_sfx = nil
end

function LightYellowSoul:toggle(active)
    self.hold_timer = 0
    self.cooldown_timer = 0
    if self.charge_sfx then
        self.charge_sfx:stop()
        self.charge_sfx = nil
    end
    
    super.toggle(self, active)
end

function LightYellowSoul:getShotType() return self.shot_type end
function LightYellowSoul:getBigShotType() return self.big_shot_type end

function LightYellowSoul:getMaxShots() return self.max_shots end

function LightYellowSoul:getCooldown()
    return self.cooldown
end

function LightYellowSoul:getChargeSpeed()
    if self:isTeaching() then -- charge the first shot of a save file slowly if teaching is enabled
        return 1
    else
        return 2
    end
end

function LightYellowSoul:canUseBigShot() return self.can_use_bigshot end
function LightYellowSoul:canUseShots() return self.can_use_shots end
function LightYellowSoul:canShoot()
    return self.can_shoot and Utils.containsValue(self.shot_allowed_states, Game.battle.state)
end
function LightYellowSoul:canCheat() return self.allow_cheat end
function LightYellowSoul:isTeaching() return self.teaching end

function LightYellowSoul:onCheat()
    Game.battle.encounter.yellow_soul_cheat_shots = (Game.battle.encounter.yellow_soul_cheat_shots or 0) + 1
end

function LightYellowSoul:fireShot(big)
    if big then
        Game.battle:addChild(self.big_shot_type(self.x, self.y, self.rotation + math.pi/2))
        Assets.playSound(self.big_shot_sound)
    else
        if #Game.stage:getObjects(self.shot_type) >= self.max_shots then return end
        Game.battle:addChild(self.shot_type(self.x, self.y, self.rotation + math.pi/2))
        Assets.playSound(self.shot_sound)
    end
    self.cooldown_timer = self:getCooldown()
end

function LightYellowSoul:update()
    super.update(self)

    -- Unless I'm wrong, which is very possible, the yellow soul flashes a different color
    -- in UT
    if self.inv_timer > 0 then
        local amt = math.floor(self.inv_flash_timer / (2/30))
        if (amt % 2) == 1 then
            self.sprite:setColor(244/255, 212/255, 1)
        else
            self.sprite:setColor(1, 1, 1)
        end
    end

    if self.cooldown_timer ~= 0 then
        self.cooldown_timer = Utils.approach(self.cooldown_timer, 0, DTMULT)
    end

    if self.transitioning then
        if self.charge_sfx then
            self.charge_sfx:stop()
            self.charge_sfx = nil
        end
        return
    end

    if not self:canShoot() then return end
    if self.cooldown_timer ~= 0 then return end
    
    if Input.pressed("confirm") and self.hold_timer == 0 and self:canUseShots() then -- fire normal shot
        self:fireShot(false)
    end
    if self:canUseBigShot() then
        -- check release before checking hold, since if held is false it sets the timer to 0
        if Input.released("confirm") then -- fire big shot
            if self.hold_timer >= 10 and self.hold_timer < 40 then -- didn't hold long enough, fire normal shot
                self:fireShot(false)
            elseif self.hold_timer >= 40 then -- fire big shot
                self:fireShot(true)
                if self.teaching then
                    self.teaching = false
                end
                if self:canCheat() and Input.down("confirm") then -- they are cheating
                    self:onCheat()
                end
            end
            if not self:canCheat() then -- reset hold timer if cheating is disabled
                self.hold_timer = 0
            end
        end

        if Input.down("confirm") then -- charge a big shot
            self.hold_timer = self.hold_timer + (self:getChargeSpeed() * DTMULT)

            if self.hold_timer >= 20 and not self.charge_sfx then -- start charging sfx
                self.charge_sfx = Assets.newSound("chargeshot_charge")
                self.charge_sfx:setLooping(true)
                self.charge_sfx:setPitch(0.1)
                self.charge_sfx:setVolume(0)
                local timer = 0
                Game.battle.timer:during(2/3, function()
                    timer = timer + DT
                    if self.charge_sfx then
                        self.charge_sfx:setVolume(Utils.clampMap(timer, 0,2/3, 0,0.3))
                    end
                end, function()
                    if self.charge_sfx then
                        self.charge_sfx:setVolume(0.3)
                    end    
                end)
                self.charge_sfx:play()
            end
            if self.hold_timer >= 20 and self.hold_timer < 40 then
                self.charge_sfx:setPitch(Utils.clampMap(self.hold_timer, 20,40, 0.1,1))
            end
        else
            self.hold_timer = 0
            if self.charge_sfx then
                self.charge_sfx:stop()
                self.charge_sfx = nil
            end
        end
    end
end

function LightYellowSoul:draw()
    local r, g, b, a = self:getDrawColor()
    local heart_texture = Assets.getTexture(self.sprite.texture_path)
    local heart_w, heart_h = heart_texture:getDimensions()

    local charge_timer = self.hold_timer - 35
    if charge_timer > 0 then
        local scale = math.abs(math.sin(charge_timer / 10)) + 1
        love.graphics.setColor(r,g,b,a*0.3)
        love.graphics.draw(heart_texture, -heart_w/2 * scale, -heart_h/2 * scale, 0, scale)

        scale = math.abs(math.sin(charge_timer / 14)) + 1.2
        love.graphics.setColor(r,g,b,a*0.3)
        love.graphics.draw(heart_texture, -heart_w/2 * scale, -heart_h/2 * scale, 0, scale)
    end

    local circle_timer = math.min(self.hold_timer - 15, 35)
    if circle_timer > 0 then
        local circle = Assets.getTexture("player/shot/charge")
        love.graphics.setColor(r,g,b,a*(circle_timer/5))
        for i=1,4 do
            local angle = (i*math.pi/2) - (circle_timer * math.rad(5))
            local x, y = math.cos(angle) * (35 - circle_timer), math.sin(angle) * (35 - circle_timer)
            local scale = Utils.clampMap(circle_timer, 0,35, 4,2)
            x, y = x - circle:getWidth()/2 * scale, y - circle:getHeight()/2 * scale
            love.graphics.draw(circle, x, y, 0, scale)
        end
    end

    if charge_timer > 0 then
        self.color = {1,1,1}
    end

    super.draw(self)

    self.color = {r, g, b}
end

function LightYellowSoul:onRemove(parent)
    if self.charge_sfx then
        self.charge_sfx:stop()
        self.charge_sfx = nil
    end
end

return LightYellowSoul