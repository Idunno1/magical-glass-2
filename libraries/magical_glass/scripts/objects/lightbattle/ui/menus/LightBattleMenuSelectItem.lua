local LightBattleMenuSelectItem, super = Class(Object, "LightBattleMenuSelectItem")

function LightBattleMenuSelectItem:init(x, y, options)
    super.init(self, x, y)

    options = options or {}

    self.selectable = options["selectable"] or true

    self.name = ""

    self.name_text = Text("", 0, 0, {font = options["font"] or "main_mono"})
    self:addChild(self.name_text)

    self.name_offset = options["name_offset"] or 32
    self.icon_offset = options["icon_offset"] or 32

    self.party = {}
    self.icons = {}
end

function LightBattleMenuSelectItem:setName(name)
    self.name = name

    if name ~= "" then
        if (#self.party == 0 and #self.icons == 0) then
            if MagicalGlass.light_battle_text_shake then
                name = "[ut_shake]* " .. name
            else
                name = "* " .. name
            end
        else
            if MagicalGlass.light_battle_text_shake then
                name = "[ut_shake]" .. name
            end 
        end
    end

    self.name_text:setText(name)
end

function LightBattleMenuSelectItem:setColor(r, g, b, a)
    self.name_text:setColor(r, g, b, a)
end

function LightBattleMenuSelectItem:setParty(members)
    self.party = {}
    for _,member in ipairs(members) do
        local chara = Game:getPartyMember(member)
        local ox, oy = chara:getHeadIconOffset()
    
        local icon = {
            ["texture"] = Assets.getTexture(chara:getHeadIcons() .. "/head"),
            ["offset_x"] = ox,
            ["offset_y"] = oy
        }
        table.insert(self.party, icon)
    end

    self:refresh()
end

--[[ function LightBattleMenuSelectItem:addIcon(icon, offset_x, offset_y)
    if type(icon) == "string" then
        icon = Assets.getTexture(icon)
    end

    icon = {
        ["texture"] = icon,
        ["offset"] = 
    }

    table.insert(self.icons)
end ]]

function LightBattleMenuSelectItem:refresh()
    local total_icons = #self.party + #self.icons

    self.name_text.x = 0
    if total_icons > 0 then
        self.name_text.x = self.name_text.x + (self.name_offset * total_icons)
    end
    self:setName(self.name)
end

function LightBattleMenuSelectItem:clear()
    self.name = ""
    self.name_text:setText("")
    self.name_text:setColor(COLORS.white)

    self.party = {}
    self.icons = {}

    self:refresh()
end

function LightBattleMenuSelectItem:drawParty()
    for i, party in ipairs(self.party) do
        local x = (((i - 1) * self.icon_offset) + party.offset_x) - 8
        local y = 5 + party.offset_y
        Draw.draw(party.texture, x, y)
    end
end

function LightBattleMenuSelectItem:draw()
    super.draw(self)

    Draw.setColor(COLORS.white)
    if #self.party > 0 then
        self:drawParty()
    end
end

return LightBattleMenuSelectItem