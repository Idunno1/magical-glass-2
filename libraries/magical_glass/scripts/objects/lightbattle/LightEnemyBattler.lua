local LightEnemyBattler, super = Class(Battler, "LightEnemyBattler")

function LightEnemyBattler:init(actor, use_overlay)
    super.init(self)
    -- This enemy's name.
    -- Associated getter: getName (string)
    self.name = "Test Enemy"

    if actor then
        self:setActor(actor, use_overlay)
    end

    self.health = 100
    self.stats = {
        health = 100,
        attack = 1,
        defense = 0
    }

    self.stat_buffs = {}

    -- The base amount of money this enemy gives the player when defeated.
    -- Asociated getter: getMoney (number, rounded)
    self.money = 0
    -- The EXP rewarded when this enemy is defeated.
    -- Associated getter: getEXP (number, rounded)
    self.exp = 0

    -- Whether this enemy can be spared via a pacifying spell.
    self.tired = false

    -- This enemy's current mercy points. When it reaches 100, this enemy can be
    -- spared.
    -- Typically, this should be changed with addMercy.
    self.mercy = 0

    -- The amount of mercy points added when this enemy is spared before mercy
    -- reaches 100.
    self.spare_points = 0

    -- Should this enemy turn to dust when defeated?
    self.vaporize_on_defeat = true
    -- Whether this enemy's dust should be separated by lines instead of pixels.
    -- Recommeneded for larger enemies.
    self.large_vapor = false

    -- Whether this enemy can be frozen.
    self.can_freeze = false
    -- Whether this enemy can run away when defeated.
    self.can_run = false

    -- Whether this enemy can be selected or not.
    self.selectable = true

    -- Whether this enemy's HP should be shown in ENEMYSELECT and if
    -- an HP gauge will be spawned with the damage numbers
    self.show_health = true
    -- Whether mercy is disabled for this enemy, like in the weird route Spamton NEO fight.
    -- This only affects the visual mercy bar.
    self.disable_mercy = false
    -- Whether the mercy gauge should be shown when mercy is added to this enemy.
    self.show_mercy_gauge = true

    -- The width of the gauge that appears when this enemy is damaged.
    -- Associated getter: getGaugeWidth (number)
    self.gauge_width = 100
    -- The offset of this enemy's damage popups.
    -- Associated getter: getDamageOffset (table)
    self.damage_offset = {5, -40}

    -- A table of strings of wave IDs that this enemy can use.
    -- Associated getter: getNextWaves (string)
    self.waves = {}

    self.wave_override = nil
    -- A table of strings of wave IDs that this enemy can use while the player is in the menu.
    -- Associated getter: getNextMenuWaves (string)
    self.menu_waves = {}
    self.menu_wave_override = nil
    
    -- The text that gets displayed when the Check ACT is used, prefixed with "ENEMY NAME - "
    -- Associated getter: getCheckText (string or table)
    self.check = "Wake up and taste the [color:red]\npain"

    -- A table of strings containing flavor text that can be displayed in ACTIONSELECT when
    -- this enemy is active.
    -- Associated getter: getEncounterText (string or table)
    self.text = {}

    -- A table of strings or just a string containing the message that is displayed in
    -- ACTIONSELECT when this enemy is active and has low health.
    -- Associated getter: getLowHealthText (string or table)
    self.low_health_text = nil
    -- A table of strings or just a string containing the message that is displayed in
    -- ACTIONSELECT when this enemy is TIRED.
    -- Associated getter: getTiredText (string or table)
    self.tired_text = nil
    -- A table of strings or just a string containing the message that is displayed in
    -- ACTIONSELECT when this enemy can be spared.
    -- Associated getter: getSparableText (string or table)
    self.spareable_text = nil

    -- When this enemy is below this percentage of health, their tired text will be displayed.
    self.tired_percentage = 0
    -- When this enemy is below this percentage of health, their low health text will be displayed.
    self.low_health_percentage = 0.2

    -- The sound that plays when this enemy is hit by an attack.
    -- Associated getter: getDamageSound (string or userdata)
    self.damage_sound = "damage"
    -- The sound that plays about a second after this enemy is hit by an attack.
    -- Associated getter: getDamageVoice (string or userdata)
    self.damage_voice = nil
    -- Display 0 instead of miss when attacked.
    self.display_damage_on_miss = false

    -- A table of strings or just a string containing the message that is displayed in
    -- this enemy's dialogue box in the ENEMYDIALOGUE phase.
    -- Associated getter: getDialogue (string or table)
    self.dialogue = {}
    self.dialogue_override = nil
    -- The style of speech bubble this enemy should use.
    self.dialogue_bubble = "ut_large"
    -- The offset for this enemy's speech bubble.
    self.dialogue_offset = {0, 0}
    -- Whether the speech bubble should be flipped horizontally.
    self.flip_dialogue = true

    -- A string displayed next to the enemy's name in ENEMYSELECT.
    -- setTired sets this to "(Tired)" when it's true, and clears it when it's false.
    self.comment = ""


    -- The acts that this enemy has.
    -- It is HEAVILY recommended to use the registerAct functions instead of directly
    -- editing this table.
    self.acts = {
        {
            ["name"] = "Check",
            ["description"] = "",
            ["party"] = {}
        }
    }

    self.current_target = nil

    self.hurt_timer = 0
    self.defeated = false

    self.encounter = nil

    -- How this enemy was removed from battle. If they're still active, this is nil.
    -- This is an internal variable. Do not edit this unless you know what you're doing.
    self.done_state = nil
