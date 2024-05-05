local LightBattle, super = Class(Object, "LightBattle")

-- welp

function LightBattle:init()
    super.init(self)

    self.state = "NONE"
    self.substate = "NONE"
    self.state_reason = nil
    self.substate_reason = nil

    self.party = {}
    self:createPartyBattlers()

    self.enemies = {}
    self.enemies_to_remove = {}
    self.enemy_world_characters = {}

    self.money = 0
    self.exp = 0

    self.tension = nil

    self.turn_count = 0

    self.xactions = {}

    self.encounter_context = nil
    self.used_violence = false

    self.current_selecting_index = 0

    self.character_actions = {}

    self.selected_character_stack = {}
    self.selected_action_stack = {}

    self.current_actions = {}
    self.short_actions = {}
    self.current_action_index = 1
    self.processed_action = {}
    self.processing_action = false

    self.attackers = {}
    self.normal_attackers = {}
    self.auto_attackers = {}

    self.attack_done = false
    self.cancel_attack = false
    self.auto_attack_timer = 0

    self.waves = {}
    self.menu_waves = {}
    self.finished_waves = false
    self.finished_menu_waves = false
    self.story_wave = nil

    self.ui_move = Assets.newSound("ui_move")
    self.ui_select = Assets.newSound("ui_select")
    self.vaporized = Assets.newSound("vaporized")

    self.arena = nil
    self.soul = nil
    
    self.battle_ui = nil
    self.menu = nil

    self.camera = Camera(self, SCREEN_WIDTH/2, SCREEN_HEIGHT/2, SCREEN_WIDTH, SCREEN_HEIGHT, false)
    self.cutscene = nil

    self.music = Music()
    self.resume_world_music = false

    self.mask = ArenaMask()
    self:addChild(self.mask)

    self.timer = Timer()
    self:addChild(self.timer)

    self.fader = Fader()
    self.fader.layer = BATTLE_LAYERS["top"]
    self.fader.alpha = 1
    self:addChild(self.fader)

    self.darkify_fader = Fader()
    self.darkify_fader.layer = BATTLE_LAYERS["below_arena"]
    self:addChild(self.darkify_fader)

    self.post_battletext_func = nil
    self.post_battletext_state = "ACTIONSELECT"

    self.textbox_timer = 0
    self.use_textbox_timer = true
end

function LightBattle:playSelectSound()
    self.ui_select:stop()
    self.ui_select:play()
end

function LightBattle:playMoveSound()
    self.ui_move:stop()
    self.ui_move:play()
end

function LightBattle:playVaporizedSound()
    self.vaporized:stop()
    self.vaporized:play()
end

function LightBattle:createPartyBattlers()
    local battler = LightPartyBattler(Game.party[1])
    self:addChild(battler)
    table.insert(self.party, battler)
end

function LightBattle:postInit(state, encounter)
    self.state = state

    if type(encounter) == "string" then
        self.encounter = MagicalGlass:createLightEncounter(encounter)
    else
        self.encounter = encounter
    end

    if self.encounter:includes(Encounter) then
        error("Attempted to use Encounter in a LightBattle. Convert the encounter file to LightEncounter.")
    end

    if Game.world.music:isPlaying() and self.encounter.music then
        self.resume_world_music = true
        Game.world.music:pause()
    end

    if self.encounter.queued_enemy_spawns then
        for _,enemy in ipairs(self.encounter.queued_enemy_spawns) do
            table.insert(self.enemies, enemy)
            table.insert(self.enemies_index, enemy)
            self:addChild(enemy)
        end
    end

    self.arena = LightArena(SCREEN_WIDTH/2, 385)
    self.arena.layer = BATTLE_LAYERS["ui"]
    self:addChild(self.arena)

    self.battle_ui = LightBattleUI()
    self.battle_ui.layer = BATTLE_LAYERS["ui"]
    self:addChild(self.battle_ui)

    self.menu = self.battle_ui.menu

