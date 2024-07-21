local LightBattlePartySelectItem, super = Class(Object, "LightBattlePartySelectItem")

function LightBattlePartySelectItem:init(x, y, options)
    super.init(self, x, y)

    options = options or {}

    self.name = Text("", 0, 0, {font = options["name_font"] or "main_mono"})
    self:addChild(self.name)

    self.health = nil
    self.max_health = nil
end

function LightBattlePartySelectItem:setName(name)
    name = "* " .. name

    if MagicalGlass.light_battle_text_shake then
        self.name:setText("[ut_shake]"..name)
    else
        self.name:setText(name)
    end
end

function LightBattlePartySelectItem:clear()
    self.name:setText("")

    self.health = nil
    self.max_health = nil
end

function LightBattlePartySelectItem:draw()
    if self.health then
        self:drawUndertaleGauge()
    end

    super.draw(self)
end

function LightBattlePartySelectItem:drawUndertaleGauge()
    local name_width = 0
    for _,member in ipairs(Game.battle.party) do
        if member and string.len(member.chara:getName()) > name_width then
            name_width = string.len(member.chara:getName())
        end
    end

    local gauge_x = 90 + (name_width * 16)
    local gauge_width = 101
    local health_percent = (self.health / self.max_health) * gauge_width

    Draw.setColor(MagicalGlass.PALETTE["menu_health_back"])
    Draw.rectangle("fill", gauge_x, 10, gauge_width, 17)

    Draw.setColor(MagicalGlass.PALETTE["menu_health"])
    Draw.rectangle("fill", gauge_x, 10, health_percent, 17)
end

return LightBattlePartySelectItem