Utils.hook(Game, "encounter", function(orig, self, encounter, transition, enemy, context)
    if transition == nil then transition = true end

    if self.battle then
        error("Attempted to enter a battle while already in battle")
    end
    
    if MagicalGlass.__current_battle_system then
        if MagicalGlass.__current_battle_system == "deltatraveler" then
            self:encounterDT(encounter, transition, enemy, context)
            return
        elseif MagicalGlass.__current_battle_system == "undertale" then
            self:encounterLight(encounter, transition, enemy, context)
            return
        elseif MagicalGlass.__current_battle_system == "deltarune" then
            self:encounterDark(encounter, transition, enemy, context)
            return
        end
    end

    if MagicalGlass.default_battle_system == "deltatraveler" then
        self:encounterDT(encounter, transition, enemy, context)
    elseif MagicalGlass.default_battle_system == "undertale" then
        self:encounterLight(encounter, transition, enemy, context)
    elseif MagicalGlass.default_battle_system == "deltarune" then
        self:encounterDark(encounter, transition, enemy, context)
    else
        self:encounterDark(encounter, transition, enemy, context)
    end
end)

Utils.hook(Game, "encounterDT", function(orig, self, encounter, transition, enemy, context)
    if transition == nil then transition = true end

    if self.battle then
        error("Attempted to enter a battle while already in battle")
    end

    MagicalGlass.__current_battle_system = "deltatraveler"

    if enemy and not isClass(enemy) then
        self.encounter_enemies = enemy
    else
        self.encounter_enemies = {enemy}
    end

    self.state = "BATTLE"

    self.battle = DTBattle()

    if context then
        self.battle.encounter_context = context
    end

    if type(transition) == "string" then
        self.battle:postInit(transition, encounter)
    else
        self.battle:postInit(transition and "TRANSITION" or "INTRO", encounter)
    end

    self.stage:addChild(self.battle)
end)