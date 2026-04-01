include("shared.lua")

local SMOKE_SPRITE_BASE = "particle/smokesprites_000"

-- Grey colour for all particles
local R, G, B = 160, 160, 160

function ENT:Initialize()
    self.Emitter = ParticleEmitter(self:GetPos(), false)
end

function ENT:OnRemove()
    if self.Emitter then
        self.Emitter:Finish()
        self.Emitter = nil
    end
end

function ENT:Draw()
    self:DrawModel()
end

function ENT:Think()
    if not self:GetSmokeActive() then return end
    if not self.Emitter then return end

    local pos = self:GetPos()

    -- Dense core puffs: small, rise slowly, expand into a big cloud
    for i = 1, 3 do
        local p = self.Emitter:Add(SMOKE_SPRITE_BASE .. math.random(1, 9), pos)
        if p then
            p:SetVelocity(Vector(math.Rand(-10, 10), math.Rand(-10, 10), math.Rand(6, 18)))
            p:SetDieTime(math.Rand(4, 8))
            p:SetColor(R, G, B)
            p:SetStartAlpha(math.Rand(160, 200))
            p:SetEndAlpha(0)
            p:SetStartSize(math.Rand(18, 28))
            p:SetEndSize(math.Rand(90, 140))
            p:SetRoll(math.Rand(0, 360))
            p:SetRollDelta(math.Rand(-0.15, 0.15))
            p:SetAirResistance(80)
            p:SetGravity(Vector(0, 0, -2))
        end
    end

    -- Occasional wide wisp: lighter, bigger, drifts higher
    if math.random() > 0.5 then
        local p = self.Emitter:Add(SMOKE_SPRITE_BASE .. math.random(1, 9), pos)
        if p then
            p:SetVelocity(Vector(math.Rand(-18, 18), math.Rand(-18, 18), math.Rand(14, 30)))
            p:SetDieTime(math.Rand(6, 12))
            p:SetColor(R, G, B)
            p:SetStartAlpha(math.Rand(60, 90))
            p:SetEndAlpha(0)
            p:SetStartSize(math.Rand(32, 52))
            p:SetEndSize(math.Rand(160, 240))
            p:SetRoll(math.Rand(0, 360))
            p:SetRollDelta(math.Rand(-0.08, 0.08))
            p:SetAirResistance(55)
            p:SetGravity(Vector(0, 0, -1))
        end
    end

    self:SetNextClientThink(CurTime() + 0.05)
    return true
end
