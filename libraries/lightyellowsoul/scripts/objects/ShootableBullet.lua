local ShootableBullet, super = Class(Bullet)

function ShootableBullet:init(x, y, texture)
    super.init(self, x, y, texture)

    self.shot_health = 1
    self.shot_tp = 1
end

function ShootableBullet:onYellowShot(shot, damage)
    self.shot_health = self.shot_health - damage
    if self.shot_health <= 0 then
        self:destroy(shot)
    end
    return "a", false
end

function ShootableBullet:destroy(shot)
    Game:giveTension(self.shot_tp)
    self:remove()
end

return ShootableBullet