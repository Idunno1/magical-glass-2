local DTBattle, super = Class(LightBattle, "DTBattle")

function DTBattle:init()
    super.init(self)

    self.tension_bar = nil
end

function DTBattle:createPartyBattlers()
    for i = 1, math.min(3, #Game.party) do
        local battler = DTPartyBattler(Game.party[i])
        self:addChild(battler)
        table.insert(self.party, battler)
    end
end

function DTBattle:postInit(state, encounter)
    self.state = state

    if type(encounter) == "string" then
        self.encounter = MagicalGlass:createLightEncounter(encounter)
    else
        self.encounter = encounter
    end

    if self.encounter:includes(Encounter) then
        error("Attempted to use Encounter in a DTBattle. Convert the encounter file to LightEncounter.")
    end

    if Game.world.music:isPlaying() and self.encounter.music then
        self.resume_world_music = true
        Game.world.music:pause()
    end

    if self.encounter.queued_enemy_spawns then
        for _,enemy in ipairs(self.encounter.queued_enemy_spawns) do
            table.insert(self.enemies, enemy)
            table.insert(self.enemy_index, enemy)
            self:addChild(enemy)
        end
    end
    
    self.tension = true
    self.can_defend = true
    self.can_flee = false

    self.tension_bar = DTTensionBar(29, 54)
    self:addChild(self.tension_bar)

    self.arena = LightArena(SCREEN_WIDTH/2 - 1, 419, nil, false)
    self.arena.sprite:setColor(MagicalGlassDeltatraveled:getArenaColor())
    self.arena.layer = BATTLE_LAYERS["ui"]
    self:addChild(self.arena)

    self.battle_ui = DTBattleUI()
    self.battle_ui.layer = BATTLE_LAYERS["ui"]
    if self.encounter.story then
        self.battle_ui:setupStory()
    else
        self.battle_ui:setup()
    end
    self:addChild(self.battle_ui)

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
        self.fader:fadeIn({speed = 5/30})
    end

    if not self.encounter:onBattleInit() then
        self:setState(state)
    end
end

function DTBattle:onStateChange(old, new)
--[[     local event_result = Kristal.callEvent(MagicalGlass.EVENT.beforeLightBattleStateChange, old, new, self.state_reason, self.state_extra)
    local enc_result = self.encounter:beforeStateChange(old, new, self.state_reason, self.state_extra)
    if event_result or enc_result or self.state ~= new then
        Kristal.callEvent(MagicalGlass.EVENT.onLightBattleStateChange, old, new, self.state_reason, self.state_extra)
        self.encounter:onStateChange(old, new, self.state_reason, self.state_extra)
        return
    end ]]

    if new == "INTRO" then
        if self.encounter.story then
            self:setState("STORY")
        else
            self:nextTurn()
        end
        self.encounter:onBattleStart()
        if self.encounter.music then
            self.music:play(self.encounter.music)
        end
    elseif new == "STORY" then
        self:spawnSoul(self.encounter:getSoulTarget())
        self.soul.can_move = true
        if self.encounter:getStoryCutscene() then
            self:startCutscene(self.encounter:getStoryCutscene()):after(function()
                self:setState("TRANSITIONOUT")
            end)
        end
    elseif new == "ACTIONSELECT" then
        Input.clear("cancel", true)

        if self.current_selecting_index < 1 or self.current_selecting_index > #self.party then
            self:nextTurn()
            if self.state ~= "ACTIONSELECT" then
                return
            end
        end
        
        self.arena.layer = BATTLE_LAYERS["ui"]

        self:toggleSoul(true, false)

        if self.state_reason ~= "CANCEL" then
            local party = self:getCurrentlySelectingMember()
            party.chara:onActionSelect(party, false)
            self.encounter:onCharacterTurn(party, false)

            self.battle_ui:setupActionSelect(party)
        end

        self.battle_ui:clearEncounterText()
        self.battle_ui.encounter_text.text.line_offset = 5
        self:setEncounterText(self.battle_ui.current_encounter_text)
    elseif new == "ENEMYSELECT" then
        self:clearEncounterText()

        if self.state_reason == "ATTACK" then
            self.battle_ui:setupAttackEnemySelect(self.enemy_index)
        elseif self.state_reason == "ACT" then
            self.battle_ui:setupACTEnemySelect(self.enemy_index)
        elseif self.state_reason == "SPELL" then
            self.battle_ui:setupSpellEnemySelect(self.enemy_index, self.state_extra["spell"])
        elseif self.state_reason == "XACT" then
            self.battle_ui:setupXActionEnemySelect(self.enemy_index, self.state_extra["x_act"])
        end
    elseif new == "PARTYSELECT" then
        self:clearEncounterText()

        if self.state_reason == "SPELL" then
            if not self.allow_party or #self.party == 1 then
                self:pushAction("SPELL", self.party[1], self.state_extra["spell"])
            else
                self.battle_ui:setupSpellPartySelect(self.party, self.state_extra["spell"])
            end            
        elseif self.state_reason == "ITEM" then
            if not self.allow_party or #self.party == 1 then
                self:pushAction("ITEM", self.party[1], self.state_extra["item"])
            else
                self.battle_ui:setupItemPartySelect(self.party, self.state_extra["item"])
            end
        end
    elseif new == "MENUSELECT" then
        self:clearEncounterText()

        if self.state_reason == "ACT" then
            if self.state_extra.acts then
                self.battle_ui:setupACTSelect(self.state_extra["enemy"], self.state_extra["acts"])
            end
        elseif self.state_reason == "SPELL" then
            self.battle_ui:setupSpellSelect(self.state_extra["user"])
        elseif self.state_reason == "ITEM" then
            if not MagicalGlass.list_item_menu then
                self.battle_ui:setupItemSelect(Game.inventory:getStorage(self.item_inventory))
            else
                self.battle_ui:setupListItemSelect(Game.inventory:getStorage(self.item_inventory))
            end
        elseif self.state_reason == "MERCY" then
            self.battle_ui:setupMercySelect()
        end
    elseif new == "ACTIONS" then
        self:clearEncounterText()
        self:toggleSoul(false)
        self.battle_ui:clearStack()
        self.battle_ui.action_select:unselect()

        if self.state_reason ~= "DONTPROCESS" then
            self:tryProcessNextAction()
        end
    elseif new == "ATTACKING" then
        self:clearEncounterText()
        self:toggleSoul(false)

        local enemies_left = self:getActiveEnemies()

        if #enemies_left > 0 then
            for i, battler in ipairs(self.party) do
                local action = self.queued_actions[i]
                if action and action.action == "ATTACK" then
                    self:beginAction(action)
                    table.insert(self.attackers, battler)
                    table.insert(self.normal_attackers, battler)
                end
            end
        end

        self.auto_attack_timer = 0

        if #self.attackers == 0 then
            self.attack_done = true
            self:setState("ACTIONSDONE")
        else
            self.attack_done = false
            self.battle_ui:beginAttack()
        end
    elseif new == "ENEMYDIALOGUE" then
        self:clearEncounterText()
        self:toggleSoul(false)
        self.battle_ui:clearStack()
        self.battle_ui.action_select:unselect()

        self.current_selecting_index = 0
        self.enemy_dialogue_timer = 3 * 30
        self.use_dialogue_timer = false

        local active_enemies = self:getActiveEnemies()
        if #active_enemies == 0 then
            self:setState("VICTORY")
            return
        end

        for _,enemy in ipairs(active_enemies) do
            enemy.current_target = enemy:getTarget()
        end

        self:setupWaves()

        local cutscenes = {self.encounter:getDialogueCutscene()}
        if #cutscenes > 0 then
            self:startCutscene(unpack(cutscenes)):after(function()
                self:setState("DIALOGUEEND")
            end)
        else
            local playing_dialogue = false
            for _,enemy in ipairs(active_enemies) do
                local dialogue = enemy:getEnemyDialogue()
                if dialogue then
                    playing_dialogue = true
                    local bubble = enemy:spawnSpeechBubble(dialogue)
                    bubble:setSkippable(false)
                    table.insert(self.enemy_dialogue, bubble)
                end
                if not playing_dialogue then
                    self:setState("DIALOGUEEND")
                end
            end
        end
    elseif new == "DIALOGUEEND" then
        if not self.soul.visible then
            self:toggleSoul(true, true)
        end

        self:clearEncounterText()
        self.battle_ui:clearStack()
        self.battle_ui.action_select:unselect()

        -- make defending take effect
        for i, battler in ipairs(self.party) do
            local action = self.queued_actions[i]
            if action and action.action == "DEFEND" then
                self:beginAction(action)
                self:processAction(action)
            end
        end

        if not self.encounter:onDialogueEnd() then
            self:setState("DEFENDINGBEGIN")
        end
    elseif new == "DEFENDINGBEGIN" then
        local dont_change = false
        for _,wave in ipairs(self.waves) do
            if wave.arena_shape then
                dont_change = true
                break
            end
        end
        
        if not dont_change then
            self.arena:setTargetSize(nil, self.begin_arena_height)
            self.begin_arena_height = nil
        else
            self.begin_arena_height = nil
        end

        self.soul.can_move = true

        self:setState("DEFENDING")
    elseif new == "DEFENDING" then
        self.wave_length = 0
        self.wave_timer = 0

        for _,wave in ipairs(self.waves) do
            wave.encounter = self.encounter

            self.wave_length = math.max(self.wave_length, wave.time)

            wave:onStart()
            wave.active = true
        end

        self.soul:onWaveStart()
    elseif new == "DEFENDINGEND" then
        self:resetArena()
    elseif new == "TURNDONE" then
        for _,wave in ipairs(self.waves) do
            wave:onArenaExit()
        end
        self.waves = {}

        Input.clear("cancel", true)
        self:nextTurn()
    elseif new == "FLEESTART" then
        self:clearEncounterText()
        self:toggleSoul(true, false)
        self.battle_ui:clearStack()
        self.battle_ui.action_select:unselect()
    
        self.current_selecting = 0

        for _,party in ipairs(self.party) do
            self:removeQueuedAction(self:getPartyIndex(party))
        end

        if MagicalGlass.always_flee or self.encounter:attemptFlee(self.turn_count) then
            self.ui_select_sound:stop()
            self:setState("FLEEING")
        else
            self:setState("ACTIONSDONE")
        end
    elseif new == "FLEEING" then
        self:handleFlee()
    elseif new == "VICTORY" then
        self:handleVictory()
    elseif new == "TRANSITIONOUT" then
        self.ended = true
        self.current_selecting = 0
        if self.encounter_context and self.encounter_context:includes(ChaserEnemy) then
            for _,enemy in ipairs(self.encounter_context:getGroupedEnemies(true)) do
                enemy:onEncounterTransitionOut(enemy == self.encounter_context, self.encounter)
            end
        end

        -- toby
        if self:getSubState() == "VICTORY" then
            self:returnToWorld()
            Game.fader:fadeIn(nil, {alpha = 1, speed = 7/30})
        else
            Game.fader:transition(function() self:returnToWorld() end, nil, {speed = 10/30})
        end
    end

    local should_end_waves = true
    if Utils.containsValue(self.wave_end_states, new) then
        for _,wave in ipairs(self.waves) do
            if wave:beforeEnd() then
                should_end_waves = false
            end
        end
        if should_end_waves then
            for _,battler in ipairs(self.party) do
                battler.targeted = false
            end
        end
    end

    if old == "DEFENDING" and new ~= "ENEMYDIALOGUE" and should_end_waves then
        self:clearWaves()
        
        if self:hasCutscene() then
            self.cutscene:after(function()
                self:setState("TURNDONE", "WAVEENDED")
            end)
        else
            self.timer:after(15/30, function()
                self:setState("TURNDONE", "WAVEENDED")
            end)
        end
    end

--[[     Kristal.callEvent(MagicalGlass.EVENT.onLightBattleStateChange, old, new, self.state_reason, self.state_extra)
    self.encounter:onStateChange(old, new, self.state_reason, self.state_extra) ]]
end

function DTBattle:setupWaves()
    self.arena.y = self.arena.init_y - 34

    if self.state_reason then -- self.state_reason is used to force a wave in this context
        self:setWaves(self.state_reason)
        local enemy_found = false
        for i, enemy in ipairs(self.enemies) do
            if Utils.containsValue(enemy.waves, self.state_reason[1]) then
                enemy.selected_wave = self.state_reason[1]
                enemy_found = true
            end
        end
        if not enemy_found then
            self.enemies[love.math.random(1, #self.enemies)].selected_wave = self.state_reason[1]
        end
    else
        self:setWaves(self.encounter:getNextWaves())
    end

    local has_arena = true 
    local dont_change_shape = false

    local has_soul = false  

    local instant_transition = false

    local soul_x, soul_y
    local soul_offset_x, soul_offset_y

    local arena_x, arena_y
    local arena_offset_x, arena_offset_y
    local arena_w, arena_h
    local arena_shape

    local center_x, center_y

    for _,wave in ipairs(self.waves) do
        if not wave.has_arena then
            has_arena = false
        end

        if wave.dont_change_shape then
            dont_change_shape = true
        end

        if wave.has_soul then
            has_soul = true
        end

        if wave.instant_transition_in then
            instant_transition = true
        end

        soul_x = wave.soul_start_x or soul_x
        soul_y = wave.soul_start_y or soul_y

        soul_offset_x = wave.soul_offset_x or soul_offset_x
        soul_offset_y = wave.soul_offset_y or soul_offset_y

        arena_x = wave.arena_x or arena_x
        arena_y = wave.arena_y or arena_y

        arena_offset_x = wave.arena_offset_x or arena_offset_x
        arena_offset_y = wave.arena_offset_y or arena_offset_y

        if wave.arena_shape then
            arena_shape = wave.arena_shape
        else
            arena_w = wave.arena_width and math.max(wave.arena_width, arena_w or 0) or arena_w
            arena_h = wave.arena_height and math.max(wave.arena_height, arena_h or 0) or arena_h
        end

        wave:beforeStart()
    end

    if has_arena then
        if not dont_change_shape then
            if not arena_shape then
                arena_x, arena_y = (arena_x or self.arena.x) + (arena_offset_x or 0), (arena_y or self.arena.y) + (arena_offset_y or 0)
                arena_w, arena_h = arena_w or 160, arena_h or 130

                self.arena:setPosition(arena_x, arena_y)

                if self.encounter.story or instant_transition then
                    self.arena:setSize(arena_w, arena_h)
                else
                    self.arena:setTargetSize(arena_w)
                    self.begin_arena_height = arena_h
                end
            else
                self.arena:setShape(arena_shape)
            end
        end
        center_x, center_y = self.arena:getCenter()
    else
        self.arena:disable()
        center_x, center_y = self.arena:getCenter()
    end

    if has_soul then
        soul_x = soul_x or (soul_offset_x and center_x + soul_offset_x)
        soul_y = soul_y or (soul_offset_y and center_y + soul_offset_y)
        self.soul:setPosition(soul_x or center_x, soul_y or center_y)
        self.soul.can_move = false

        self.soul_appear_timer = 2
    end
end

function DTBattle:resetArena()
    local dont_change_shape
    local instant_transition

    if self.arena.y ~= self.arena.init_y then self.arena.y = self.arena.init_y end

    for _,wave in ipairs(self.waves) do
        if wave.dont_change_shape then
            dont_change_shape = true
        end
        if wave.instant_transition_out then
            instant_transition = true
        end
    end

    if not dont_change_shape then
        if instant_transition then
            if self.arena.x ~= self.arena.init_x then self.arena.x = self.arena.init_x end

            self.arena:setSize(self.arena.init_width, self.arena.init_height)
        else
            if self.arena.height >= self.arena.init_height then
                self.arena:resetPosition(function()
                    self.arena:setTargetSize(nil, self.arena.init_height, function()
                        self.arena:setTargetSize(self.arena.init_width)
                    end)
                end)
            else
                self.arena:resetPosition(function()
                    self.arena:setTargetSize(self.arena.init_width, nil, function()
                        self.arena:setTargetSize(nil, self.arena.init_height)
                    end)
                end)
            end
        end
    end

    self.arena:enable()
end

function DTBattle:onKeyPressed(key)
    if Kristal.Config["debug"] then
        if Input.ctrl() then
            -- Full heal
            if key == "h" then
                Assets.playSound("power")
                for _,party in ipairs(self.party) do
                    party:heal(math.huge)
                end
            end
            -- Force Victory
            if key == "y" then
                Input.clear(nil, true)
                --self.forced_victory = true
                if self.state == "DEFENDING" then
                    if not self.encounter:onWavesDone() then
                        self:toggleSoul(false)
                        self:setState("DEFENDINGEND", "WAVEENDED")
                    end
                end
                self:setState("VICTORY")
            end
            -- Mute Music
            -- todo: make this persist between reloads
            if key == "m" then
                if self.music then
                    if self.music:isPlaying() then
                        self.music:pause()
                    else
                        self.music:resume()
                    end
                end
            end
            -- Insta-end the DEFENDING phase
            if key == "f" and self.state == "DEFENDING" then
                if not self.encounter:onWavesDone() then
                    self:toggleSoul(false)
                    self:setState("DEFENDINGEND", "WAVEENDED")
                end
            end
            -- "You dare bring light into my lair? You must die!" -Ganon 1993
            if key == "j" and Input.shift() then
                if self.soul then
                    Game:gameOver(self:getSoulPosition())
                else
                    Game:gameOver()
                end
            end
            -- Gain a lot of TP, enough for a Snowgrave
            if key == "k" then
                Game:setTension(Game:getMaxTension() * 2, true)
            end
            -- SOUL noclip (or phasing, if you're toby)
            if key == "n" then
                NOCLIP = not NOCLIP
            end
        end
    end

    self.battle_ui:onKeyPressed(key)
end

return DTBattle