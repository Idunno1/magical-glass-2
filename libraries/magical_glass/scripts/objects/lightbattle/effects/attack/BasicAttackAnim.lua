local BasicAttackAnim, super = Class(Sprite, "BasicAttackAnim")

function BasicAttackAnim:init(x, y, texture, stretch, options)
    super.init(self, texture, x, y)

    options = options or {}

    self.layer = BATTLE_LAYERS["above_ui"] + 5

    self.attack_texture = texture or "effects/attack/strike"

    self.stretch = stretch
    if not MagicalGlass.solo_battles then
        self.stretch = nil
    end

    self.attack_sound = options["sound"] or "laz_c"
    self.attack_sound_pitch = options["sound_pitch"] or 1

    self.crit = crit
    self.crit_sound = options["crit_sound"] or "criticalswing"

    self.after_func = options["after"] or function() end

    self:setColor(options["color"] or MagicalGlass.PALETTE["player_attack"])

    self.attack_sprite = nil
end

function BasicAttackAnim:onAdd()
    local sound = Assets.stopAndPlaySound(self.attack_sound)
    sound:setPitch(self.attack_sound_pitch)

    if self.crit then
        Assets.stopAndPlaySound(self.crit_sound)
    end

    self.attack_sprite = Sprite(self.attack_texture)
    if self.stretch then
        self.attack_sprite:setScale((self.stretch * 2) - 0.5)
    else
        self.attack_sprite:setScale(1.5)
    end
    self.attack_sprite:setOrigin(0.5)
    self.attack_sprite.inherit_color = true

    local speed
    if self.stretch then
        speed = (self.stretch / 4) / 1.6 -- probably isn't accurate
    else
        speed = 2/30
    end

    self.attack_sprite:play(speed, false, function()
        self.after_func()
        self:remove()
    end)

    self:addChild(self.attack_sprite)
end

return BasicAttackAnim