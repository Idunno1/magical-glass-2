local lib = {}

function lib:init()
    print("Loaded LightBlueSoul!")
end

function lib:onRegisterObjects()
    -- LightSoul doesn't exist by the time LightBlueSoul gets created, so
    -- it won't inherit it, register it once all the other objects are ready

    local obj = libRequire("lightbluesoul", "scripts/LightBlueSoul")
    Registry.registerGlobal("LightBlueSoul", obj)
end

return lib