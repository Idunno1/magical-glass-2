local LightEncounter = Class(nil, "LightEncounter")

function LightEncounter:init()
    -- A table defining the default location of where the soul should move to
    -- during the battle transition. If this is nil, it will move to the FIGHT button.
    -- Associated getter: getSoulTarget (table[x, y])
    self.soul_target = nil

    -- Text that will be displayed when the battle starts
    -- Associated getter: getEncounterText (string)
    self.text = "* A skirmish breaks out!"

    -- Whether this encounter allows commands to be input. Changes the UI if active.
    self.story = false
    -- The wave that gets spawned if story is true.
    -- Associated getter: getStoryWave (string or Wave)
    self.story_wave = nil

    -- The image to draw for the background. Leave blank to disable the background.
    -- Associated getter: getBackgroundImage (bool)
    self.background_image = "ui/lightbattle/backgrounds/battle"

    -- The music used for this encounter
    -- Associated getter: getMusic (string representing the path to an audio file)
    self.music = "battle_ut"

    -- Whether characters have the X-Action option in their spell menu
    self.default_xactions = Game:getConfig("partyActions")

    -- Should the battle skip the YOU WON! text?
    -- Associated getter: shouldSkipEndMessage (bool)
    self.no_end_message = false

    -- Whether Karmic Retribution (KR) will be enabled for this encounter.
    -- Associated getter: isKarmaEnabled (bool)
    self.karma = false

    -- Table used to spawn enemies after a battle starts and this encounter file is loaded
    -- beforehand.
    self.queued_enemy_spawns = {}

    -- Whether the "Flee" command should be shown in the MERCY menu.
    -- Associated getter: canFlee (bool)
    self.can_flee = true

    -- The initial flee chance of this encounter. Increases every time the player fails to flee
    -- from this encounter. Succeeds if it exceeds (>) self.flee_threshold by default.
    -- Fleeing is detemined by attemptFlee (bool) function.
    self.flee_chance = 0
    -- flee_chance must EXCEED (i.e. be higher than) this number for the flee to be successful.
    -- This is always 50 in UNDERTALE.
    -- Associated getter: getFleeThreshold (number)
    self.flee_threshold = 50
    -- A table of messages that the game will pick from to print if you successfully flee from
    -- this encounter.
    -- Associated getter: getFleeMessage (string or table)
    self.flee_messages = {
        "* I'm outta here.", -- 1/20 chance by default
        "* I've got better to do.", -- 1/20 chance
        "* Escaped...", -- 17/20 chance
        "* Don't slow me down." -- 1/20 chance
    }

    -- A copy of Battle.defeated_enemies, used to determine how an enemy has been defeated.
    -- This is an internal variable. Do not edit it unless you know what you're doing.
    self.defeated_enemies = nil
end

-- Getters

function LightEncounter:getMusic()
    if self.music then
        if type(self.music) == "string" then
            -- Load and return the song if it's a string.
            return Assets.newSound(self.music)
        elseif type(self.music) == "userdata" then
            -- Just return if if it's already loaded, and is thus userdata.
            return self.music
        end
    else
        -- Otherwise, return nil to signify that no music should be played.
        return nil
    end
end

function LightEncounter:getEncounterText()
    local enemies = Game.battle:getActiveEnemies()
    local enemy = Utils.pick(enemies, function(v)
        if not v.text then
            return true
        else
            return #v.text > 0
        end
    end)
    if enemy then
        return enemy:getEncounterText()
    else
        return self.text
    end
end

function LightEncounter:getNextWaves()
    local waves = {}
    if self.story then
        local wave = self:getStoryWave()
        table.insert(waves, wave)
    else
        for _,enemy in ipairs(Game.battle:getActiveEnemies()) do
            local wave = enemy:selectWave()
            if wave then
                table.insert(waves, wave)
            end
        end
    end
    return waves
end

function LightEncounter:getNextMenuWaves()
    local waves = {}
    for _,enemy in ipairs(Game.battle:getActiveEnemies()) do
        local wave = enemy:selectMenuWave()
        if wave then
            table.insert(waves, wave)
        end
    end
    return waves
end

