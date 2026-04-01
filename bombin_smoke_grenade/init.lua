AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

-- ----------------------------------------------------------------
-- Hardcoded smoke profile - medium grey cloud, no menu
-- ----------------------------------------------------------------
local CFG = {
    MinDuration   = 40,
    MaxDuration   = 120,

    BaseSpread    = 20,
    SpreadSpeed   = 24,
    Speed         = 14,
    StartSize     = 22,
    EndSize       = 110,
    Rate          = 38,
    JetLength     = 220,
    WindAngle     = 0,
    WindSpeed     = 0,
    Twist         = 6,
    Roll          = 3,

    -- Medium grey
    ColorR        = 160,
    ColorG        = 160,
    ColorB        = 160,
    RenderAmt     = 210,

    SmokeMaterial = "particle/particle_smokegrenade",
    SoundPath     = "ambient/gas/steam2.wav",
    SoundVolume   = 0.75,
    SoundPitch    = 88,
}

function ENT:SpawnFunction(ply, tr, className)
    if not tr.Hit then return end

    local ent = ents.Create(className)
    if not IsValid(ent) then return end

    ent:SetPos(tr.HitPos + tr.HitNormal * 12)
    ent:SetAngles(AngleRand())
    ent:Spawn()
    ent:Activate()

    return ent
end

function ENT:Initialize()
    self:SetModel("models/Weapons/w_grenade.mdl")
    self:SetMaterial("models/debug/debugwhite")
    self:SetColor(Color(180, 180, 180, 255))
    self:SetRenderMode(RENDERMODE_TRANSCOLOR)

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    self.SmokeStopped = false
    self.SmokeActive  = false

    self:StartSmoke()
end

function ENT:CreateSmokeStack()
    local duration = math.Rand(CFG.MinDuration, CFG.MaxDuration)
    self:SetSmokeDieTime(CurTime() + duration)

    -- Linger time: how long existing particles keep travelling after TurnOff
    self.SmokeLingerTime = math.max(CFG.JetLength / math.max(CFG.Speed, 1), 3) + 2

    local smoke = ents.Create("env_smokestack")
    if not IsValid(smoke) then return end

    -- No parent - survives grenade removal so particles can fade naturally
    smoke:SetPos(self:GetPos() + Vector(0, 0, 6))
    smoke:SetAngles(Angle(-90, 0, 0))

    smoke:SetKeyValue("InitialState",  "1")
    smoke:SetKeyValue("BaseSpread",    tostring(CFG.BaseSpread))
    smoke:SetKeyValue("SpreadSpeed",   tostring(CFG.SpreadSpeed))
    smoke:SetKeyValue("Speed",         tostring(CFG.Speed))
    smoke:SetKeyValue("StartSize",     tostring(CFG.StartSize))
    smoke:SetKeyValue("EndSize",       tostring(CFG.EndSize))
    smoke:SetKeyValue("Rate",          tostring(CFG.Rate))
    smoke:SetKeyValue("JetLength",     tostring(CFG.JetLength))
    smoke:SetKeyValue("WindAngle",     tostring(CFG.WindAngle))
    smoke:SetKeyValue("WindSpeed",     tostring(CFG.WindSpeed))
    smoke:SetKeyValue("SmokeMaterial", CFG.SmokeMaterial)
    smoke:SetKeyValue("Twist",         tostring(CFG.Twist))
    smoke:SetKeyValue("Roll",          tostring(CFG.Roll))
    smoke:SetKeyValue("rendercolor",   string.format("%d %d %d", CFG.ColorR, CFG.ColorG, CFG.ColorB))
    smoke:SetKeyValue("renderamt",     tostring(CFG.RenderAmt))

    smoke:Spawn()
    smoke:Activate()
    smoke:Fire("TurnOn", "", 0)

    self.SmokeStack = smoke
end

function ENT:StartSound()
    if self.SmokeSoundPatch then
        self.SmokeSoundPatch:Stop()
        self.SmokeSoundPatch = nil
    end

    self.SmokeSoundPatch = CreateSound(self, CFG.SoundPath)
    if self.SmokeSoundPatch then
        self.SmokeSoundPatch:PlayEx(CFG.SoundVolume, CFG.SoundPitch)
    end
end

function ENT:StartSmoke()
    self:CreateSmokeStack()
    self:StartSound()
    self.SmokeActive = true
    self:NextThink(CurTime() + 0.1)
end

function ENT:StopSmoke()
    if self.SmokeStopped then return end
    self.SmokeStopped = true
    self.SmokeActive  = false

    if self.SmokeSoundPatch then
        self.SmokeSoundPatch:Stop()
        self.SmokeSoundPatch = nil
    end

    if IsValid(self.SmokeStack) then
        local stack      = self.SmokeStack
        local lingerTime = self.SmokeLingerTime or 10
        self.SmokeStack  = nil

        stack:Fire("TurnOff", "", 0)
        SafeRemoveEntityDelayed(stack, lingerTime)
    end
end

function ENT:Think()
    if not self.SmokeActive then return end

    local timeLeft = self:GetSmokeDieTime() - CurTime()

    if timeLeft <= 0 then
        self:StopSmoke()
        self:Remove()
        return
    end

    -- Track grenade position (no parent)
    if IsValid(self.SmokeStack) then
        self.SmokeStack:SetPos(self:GetPos() + Vector(0, 0, 6))
    end

    -- Fade sound in last 5 seconds
    if self.SmokeSoundPatch then
        local volume = CFG.SoundVolume
        if timeLeft <= 5 then
            volume = volume * math.Clamp(timeLeft / 5, 0, 1)
        end
        self.SmokeSoundPatch:ChangeVolume(volume, 0.15)
    end

    self:NextThink(CurTime() + 0.1)
    return true
end

function ENT:OnRemove()
    self:StopSmoke()
end