end

-- Getters

function LightEnemyBattler:getName() return self.name end
function LightEnemyBattler:getMoney() return self.money end
function LightEnemyBattler:getEXP() return self.exp end

function LightEnemyBattler:getHealth() return self.health end
function LightEnemyBattler:getStats() return self.stats end
function LightEnemyBattler:getStat(name, default)
    return (self:getStats()[name] or (default or 0))
end
function LightEnemyBattler:getStatBuffs() return self.stat_buffs end
function LightEnemyBattler:getStatBuff(stat)
    return self:getStatBuffs()[stat] or 0
end

function LightEnemyBattler:getCheckText() return self.check end

function LightEnemyBattler:getEncounterText()
    local has_spareable_text = self.spareable_text and self:canSpare()

    local priority_spareable_text = Game:getConfig("prioritySpareableText")
    if priority_spareable_text and has_spareable_text then
        return self.spareable_text
    end

    if self.low_health_text and self.health <= (self.max_health * self.low_health_percentage) then
        return self.low_health_text

    elseif self.tired_text and self.tired then
        return self.tired_text

    elseif has_spareable_text then
        return self.spareable_text
    end

    return Utils.pick(self.text)
end

function LightEnemyBattler:getAct(name)
    for _,act in ipairs(self.acts) do
        if act.name == name then
            return act
        end
    end
end

function LightEnemyBattler:getXAction(battler) return "Standard" end
function LightEnemyBattler:isXActionShort(battler) return false end

function LightEnemyBattler:getNextWaves()
    if self.wave_override then
        local wave = self.wave_override
        self.wave_override = nil
        return {wave}
    end
    return self.waves
end

function LightEnemyBattler:getDamageSound()
    if self.damage_sound then
        if type(self.damage_sound) == "string" then
            -- Load and return the sound if it's a string.
            return Assets.newSound(self.damage_sound)
        elseif type(self.damage_sound) == "userdata" then
            -- Just return if if it's already loaded, and is thus userdata.
            return self.damage_sound
        end
    else
        -- Otherwise, return nil to signify that no sound should be played.
        return nil
    end
end

function LightEnemyBattler:getDamageVoice()
    if self.damage_voice then
        if type(self.damage_voice) == "string" then
            return Assets.newSound(self.damage_voice)
        elseif type(self.damage_voice) == "userdata" then
            return self.damage_voice
        end
    else
        return nil
    end
end

-- Callbacks

function LightEnemyBattler:onCheck(battler) end

function LightEnemyBattler:onActStart(battler, name)
    battler:setAnimation("battle/act")
    local action = Game.battle:getCurrentAction()
    if action.party then
        for _,party_id in ipairs(action.party) do
            Game.battle:getPartyBattler(party_id):setAnimation("battle/act")
        end
    end
end
function LightEnemyBattler:onAct(battler, name)
    if name == "Check" then
        self:onCheck(battler)
        if type(self.check) == "table" then
            local tbl = {}
            for i,check in ipairs(self.check) do
                if i == 1 then
                    table.insert(tbl, "* " .. string.upper(self.name) .. " - " .. check)
                else
                    table.insert(tbl, "* " .. check)
                end
            end
            return tbl
        else
            return "* " .. string.upper(self.name) .. " - " .. self.check
        end
    end
end

function LightEnemyBattler:onTurnStart() end
function LightEnemyBattler:onTurnEnd() end