function LightEncounter:getStoryWave() return self.story_wave end

function LightEncounter:getBackgroundImage()
    if self.background_image then
        if type(self.background_image) == "string" then
            -- Load and return the image if it's a string.
            return Assets.getTexture(self.background_image)
        elseif type(self.background_image) == "userdata" then
            -- Just return if if it's already loaded, and is thus userdata.
            return self.background_image
        end
    else
        -- Otherwise, return nil to signify that an image shouldn't be drawn.
        return nil
    end
end

function LightEncounter:isKarmaEnabled() return self.karma end
function LightEncounter:canFlee() return self.can_flee end
function LightEncounter:getSoulColor() return Game:getSoulColor() end

function LightEncounter:getFleeMessage()
    local message = Utils.random(0, 20, 1)

    if message == 0 or message == 1 then
        return "[instant]" .. self.flee_messages[1] -- "* I'm outta here."
    elseif message == 2 then
        return "[instant]" .. self.flee_messages[2] -- "* I've got better to do."
    elseif message > 3 then
        return "[instant]" .. self.flee_messages[3] -- "* Escaped..."
    elseif message == 3 then
        return "[instant]" .. self.flee_messages[4] -- "* Don't slow me down."
    end
end

function LightEncounter:getRewardFleeMessage(exp, money)
    return "* Ran away with " .. exp .. " EXP\n  and " .. money .. " " .. Game:getConfig("lightCurrency"):lower() .. "."
end

function LightEncounter:getDialogueCutscene() end

function LightEncounter:getVictoryMoney(money) end
function LightEncounter:getVictoryEXP(exp) end
function LightEncounter:getVictoryText(text, money, exp) end

-- Callbacks

function LightEncounter:onTransition()
    self:soulTransition(x, y)
end

function LightEncounter:onTransitionFinished()
    Game.battle:setState("ACTIONSELECT")
end

function LightEncounter:onBattleInit() end
function LightEncounter:onBattleStart() end
function LightEncounter:onBattleEnd() end

function LightEncounter:onFleeStart() end
function LightEncounter:onFlee() 
    Assets.playSound("escaped")
end
function LightEncounter:onFleeFail() end

function LightEncounter:onTurnStart() end
function LightEncounter:onTurnEnd() end

function LightEncounter:onActionsStart() end
function LightEncounter:onActionsEnd() end

function LightEncounter:onCharacterTurn(battler, undo) end

function LightEncounter:beforeStateChange(old, new) end
function LightEncounter:onStateChange(old, new) end

function LightEncounter:onActionSelect(battler, button) end

function LightEncounter:onMenuSelect(state_reason, item, can_select) end
function LightEncounter:onMenuCancel(state_reason, item) end

function LightEncounter:onEnemySelect(state_reason, enemy_index) end
function LightEncounter:onEnemyCancel(state_reason, enemy_index) end

function LightEncounter:onPartySelect(state_reason, party_index) end
function LightEncounter:onPartyCancel(state_reason, party_index) end

function LightEncounter:onDialogueEnd()
    Game.battle:setState("DEFENDINGBEGIN")
end

function LightEncounter:onWavesDone(waves)
    Game.battle:toggleSoul(false)
    Game.battle:setState("DEFENDINGEND", "WAVEENDED")
end

function LightEncounter:onMenuWavesDone(waves) end

