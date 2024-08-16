MagicalGlassDeltatraveled = {}
local lib = MagicalGlassDeltatraveled

lib.FLAVORS = {
    ["plain"] = {button = {1, 127/255, 39/255, 1}, button_h = COLORS.yellow, select_text = COLORS.yellow, arena = COLORS.white}
}

function lib:init()
    print("Loaded Magical Glass Deltatraveled!")

    for _,path in ipairs(Utils.getFilesRecursive(self.info.path.."/scripts/init")) do
        love.filesystem.load(self.info.path .. "/scripts/init/" .. path)()
    end
end

function lib:save(data)
    data.magical_glass_2_deltatraveled = {}
    data.magical_glass_2_deltatraveled["flavor"] = self.flavor
end

function lib:load(data, is_new_file)
    if not data.magical_glass_2_deltatraveled then
        self.flavor = "plain"
    else
        self.flavor = data.magical_glass_2_deltatraveled["flavor"]
    end
end

function lib:unload()
    MagicalGlassDeltatraveled = nil
end

function lib:getConfig(config)
    return Kristal.getLibConfig(self.info.id, config)
end

function lib:getCurrentFlavor()
    return lib.FLAVORS[self.flavor]
end

function lib:setFlavor(flavor)
    if lib.FLAVORS[flavor] then
        self.flavor = flavor
    end
end

-- todo: user-added flavors

function lib:getButtonColor()
    return Utils.unpackColor(self:getCurrentFlavor().button)
end

function lib:getHoveredButtonColor()
    return Utils.unpackColor(self:getCurrentFlavor().button_h)
end

-- reminder to actually implement this
function lib:getSelectedTextColor()
    return Utils.unpackColor(self:getCurrentFlavor().select_text)
end

function lib:getArenaColor()
    return Utils.unpackColor(self:getCurrentFlavor().arena)
end

function lib:onRegisterObjects()
    for _,path,object in Registry.iterScripts("dtbattle", true) do
        local id = object.id or path
        Registry.objects[id] = object
        Registry.registerGlobal(id, object)
    end
end

function lib:registerDebugOptions(debug)
    debug:registerOption("encounter_select", "Start DT Encounter", "Start a Deltatraveler encounter.", function()
        debug:enterMenu("dt_encounter_select", 0)
    end)

    debug:registerMenu("dt_encounter_select", "Select DT Encounter", "search")
    for id,_ in pairs(MagicalGlass.registry.light_encounters) do
        if id ~= "_nobody" then
            debug:registerOption("dt_encounter_select", id, "Start this encounter.", function()
                Game:encounterDT(id, true, nil, nil, true)
                debug:closeMenu()
            end)
        end
    end
end

return lib