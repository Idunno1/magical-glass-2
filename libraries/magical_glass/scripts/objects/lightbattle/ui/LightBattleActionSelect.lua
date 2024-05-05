local LightBattleActionSelect, super = Class(Object, "LightBattleActionSelect")

function LightBattleActionSelect:init(x, y)
    super.init(self, x, y)

    self.active = false

    self.buttons = {}
    self.current_button = 1

    self.memory = {}
end

function LightBattleActionSelect:hasButtons()
    return self.buttons and #self.buttons > 1
end

function LightBattleActionSelect:setup(member)
    for _,button in ipairs(self.buttons) do
        button:remove()
    end

    self.buttons = {}

    local button_types = {"fight", "act", "spell", "item", "mercy"}

    if not member.chara:hasAct() then Utils.removeFromTable(button_types, "act") end
    if not member.chara:hasSpells() then Utils.removeFromTable(button_types, "spell") end

    button_types = Kristal.callEvent("getLightActionButtons", member, button_types) or button_types

    -- holy fuck this is terrible
    local start_x = (213 / 2) - ((#button_types - 1) * 35 / 2) - 1

    for i, ibutton in ipairs(button_types) do
        if type(ibutton) == "string" then
            local x
            if #button_types <= 4 then
                x = math.floor(67 + ((i - 1) * 156))
                if i == 2 then
                    x = x - 3
                elseif i == 3 then
                    x = x + 1
                end
            else
                x = math.floor(67 + ((i - 1) * 117))
            end
            
            local button = LightActionButton(x, 0, ibutton)
            button.actbox = self
            table.insert(self.buttons, button)
            self:addChild(button)
        elseif type(ibutton) == "boolean" then
            -- nothing, used to create an empty space
        else
            ibutton:setPosition(math.floor(66 + ((i - 1) * 156)) + 0.5, 0)
            ibutton.battler = self.battler
            ibutton.actbox = self
            table.insert(self.buttons, ibutton)
            self:addChild(ibutton)
        end
    end

    self.current_button = Utils.clamp(self.current_button, 1, #self.buttons)

    self.active = true
end

function LightBattleActionSelect:update()
    if self.active and self:hasButtons() then
        for i, button in ipairs(self.buttons) do
            button.hovered = (self.current_button == i)
        end
    elseif not self.active and self:hasButtons() then
        for i, button in ipairs(self.buttons) do
            button.hovered = false
        end
    end

    self:snapSoulToButton()

    super.update(self)
end

function LightBattleActionSelect:onKeyPressed(key)
    if self.active and self:hasButtons() then
        if Input.isConfirm(key) then
            self:select(self.current_button)
        elseif Input.isCancel(key) then
            self:cancel()
        elseif Input.is("left", key) then
            Game.battle:playMoveSound()
            self.current_button = self.current_button - 1
        elseif Input.is("right", key) then
            Game.battle:playMoveSound()
            self.current_button = self.current_button + 1
        end

        if self.current_button < 1 then
            self.current_button = #self.buttons
        end

        if self.current_button > #self.buttons then
            self.current_button = 1
        end
    end
end

function LightBattleActionSelect:select(button)
    Game.battle:playSelectSound()
end

function LightBattleActionSelect:cancel() end

function LightBattleActionSelect:snapSoulToButton()
    if Game.battle.soul and self.buttons then
        local x, y = self.buttons[self.current_button]:getRelativePosFor(Game.battle)
        Game.battle.soul:setPosition(x - 38, y + 9)
    end
end

return LightBattleActionSelect