function LightEncounter:getDefaultEnemyPositioning()
    local enemies = self.queued_enemy_spawns
    return SCREEN_WIDTH/2 + math.floor((#enemies + 1) / 2) * 120 * ((#enemies % 2 == 0) and -1 or 1), 240
end

function LightEncounter:getDefeatedEnemies()
    return self.defeated_enemies or Game.battle.defeated_enemies
end

function LightEncounter:onGameOver() end
function LightEncounter:onReturnToWorld(events) end

function LightEncounter:update() end
function LightEncounter:draw(fade) end

function LightEncounter:drawBackground()
    Draw.setColor(1, 1, 1, 1)
    local texture = self:getBackgroundImage()
    local x, y = ((SCREEN_WIDTH / 2) - (texture:getWidth() / 2)), 9
    x, y = math.floor(x), math.floor(y)
    Draw.draw(texture, x, y)
end

-- Functions

function LightEncounter:createSoul(x, y, color)
    return LightSoul(x, y, color)
end

function LightEncounter:soulTransition(x, y, speed)
    speed = speed or 17/30

    local target_x, target_y
    if x and y then
        target_x, target_y = x, y
    elseif self.soul_target and type(self.soul_target) == "table" and (self.soul_target.x and self.soul_target.y) then
        target_x, target_y = self.soul_target.x, self.soul_target.y
    else
        -- replace this with non-absolute coords
        target_x, target_y = 49, 455
    end

    local soul_chara = Game.world:getPartyCharacterInParty(Game:getSoulPartyMember())
    local fake_player = FakeClone(soul_chara, soul_chara:getScreenPos())
    fake_player.layer = Game.battle.fader.layer + 1
    Game.battle:addChild(fake_player)

    local noise = Assets.newSound("noise")

    Game.battle.timer:script(function(wait)
        -- Dark frame, only chara
        wait(1/30)
        -- Show soul
        noise:play()
        local player = fake_player.ref
        local x, y = Game.world.soul:localToScreenPos()
        Game.battle:spawnSoul(x, y)
        Game.battle.soul:startTransition()
        wait(2/30)
        -- Hide soul
        Game.battle.soul.visible = false
        wait(2/30)
        -- Show soul
        Game.battle.soul.visible = true
        noise:play()
        wait(2/30)
        -- Hide soul
        Game.battle.soul.visible = false
        wait(2/30)
        -- Show soul
        Game.battle.soul.visible = true
        noise:play()
        wait(2/30)
        -- Remove fake player, move soul
        fake_player:remove()
        Assets.playSound("battlefall")

        Game.battle.soul:slideTo(target_x, target_y, speed)

        wait(17/30)
        -- Wait for fade
        wait(5/30)

        Game.battle.soul:finishTransition()
        Game.battle.soul.x = Game.battle.soul.x - 1
        Game.battle.soul.y = Game.battle.soul.y - 1

        Game.battle.fader:fadeIn(nil, {speed=5/30})
        Game.battle.transitioned = true

        self:onTransitionFinished()
    end)
end

function LightEncounter:addEnemy(enemy, x, y, ...)
    local enemy_obj
    if type(enemy) == "string" then
        enemy_obj = MagicalGlass:createLightEnemy(enemy, ...)
    else
        enemy_obj = enemy
    end

    local enemies = self.queued_enemy_spawns
    if Game.battle and Game.state == "BATTLE" then
        enemies = Game.battle.enemies
    end

    self:positionEnemy(enemy_obj, x, y)

    enemy_obj.encounter = self
    table.insert(enemies, enemy_obj)

    if Game.battle and Game.state == "BATTLE" then
        Game.battle:addChild(enemy_obj)
    end
    return enemy_obj
end

function LightEncounter:positionEnemy(enemy, x, y)
    if x and not y then
        enemy:setPosition(x, self:getDefaultEnemyPositioning()[2])
    elseif x and y then
        enemy:setPosition(x, y)
    else
        enemy:setPosition(self:getDefaultEnemyPositioning())
    end
end

function LightEncounter:attemptFlee(turn_count)
    self:onFleeStart()

    if self.flee_chance > self.flee_threshold then
        self:onFlee()
        return true
    else
        self:increaseFleeChance(turn_count)
        self:onFleeFail()
        return false
    end
end

function LightEncounter:increaseFleeChance(turn_count)
    self.flee_chance = Utils.random(100) + (10 * (turn_count - 1))
end


-- Since a dark encounter and a light encounter could theoretically share IDs,
-- LightEncounter flags must use a different prefix.
function LightEncounter:setFlag(flag, value)
    Game:setFlag("light_encounter#"..self.id..":"..flag, value)
end

function LightEncounter:getFlag(flag, default)
    return Game:getFlag("light_encounter#"..self.id..":"..flag, default)
end

function LightEncounter:addFlag(flag, amount)
    return Game:addFlag("light_encounter#"..self.id..":"..flag, amount)
end

function LightEncounter:canDeepCopy()
    return false
end

return LightEncounter