local LightBattleMenuSelect, super = Class(Object, "LightBattleMenuSelect")

function LightBattleMenuSelect:init()
    super.init(self)

    self.menu_items = {}

    self.current_menu_x = 1
    self.current_menu_y = 1
    self.current_menu_columns = nil
    self.current_menu_rows = nil

    self.selected_item = nil
    self.selected_spell = nil
    self.selected_xaction = nil

    self.memory = {}
end

function LightBattleMenuSelect:setup(items)

end

function LightBattleMenuSelect:addItem(item)
    item = {
        ["name"] = item.name or "",
        ["shortname"] = item.shortname or nil,
        ["seriousname"] = item.seriousname or nil,
        ["tp"] = item.tp or 0,
        ["unusable"] = item.unusable or false,
        ["description"] = item.description or "",
        ["party"] = item.party or {},
        ["color"] = item.color or {1, 1, 1, 1},
        ["data"] = item.data or nil,
        ["callback"] = item.callback or function() end,
        ["highlight"] = item.highlight or nil,
        ["icons"] = item.icons or nil,
        ["special"] = item.special or nil
    }

    item.object = self:createMenuObject(item)

    table.insert(self.menu_items, item)
end

function LightBattleMenuSelect:createMenuObject(item)
    local object = Text(item.name)
    return self:addChild(object)
end

function LightBattleMenuSelect:clearMenuObjects()
    for _,obj in ipairs(self.menu_objects) do
        obj:remove()
    end
    print(#self.menu_objects)
end

function LightBattleMenuSelect:onKeyPressed(key)

end

return LightBattleMenuSelect