function LightEnemyBattler:onSpareable() end
function LightEnemyBattler:onSpared()
    if self.actor.use_light_battler_sprite then
        if self.actor:getAnimation("lightbattle_spared") then
            self.overlay_sprite:setAnimation("lightbattle_spared")
        else
            self.overlay_sprite:setAnimation("lightbattle_hurt")
        end
    else
        self.overlay_sprite:setAnimation("spared")
    end
end

function LightEnemyBattler:onHurt(damage, battler)
    self:toggleOverlay(true)
    if self.actor.use_light_battler_sprite then
        if not self:getActiveSprite():setAnimation("lightbattle_hurt") then
            self:toggleOverlay(false)
        end
    else
        if not self:getActiveSprite():setAnimation("hurt") then
            self:toggleOverlay(false)
        end
    end

    self:getActiveSprite():shake(9, 0, 0.5, 2/30) -- still not sure if this should be different

    Game.battle.timer:after(1/3, function()
        local sound = self:getDamageVoice()
        if sound and type(sound) == "string" and not self:getActiveSprite().frozen then
            Assets.stopAndPlaySound(sound)
        end
    end)

    if self.health <= (self.max_health * self.tired_percentage) then
        self:setTired(true)
    end

    if self.health <= (self.max_health * self.spare_percentage) then
        self.mercy = 100
    end
end

function LightEnemyBattler:onHurtEnd()
    self:getActiveSprite():stopShake()
    if self.health > 0 or not self.vaporize_on_defeat then
        self:toggleOverlay(false, true)
    end
end

function LightEnemyBattler:onDodge(battler, attacked) end

function LightEnemyBattler:onDefeatSpared()
    self:toggleOverlay(true)
    self.alpha = 0.5
    Game.battle:playVaporizedSound()

    for i = 0, 15 do
        local x = ((Utils.random((self.width / 2)) + (self.width / 4))) - 8
        local y = ((Utils.random((self.height / 2)) + (self.height / 4))) - 8

        local sx, sy = self:getRelativePos(x, y)

        local dust = SpareDust(sx, sy)
        self.parent:addChild(dust)

        dust.rightside = ((8 + x)) / (self.width / 2)
        dust.topside = ((8 + y)) / (self.height / 2)

        Game.battle.timer:after(1/30, function()
            dust:spread()
        end)

        dust.layer = BATTLE_LAYERS["above_ui"] + 3
    end
end

function LightEnemyBattler:onDefeat(damage, battler)
    if self.exit_on_defeat then
        if self.actor.use_light_battler_sprite then
            self:toggleOverlay(true)
        end
        Game.battle.timer:after(self.hurt_timer, function()
            if self.actor.use_light_battler_sprite then
                self:toggleOverlay(true)
            end
            if self.can_die then
                if self.ut_death then
                    self:onDefeatVaporized(damage, battler)
                else
                    self:onDefeatFatal(damage, battler)
                end
            else
                self:onDefeatRun(damage, battler)
            end
        end)
    elseif not self.actor.use_light_battler_sprite then
        self.sprite:setAnimation("defeat")
    end
end

function LightEnemyBattler:onDefeatVaporized(damage, battler)
    self.hurt_timer = -1
    self.defeated = true

    Assets.playSound("vaporized", 1.2)

    local sprite = self:getActiveSprite()

    sprite.visible = false
    sprite:stopShake()

    local death_x, death_y = sprite:getRelativePos(0, 0, self)
    local death
    if self.large_dust then
        death = DustEffectLarge(sprite:getTexture(), death_x, death_y, function() self:remove() end)
    else
        death = DustEffect(sprite:getTexture(), death_x, death_y, function() self:remove() end)
    end
     
    death:setColor(sprite:getDrawColor())
    death:setScale(sprite:getScale())
    self:addChild(death)

    self:defeat("KILLED", true)
end

function LightEnemyBattler:onDefeatRun(damage, battler)
    self.hurt_timer = -1
    self.defeated = true

    Assets.playSound("defeatrun")

    local sweat = Sprite("effects/defeat/sweat")
    sweat:setOrigin(0.5, 0.5)
    sweat:play(5/30, true)
    sweat.layer = 100
    self:addChild(sweat)

    Game.battle.timer:after(15/30, function()
        sweat:remove()
        -- maybe don't hook actorsprite this time?
        self:getActiveSprite().run_away_light = true

        Game.battle.timer:after(15/30, function()
            self:remove()
        end)
    end)

    self:defeat("VIOLENCED", true)
end

-- Functions

