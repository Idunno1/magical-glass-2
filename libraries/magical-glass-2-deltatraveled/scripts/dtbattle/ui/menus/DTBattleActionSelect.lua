local DTBattleActionSelect, super = Class(LightBattleActionSelect, "DTBattleActionSelect")

function DTBattleActionSelect:init(x, y)
    super.init(self, x, y)

    self.memory = {}
end

function DTBattleActionSelect:setup(member)
    for _,button in ipairs(self.buttons) do
        button:remove()
    end

    self.battler = member
    self.buttons = {}

    local button_types = {"fight", "act", "spell", "item", "mercy"}

    if not self.battler.chara:hasAct() then Utils.removeFromTable(button_types, "act") end
    if not self.battler.chara:hasSpells() then Utils.removeFromTable(button_types, "spell") end

    --button_types = Kristal.callEvent("getLightActionButtons", self.battler, button_types) or button_types

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
            
            local button = DTActionButton(x, 0, ibutton, self.battler)
            if ibutton == "item" and #Game.inventory:getStorage(Game.battle.item_inventory) == 0 then
                button.selectable = false
            end
            table.insert(self.buttons, button)
            self:addChild(button)
        elseif type(ibutton) == "boolean" and ibutton == false then
            -- nothing, used to create an empty space
        else
            ibutton:setPosition(math.floor(66 + ((i - 1) * 156)) + 0.5, 0)
            ibutton.battler = self.battler
            table.insert(self.buttons, ibutton)
            self:addChild(ibutton)
        end
    end

    if self.cursor_memory then
        if not self.buttons[self.current_button] then
            self.current_button = 1
        end
    else
        self.current_button = 1
    end
end

function DTBattleActionSelect:snapSoulToButton()
    if Game.battle.soul and self.buttons then
        local x, y = self:getCurrentButton():getRelativePosFor(Game.battle)
        Game.battle.soul:setPosition(x - 39, y + 9)
    end
end

return DTBattleActionSelect