--[[     self.tension_bar = LightTensionBar(29, 53, true)
    if self.tension then
        self.tension_bar.visible = false
    end
    self:addChild(self.tension_bar) ]]

    if Game.encounter_enemies then
        for _,from in ipairs(Game.encounter_enemies) do
            if not isClass(from) then
                local enemy = self:parseEnemyIdentifier(from[1])
                from[2].battler = enemy
                self.enemy_world_characters[enemy] = from[2]
            else
                for _,enemy in ipairs(self.enemies) do
                    if enemy.actor and from.actor and enemy.actor.name == from.actor.name then
                        from.battler = enemy
                        self.enemy_world_characters[enemy] = from
                        break
                    end
                end
            end
        end
    end

    if self.encounter_context and self.encounter_context:includes(ChaserEnemy) then
        for _,enemy in ipairs(self.encounter_context:getGroupedEnemies(true)) do
            enemy:onEncounterStart(enemy == self.encounter_context, self.encounter)
        end
    end

    if state == "TRANSITION" then
        self.encounter:onTransition()
    else
        self.fader.alpha = 0
        self.encounter:onTransitionFinished()

        if state ~= "INTRO" then
            self:nextTurn()
        end
    end

    if not self.encounter:onBattleInit() then
        self:setState(state)
    end
end

function LightBattle:getSoulLocation(always_player)
    if self.soul and (not always_player) then
        return self.soul:getPosition()
    else
        -- replace this with non-absolute coords
        return 49, 455
    end
end

function LightBattle:spawnSoul(x, y)
    local bx, by = self:getSoulLocation()
    x = x or bx
    y = y or by
    local color = {Game:getSoulColor()}
    if not self.soul then
        self.soul = self.encounter:createSoul(x, y, color, {sprite = "player/heart_light"})
        self.soul.alpha = 1
        self:addChild(self.soul)
    end
end

function LightBattle:toggleSoul(active)
    if not self.soul then
        self:spawnSoul(self.arena:getCenter())
    end
    self.soul:toggle(active)
end

function LightBattle:toggleTension(active)
    if active == nil then
        self.tension = not self.tension
    else
        self.tension = active
    end

    self.tension_bar.visible = self.tension

    if self.soul then
        self.soul:toggleGrazing(active)
    end
end

function LightBattle:setEncounterText(text)
    self.battle_ui.encounter_text:setText("[voice:battle]" .. text)

end

function LightBattle:nextTurn()
    self.turn_count = self.turn_count + 1

    if self.turn_count > 1 then
        if self.encounter:onTurnEnd() then
            return
        end
        for _,enemy in ipairs(self:getActiveEnemies()) do
            if enemy:onTurnEnd() then
                return
            end
        end
    end

    self.character_actions = {}
    self.current_actions = {}
    self.processed_action = {}

    self.attackers = {}
    self.normal_attackers = {}
    self.auto_attackers = {}

--[[     while not (self.party[self.current_selecting]:isActive()) do
        self.current_selecting = self.current_selecting + 1
        if self.current_selecting > #self.party then
            print("WARNING: nobody up! this shouldn't happen...")
            self.current_selecting = 1
            break
        end
    end ]]

    if self.state ~= "ACTIONSELECT" then
        self:setState("ACTIONSELECT")
    end
end

function LightBattle:setState(state, reason)
    local old = self.state
    self.state = state
    self.state_reason = reason
    self:onStateChange(old, self.state)
end

function LightBattle:onStateChange(old, new)
    local result = self.encounter:beforeStateChange(old, new)
    if result or self.state ~= new then
        return
    end

    if new == "INTRO" then
        self:nextTurn()
    elseif new == "ACTIONSELECT" then
        self.arena.layer = BATTLE_LAYERS["ui"]

        if not self.soul then
            self:spawnSoul()
        end

        self.battle_ui:setupActionSelect(self.party[1])

        self:setEncounterText("* Test Test Test Test")
    end
end

function LightBattle:onSubStateChange(old, new) end

function LightBattle:isHighlighted()
    return false
end

function LightBattle:isWorldHidden()
    return true
end


function LightBattle:draw()
    if self.encounter:getBackgroundImage() then
        self.encounter:drawBackground()
    end

    super.draw(self)

    self.encounter:draw()

--[[     if DEBUG_RENDER then
        self:drawDebug()
    end ]]
end

function LightBattle:onKeyPressed(key)
    self.battle_ui:onKeyPressed(key)
end

return LightBattle