function LightEnemyBattler:setTired(bool)
    self.tired = bool
    if self.tired then
        self.comment = "(Tired)"
    else
        self.comment = ""
    end
end

function LightEnemyBattler:addMercy(amount) 
    -- Doesn't deltarune show a miss if you spare an enemy with >= 100 mercy?
    if (amount >= 0 and self.mercy >= 100) or (amount < 0 and self.mercy <= 0) then
        -- This enemy either has full mercy or 0 mercy and some is being removed. 
        -- Regardless, nothing should happen.
        return
    end
    
    self.mercy = self.mercy + amount
    if self.mercy < 0 then
        self.mercy = 0
    end

    if self.mercy >= 100 then
        self.mercy = 100
    end

    if self:canSpare() then
        self:onSpareable()
        if self.auto_spare then
            self:spare(false)
        end
    end

    if MagicalGlass.light_battle_mercy_messages and self.show_mercy_gauge then
        if amount == 0 then
            self:statusMessageLight("msg", "miss", COLORS.yellow)
        else
            if amount > 0 then
                local pitch = 0.8
                if amount < 99 then pitch = 1 end
                if amount <= 50 then pitch = 1.2 end
                if amount <= 25 then pitch = 1.4 end

                local src = Assets.playSound("mercyadd", 0.8)
                src:setPitch(pitch)
            end

            self:statusMessageLight("mercy", amount)
        end
    end
end

function LightEnemyBattler:registerAct(name, description, party, tp, highlight, icons)
    if type(party) == "string" then
        if party == "all" then
            party = {}
            for _,chara in ipairs(Game.party) do
                table.insert(party, chara.id)
            end
        else
            party = {party}
        end
    end
    local act = {
        ["character"] = nil,
        ["name"] = name,
        ["description"] = description,
        ["party"] = party,
        ["tp"] = tp or 0,
        ["highlight"] = highlight,
        ["short"] = false,
        ["icons"] = icons
    }
    table.insert(self.acts, act)
    return act
end

function LightEnemyBattler:registerShortAct(name, description, party, tp, highlight, icons)
    if type(party) == "string" then
        if party == "all" then
            party = {}
            for _,battler in ipairs(Game.battle.party) do
                table.insert(party, battler.id)
            end
        else
            party = {party}
        end
    end
    local act = {
        ["character"] = nil,
        ["name"] = name,
        ["description"] = description,
        ["party"] = party,
        ["tp"] = tp or 0,
        ["highlight"] = highlight,
        ["short"] = true,
        ["icons"] = icons
    }
    table.insert(self.acts, act)
    return act
end

function LightEnemyBattler:registerActFor(char, name, description, party, tp, highlight, icons)
    if type(party) == "string" then
        if party == "all" then
            party = {}
            for _,chara in ipairs(Game.party) do
                table.insert(party, chara.id)
            end
        else
            party = {party}
        end
    end
    local act = {
        ["character"] = char,
        ["name"] = name,
        ["description"] = description,
        ["party"] = party,
        ["tp"] = tp or 0,
        ["highlight"] = highlight,
        ["short"] = false,
        ["icons"] = icons
    }
    table.insert(self.acts, act)
end

function LightEnemyBattler:registerShortActFor(char, name, description, party, tp, highlight, icons)
    if type(party) == "string" then
        if party == "all" then
            party = {}
            for _,battler in ipairs(Game.battle.party) do
                table.insert(party, battler.id)
            end
        else
            party = {party}
        end
    end
    local act = {
        ["character"] = char,
        ["name"] = name,
        ["description"] = description,
        ["party"] = party,
        ["tp"] = tp or 0,
        ["highlight"] = highlight,
        ["short"] = true,
        ["icons"] = icons
    }
    table.insert(self.acts, act)
end

function LightEnemyBattler:removeAct(name)
    for i,act in ipairs(self.acts) do
        if act.name == name then
            table.remove(self.acts, i)
            break
        end
    end
end

function LightEnemyBattler:getNameColors()
    local result = {}
    if self:canSpare() then
        table.insert(result, {1, 1, 0})
    end
    if self.tired then
        table.insert(result, {0, 0.7, 1})
    end
    return result
end

function LightEnemyBattler:getTarget()
    return Game.battle:randomTarget()
end

