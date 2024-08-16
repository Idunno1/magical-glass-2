local DTPartyBattler, super = Class(LightPartyBattler, "DTPartyBattler")

function DTPartyBattler:init(chara)
    super.init(self, chara)

    self.status_box = nil
end

function DTPartyBattler:setActor(actor)
    self.status_box:setActor(actor)
end

function DTPartyBattler:hurt(amount, exact, color, options)
    options = options or {}

    if not options["all"] then
        Assets.playSound("hurt")
        if not exact then
            amount = self:calculateDamage(amount)
            if self.defending then
                amount = math.ceil((2 * amount) / 3)
            end
            local element = 0
            amount = math.ceil((amount * self:getElementReduction(element)))
        end

        self:removeHealth(amount)
    else
        if not exact then
            amount = self:calculateDamage(amount)
            local element = 0
            amount = math.ceil((amount * self:getElementReduction(element)))

            if self.defending then
                amount = math.ceil((3 * amount) / 4)
            end

            self:removeHealth(amount) -- yep, don't care
        end
    end

    if (self.chara:getHealth() <= 0) then
        self:statusMessage("msg", "down", color, true)
    else
        self:statusMessage("damage", amount, color, true)
    end

    Game.battle:shakeCamera(2)
end

function DTPartyBattler:statusMessage(type, arg, color)
    local x, y = self.status_box:getRelativePos()

    color = color or {self.chara:getDTHurtColor()}

    local number = DTDamageNumber(type, arg, x + 13, y + 40, color)
    if kill then
        number.kill_others = true
    end
    self.status_box.parent:addChild(number)

    return number
end

function DTPartyBattler:recruitMessage(type)
    local x, y = self.status_box:getRelativePos(self.status_box.width/2, self.status_box.height/2)

    local recruit = RecruitMessage(type, x, y - 80)
    self.status_box.parent:addChild(recruit)

    return recruit
end

return DTPartyBattler