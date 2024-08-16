local DTBattleUI, super = Class(LightBattleUI, "DTBattleUI")

function DTBattleUI:init()
    super.init(self)

    self.current_encounter_text = Game.battle.encounter.text

    self.encounter_text = UnderTextbox(15, 19, SCREEN_WIDTH - 30, SCREEN_HEIGHT - 53, "main_mono", nil, true)
    self.encounter_text.text.default_voice = "battle"
    self.encounter_text.text.line_offset = 5
    self.encounter_text:setText("")
    self.encounter_text.debug_rect = {-30, -12, SCREEN_WIDTH+1, 124}
    Game.battle.arena:addChild(self.encounter_text)

--[[     self.flee_text = Text("", 63, 15, SCREEN_WIDTH - 30, SCREEN_HEIGHT - 53, {font = "main_mono"})
    self.flee_text.line_offset = 4
    self.flee_text.debug_rect = {-30, -12, SCREEN_WIDTH+1, 124}
    self.flee_text.visible = false
    Game.battle.arena:addChild(self.flee_text) ]]

    self.action_displays = {}

    self.attack_target = nil
    self.attacking = false

    self.menu_stack = {}

    self.action_select = nil
    self.menu_select = nil
    self.list_menu_select = nil
    self.enemy_select = nil
    self.party_select = nil
end

function DTBattleUI:setupMenus()
    local action_select_x = Game.battle.arena.x - Game.battle.arena.width / 2
    self.action_select = DTBattleActionSelect(action_select_x - 16, Game.battle.arena.y + 26, true)
    Game.battle:addChild(self.action_select)

    self.menu_select = LightBattleMenuSelect(63, 17, true)
    Game.battle.arena:addChild(self.menu_select)

    self.list_menu_select = LightBattleItemSelect(63, 17)
    Game.battle.arena:addChild(self.list_menu_select)

    self.enemy_select = DTBattleEnemySelect(63, 17, true)
    Game.battle.arena:addChild(self.enemy_select)

    self.party_select = LightBattlePartySelect(63, 17, true)
    Game.battle.arena:addChild(self.party_select)
end

function DTBattleUI:setupActionDisplays()
    local size_offset = 40
    local box_gap = 5

    if #Game.battle.party == 2 then
        size_offset = 100
        box_gap = 75
    elseif #Game.battle.party == 1 then
        size_offset = 230
    end

    for i,battler in ipairs(Game.battle.party) do
        local box_x, box_y = size_offset + (i - 1) * (185 + box_gap), 253.5
        local status_box = DTStatusBox(box_x, box_y, i, battler)
        status_box.layer = BATTLE_LAYERS["below_ui"]
        Game.battle:addChild(status_box)
        battler.status_box = status_box
        table.insert(self.action_displays, status_box)
    end
end

return DTBattleUI