function LightEnemyBattler:hurt(amount, battler, on_defeat, color, show_status, attacked)
    if attacked ~= false then
        attacked = true
    end
    local message
    if amount <= 0 then
        if not self.display_damage_on_miss or not attacked then
            message = self:lightStatusMessage("msg", "miss", color or (battler and {battler.chara:getLightMissColor()}))
        else
            message = self:lightStatusMessage("damage", 0, color or (battler and {battler.chara:getLightDamageColor()}))
        end
        if message and (anim and anim ~= nil) then
            message:resetPhysics()
        end
        if attacked then
            self.hurt_timer = 1
        end

        self:onDodge(battler, attacked)
        return
    end

    message = self:lightStatusMessage("damage", amount, color or (battler and {battler.chara:getLightDamageColor()}))
    if message and (anim and anim ~= nil) then
        message:resetPhysics()
    end
    self.health = self.health - amount

    self.hurt_timer = 1
    self:onHurt(amount, battler)

    self:checkHealth(on_defeat, amount, battler)
end

function LightEnemyBattler:heal(amount)
    Assets.stopAndPlaySound("power")
    self:lightStatusMessage("damage", "+" .. amount, {0, 1, 0})

    self.health = self.health + amount

    if self.health >= self.max_health then
        self.health = self.max_health
    end
end

function LightEnemyBattler:checkHealth(on_defeat, amount, battler)
    -- on_defeat is optional
    if self.health <= 0 then
        self.health = 0

        if not self.defeated then
            if on_defeat then
                on_defeat(self, amount, battler)
            else
                self:forceDefeat(amount, battler)
            end
        end
    end
end

function LightEnemyBattler:canSpare()
    return self.mercy >= 100
end

function LightEnemyBattler:spare(pacify)
    if self.vaporize_on_defeat then
        self:onDefeatSpared()
    end

    self:defeat(pacify and "PACIFIED" or "SPARED", false)
    self:onSpared()
end

function LightEnemyBattler:freeze()
    if not self.can_freeze then
        self:onDefeat()
        return
    end

    Assets.playSound("petrify")

    self:toggleOverlay(true)

    local sprite = self:getActiveSprite()
    if not sprite:setAnimation("frozen") then
        sprite:setAnimation("hurt")
    end
    sprite:stopShake()

    local message = self:lightStatusMessage("msg", "frozen", {58/255, 147/255, 254/255}, true)
    message.y = message.y + 60
    message:resetPhysics()

    self.hurt_timer = -1

    sprite.frozen = true
    sprite.freeze_progress = 0

    Game.battle.timer:tween(20/30, sprite, {freeze_progress = 1})

    if Game:isLight() then
        Game.battle.money = Game.battle.money + 2
    else
        Game.battle.money = Game.battle.money + 24
    end
    self:defeat("FROZEN", true)
end

function LightEnemyBattler:defeat(reason, violent)
    self.done_state = reason or "DEFEATED"

    if violent then
        Game.battle.used_violence = true
        if self.done_state == "KILLED" or self.done_state == "FROZEN" then
            -- do this better
            -- MagicalGlassLib.kills = MagicalGlassLib.kills + 1
            Game.battle.xp = Game.battle.xp + self:getEXP()
        end
    end
    
    Game.battle.money = Game.battle.money + self:getMoney()
    Game.battle:removeEnemy(self, true)
end

function LightEnemyBattler:forceDefeat(amount, battler)
    self:onDefeat(amount, battler)
end

function LightEnemyBattler:statusMessage(...)
    return super.statusMessage(self, self.width/2, self.height/2, ...)
end

function LightEnemyBattler:recruitMessage(...)
    return super.recruitMessage(self, self.width/2, self.height/2, ...)
end

function LightEnemyBattler:update()
    if self.actor then
        self.actor:onBattleUpdate(self)
    end

    if self.hurt_timer > 0 then
        self.hurt_timer = Utils.approach(self.hurt_timer, 0, DT)

        if self.hurt_timer == 0 then
            self:onHurtEnd()
        end
    end

    super.update(self)
end

function LightEnemyBattler:draw()
    if self.actor then
        self.actor:onBattleDraw(self)
    end

    super.draw(self)
end

function LightEnemyBattler:setFlag(flag, value)
    Game:setFlag("light_enemy#"..self.id..":"..flag, value)
end

function LightEnemyBattler:getFlag(flag, default)
    return Game:getFlag("light_enemy#"..self.id..":"..flag, default)
end

function LightEnemyBattler:addFlag(flag, amount)
    return Game:addFlag("light_enemy#"..self.id..":"..flag, amount)
end

function LightEnemyBattler:canDeepCopy()
    return false
end

return LightEnemyBattler