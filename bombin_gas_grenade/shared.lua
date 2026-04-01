ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Bombin Gas Grenade"
ENT.Author = "Nachin Bombin"
ENT.Category = "Bombin Addons"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_OPAQUE

ENT.ConfigDefaults = {
    MinSize = 0.85,
    MaxSize = 1.75,
    MinDuration = 18,
    MaxDuration = 35,

    BaseSpread = 12,
    SpreadSpeed = 18,
    Speed = 20,
    StartSize = 16,
    EndSize = 72,
    Rate = 48,
    JetLength = 180,
    WindAngle = 0,
    WindSpeed = 0,
    Twist = 8,
    Roll = 4,

    RenderAmt = 245,
    ColorR = 68,
    ColorG = 68,
    ColorB = 68,

    SoundVolume = 0.9,
    SoundPitch = 100,
    SmokeMaterial = "particle/particle_smokegrenade",
    SoundPath = "ambient/gas/steam2.wav"
}

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "GasScale")
    self:NetworkVar("Float", 1, "GasDuration")
    self:NetworkVar("Float", 2, "GasDieTime")
end
