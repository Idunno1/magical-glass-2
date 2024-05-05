MagicalGlass = {}
local lib = MagicalGlass

MagicalGlass.PALETTE = {
    ["hp"]       = COLORS.yellow,
    ["hp_back"]  = COLORS.red,

    ["karma"]    = { 192/255, 0, 0, 1 },

    ["defend"]   = COLORS.aqua,

    ["en"]       = { 184/255, 213/255, 70/255, 1 },
    ["en_back"]  = { 62/255, 283/255, 100/255, 1 }
}
setmetatable(MagicalGlass.PALETTE, {
    __index = function (t, i) return Kristal.callEvent("getMGPaletteColor", i) or palette_data[i] end,
    __newindex = function (t, k, v) palette_data[k] = v end,
})

-- Events

function lib:init()
    print("oh boy here we go again")
    print("Loaded Magical Glass 2!")

    self:initRegistry()
    for _,path,_ in Registry.iterScripts("init") do
        Kristal.executeLibScript("magical-glass", path)
    end
end

function lib:save(data)
    data.magical_glass_2 = {}
    data.magical_glass_2["default_battle_system"] = self.default_battle_system
    data.magical_glass_2["light_battle_mercy_messages"] = self.light_battle_mercy_messages

    data.magical_glass_2["__current_battle_system"] = self.__current_battle_system
end

function lib:load(data, is_new_file)
    if not data.magical_glass_2 then
        self.default_battle_system = Kristal.getLibConfig("magical-glass", "defaultBattleSystem") or "deltarune"
        self.light_battle_mercy_messages = Kristal.getLibConfig("magical-glass", "lightBattleMercyMessages") or false

        self.__current_battle_system = nil
    else
        self.default_battle_system = data.magical_glass_2["default_battle_system"]
        self.light_battle_mercy_messages = data.magical_glass_2["light_battle_mercy_messages"]

        self.__current_battle_system = data.magical_glass_2["__current_battle_system"]
    end
end

function lib:registerDebugOptions(debug)
    debug:registerMenu("encounter_select", "Encounter Select")

    debug:registerOption("encounter_select", "Start Dark Encounter", "Start a dark encounter.", function()
        debug:enterMenu("dark_encounter_select", 0)
    end)
    debug:registerOption("encounter_select", "Start Light Encounter", "Start a light encounter.", function()
        debug:enterMenu("light_encounter_select", 0)
    end)

    debug:registerMenu("dark_encounter_select", "Select Dark Encounter", "search")
    for id,_ in pairs(Registry.encounters) do
        debug:registerOption("dark_encounter_select", id, "Start this encounter.", function()
            Game:encounterDark(id, true, nil, nil, false)
            debug:closeMenu()
        end)
    end

    debug:registerMenu("light_encounter_select", "Select Light Encounter", "search")
    for id,_ in pairs(self.light_encounters) do
        if id ~= "_nobody" then
            debug:registerOption("light_encounter_select", id, "Start this encounter.", function()
                Game:encounterLight(id, true, nil, nil, true)
                debug:closeMenu()
            end)
        end
    end
end

function lib:unload()
    MagicalGlass = nil
end

-- Registry

function lib:initRegistry()
    self.random_encounters = {}
    self.light_encounters = {}
    self.light_enemies = {}
    self.light_shops = {}

    for _,path,rnd_enc in Registry.iterScripts("battle/randomencounters") do
        assert(rnd_enc ~= nil, '"randomencounters/'..path..'.lua" does not return value')
        rnd_enc.id = rnd_enc.id or path
        self.random_encounters[rnd_enc.id] = rnd_enc
    end

    for _,path,light_enc in Registry.iterScripts("battle/lightencounters") do
        assert(light_enc ~= nil, '"lightencounters/'..path..'.lua" does not return value')
        light_enc.id = light_enc.id or path
        self.light_encounters[light_enc.id] = light_enc
    end

    for _,path,light_enemy in Registry.iterScripts("battle/lightenemies") do
        assert(light_enemy ~= nil, '"lightenemies/'..path..'.lua" does not return value')
        light_enemy.id = light_enemy.id or path
        self.light_enemies[light_enemy.id] = light_enemy
    end

    for _,path,light_shop in Registry.iterScripts("lightshops") do
        assert(light_shop ~= nil, '"lightshops/'..path..'.lua" does not return value')
        light_shop.id = light_shop.id or path
        self.light_shops[light_shop.id] = light_shop
    end
end

function lib:getRandomEncounter(id)
    return self.random_encounters[id]
end

function lib:createRandomEncounter(id, ...)
    if self.random_encounters[id] then
        return self.random_encounters[id](...)
    else
        error("Attempt to create non existent random encounter \"" .. tostring(id) .. "\"")
    end
end

function lib:getLightEncounter(id)
    return self.light_encounters[id]
end

function lib:createLightEncounter(id, ...)
    if self.light_encounters[id] then
        return self.light_encounters[id](...)
    else
        error("Attempt to create non existent light encounter \"" .. tostring(id) .. "\"")
    end
end

function lib:getLightEnemy(id)
    return self.light_enemies[id]
end

function lib:createLightEnemy(id, ...)
    if self.light_enemies[id] then
        return self.light_enemies[id](...)
    else
        error("Attempt to create non existent light enemy \"" .. tostring(id) .. "\"")
    end
end

-- Functions

function lib:getCurrentBattleSystem()
    return self.__current_battle_system
end

return lib