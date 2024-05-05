local LightBattleUI, super = Class(Object, "LightBattleUI")

function LightBattleUI:init()
    super.init(self)

    self.encounter_text = Textbox(14, 17, SCREEN_WIDTH - 30, SCREEN_HEIGHT - 53, "main_mono", nil, true)
    self.encounter_text.text.default_sound = "battle"
    self.encounter_text.text.line_offset = 5
    self.encounter_text:setText("")
    self.encounter_text.debug_rect = {-30, -12, SCREEN_WIDTH+1, 124}
    Game.battle.arena:addChild(self.encounter_text)

    self.action_select = LightBattleActionSelect(-18, 191)
    Game.battle.arena:addChild(self.action_select)

    self.menu_select = LightBattleMenuSelect()
    Game.battle.arena:addChild(self.menu_select)

    self.enemy_select = LightBattleEnemySelect()
    Game.battle.arena:addChild(self.enemy_select)

    self.party_select = LightBattlePartySelect()
    Game.battle.arena:addChild(self.party_select)

    self.action_displays = {}

    local status_x, status_y = (SCREEN_WIDTH / 2) - 290, SCREEN_HEIGHT - 79
    local status = LightBattleStatusDisplay(status_x, status_y, Game.battle.party[1])
    self:addChild(status)
    table.insert(self.action_displays, status)

    self.attack_box = nil
    self.attacking = false
end

function LightBattleUI:clearEncounterText()
    self.encounter_text:setActor(nil)
    self.encounter_text:setFace(nil)
    self.encounter_text:setFont()
    self.encounter_text:setAlign("left")
    self.encounter_text:setSkippable(true)
    self.encounter_text:setAdvance(true)
    self.encounter_text:setAuto(false)
    self.encounter_text:setText("")
end

function LightBattleUI:setupActionSelect(member)
    if member then
        self.action_select:setup(member)
    end
end

function LightBattleUI:setupMenuSelect()

end

function LightBattleUI:setupEnemySelect()

end

function LightBattleUI:setupPartySelect()

end

function LightBattleUI:onKeyPressed(key)
    self.action_select:onKeyPressed(key)
    self.menu_select:onKeyPressed(key)
    self.enemy_select:onKeyPressed(key)
    self.party_select:onKeyPressed(key)
end


return LightBattleUI