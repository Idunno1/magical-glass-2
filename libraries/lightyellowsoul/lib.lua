local lib = {}

function lib:init()
    print("Loaded LightYellowSoul!")
end

function lib:onRegisterObjects()
    -- LightSoul doesn't exist by the time LightYellowSoul gets created, so
    -- it won't inherit it, register it once all the other objects are ready

    local obj = libRequire("lightyellowsoul", "scripts/LightYellowSoul")
    Registry.registerGlobal("LightYellowSoul", obj)
end

return lib