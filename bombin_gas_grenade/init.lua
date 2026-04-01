
AddCSLuaFile("shared.lua")


AddCSLuaFile("cl_init.lua")
include("shared.lua")


local DEFAULTS = table.Copy(ENT.ConfigDefaults or {})

local function ClampSwap(minValue, maxValue)
    if minValue > maxValue then
        minValue, maxValue = maxValue, minValue
    end

    return minValue, maxValue
end

local function ReadSpawnConfig(ply)
    local d = DEFAULTS

    local cfg = {
        MinSize = IsValid(ply) and ply:GetInfoNum("bombin_gasg_min_size", d.MinSize or 0.85) or (d.MinSize or 0.85),
        MaxSize = IsValid(ply) and ply:GetInfoNum("bombin_gasg_max_size", d.MaxSize or 1.75) or (d.MaxSize or 1.75),
        MinDuration = IsValid(ply) and ply:GetInfoNum("bombin_gasg_min_duration", d.MinDuration or 18) or (d.MinDuration or 18),
        MaxDuration = IsValid(ply) and ply:GetInfoNum("bombin_gasg_max_duration", d.MaxDuration or 35) or (d.MaxDuration or 35),

        BaseSpread = IsValid(ply) and ply:GetInfoNum("bombin_gasg_basespread", d.BaseSpread or 12) or (d.BaseSpread or 12),
        SpreadSpeed = IsValid(ply) and ply:GetInfoNum("bombin_gasg_spreadspeed", d.SpreadSpeed or 18) or (d.SpreadSpeed or 18),
        Speed = IsValid(ply) and ply:GetInfoNum("bombin_gasg_speed", d.Speed or 20) or (d.Speed or 20),
        StartSize = IsValid(ply) and ply:GetInfoNum("bombin_gasg_startsize", d.StartSize or 16) or (d.StartSize or 16),
        EndSize = IsValid(ply) and ply:GetInfoNum("bombin_gasg_endsize", d.EndSize or 72) or (d.EndSize or 72),
        Rate = IsValid(ply) and ply:GetInfoNum("bombin_gasg_rate", d.Rate or 48) or (d.Rate or 48),
        JetLength = IsValid(ply) and ply:GetInfoNum("bombin_gasg_jetlength", d.JetLength or 180) or (d.JetLength or 180),
        WindAngle = IsValid(ply) and ply:GetInfoNum("bombin_gasg_windangle", d.WindAngle or 0) or (d.WindAngle or 0),
        WindSpeed = IsValid(ply) and ply:GetInfoNum("bombin_gasg_windspeed", d.WindSpeed or 0) or (d.WindSpeed or 0),
        Twist = IsValid(ply) and ply:GetInfoNum("bombin_gasg_twist", d.Twist or 8) or (d.Twist or 8),
        Roll = IsValid(ply) and ply:GetInfoNum("bombin_gasg_roll", d.Roll or 4) or (d.Roll or 4),

        RenderAmt = IsValid(ply) and ply:GetInfoNum("bombin_gasg_renderamt", d.RenderAmt or 245) or (d.RenderAmt or 245),
        ColorR = IsValid(ply) and ply:GetInfoNum("bombin_gasg_colorr", d.ColorR or 68) or (d.ColorR or 68),
        ColorG = IsValid(ply) and ply:GetInfoNum("bombin_gasg_colorg", d.ColorG or 68) or (d.ColorG or 68),
        ColorB = IsValid(ply) and ply:GetInfoNum("bombin_gasg_colorb", d.ColorB or 68) or (d.ColorB or 68),

        SoundVolume = IsValid(ply) and ply:GetInfoNum("bombin_gasg_soundvolume", d.SoundVolume or 0.9) or (d.SoundVolume or 0.9),
        SoundPitch = IsValid(ply) and ply:GetInfoNum("bombin_gasg_soundpitch", d.SoundPitch or 100) or (d.SoundPitch or 100),

        SmokeMaterial = d.SmokeMaterial or "particle/particle_smokegrenade",
        SoundPath = d.SoundPath or "ambient/gas/steam2.wav"
    }

    cfg.MinSize = math.Clamp(cfg.MinSize, 0.10, 10)
    cfg.MaxSize = math.Clamp(cfg.MaxSize, 0.10, 10)
    cfg.MinDuration = math.Clamp(cfg.MinDuration, 1, 300)
    cfg.MaxDuration = math.Clamp(cfg.MaxDuration, 1, 300)

    cfg.BaseSpread = math.Clamp(cfg.BaseSpread, 0, 256)
    cfg.SpreadSpeed = math.Clamp(cfg.SpreadSpeed, 0, 256)
    cfg.Speed = math.Clamp(cfg.Speed, 1, 256)
    cfg.StartSize = math.Clamp(cfg.StartSize, 1, 256)
    cfg.EndSize = math.Clamp(cfg.EndSize, 1, 512)
    cfg.Rate = math.Clamp(cfg.Rate, 1, 256)
    cfg.JetLength = math.Clamp(cfg.JetLength, 1, 1024)
    cfg.WindAngle = math.Clamp(cfg.WindAngle, -180, 180)
    cfg.WindSpeed = math.Clamp(cfg.WindSpeed, 0, 256)
    cfg.Twist = math.Clamp(cfg.Twist, -360, 360)
    cfg.Roll = math.Clamp(cfg.Roll, -360, 360)

    cfg.RenderAmt = math.Clamp(cfg.RenderAmt, 1, 255)
    cfg.ColorR = math.Clamp(cfg.ColorR, 0, 255)
    cfg.ColorG = math.Clamp(cfg.ColorG, 0, 255)
    cfg.ColorB = math.Clamp(cfg.ColorB, 0, 255)

    cfg.SoundVolume = math.Clamp(cfg.SoundVolume, 0, 1)
    cfg.SoundPitch = math.Clamp(cfg.SoundPitch, 60, 180)

    cfg.MinSize, cfg.MaxSize = ClampSwap(cfg.MinSize, cfg.MaxSize)
    cfg.MinDuration, cfg.MaxDuration = ClampSwap(cfg.MinDuration, cfg.MaxDuration)

    return cfg
end

function ENT:SpawnFunction(ply, tr, className)
    if not tr.Hit then return end

    local ent = ents.Create(className)
    if not IsValid(ent) then return end

    ent:SetPos(tr.HitPos + tr.HitNormal * 12)
    ent:SetAngles(AngleRand())
    ent.SpawnConfig = ReadSpawnConfig(ply)
    ent:Spawn()
    ent:Activate()

    return ent
end

function ENT:Initialize()
    self:SetModel("models/Weapons/w_grenade.mdl")
    self:SetMaterial("models/debug/debugwhite")
    self:SetColor(Color(0, 0, 0, 255))
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

    self.SpawnConfig = self.SpawnConfig or ReadSpawnConfig(nil)
    self.GasStopped = false
    self.GasActive = false

    self:StartGas()
end

function ENT:CreateSmokeStack()
    local cfg = self.SpawnConfig or ReadSpawnConfig(nil)
    local gasScale = math.Rand(cfg.MinSize, cfg.MaxSize)
    local gasDuration = math.Rand(cfg.MinDuration, cfg.MaxDuration)

    self:SetGasScale(gasScale)
    self:SetGasDuration(gasDuration)
    self:SetGasDieTime(CurTime() + gasDuration)

    local smoke = ents.Create("env_smokestack")
    if not IsValid(smoke) then return end

    smoke:SetPos(self:GetPos() + Vector(0, 0, 6))
    smoke:SetAngles(Angle(-90, 0, 0))
    smoke:SetParent(self)

    smoke:SetKeyValue("InitialState", "1")
    smoke:SetKeyValue("BaseSpread", tostring(math.Round(cfg.BaseSpread * gasScale)))
    smoke:SetKeyValue("SpreadSpeed", tostring(math.Round(cfg.SpreadSpeed * gasScale)))
    smoke:SetKeyValue("Speed", tostring(math.Round(cfg.Speed)))
    smoke:SetKeyValue("StartSize", tostring(math.Round(cfg.StartSize * gasScale)))
    smoke:SetKeyValue("EndSize", tostring(math.Round(cfg.EndSize * gasScale)))
    smoke:SetKeyValue("Rate", tostring(math.Round(cfg.Rate)))
    smoke:SetKeyValue("JetLength", tostring(math.Round(cfg.JetLength * gasScale)))
    smoke:SetKeyValue("WindAngle", tostring(math.Round(cfg.WindAngle)))
    smoke:SetKeyValue("WindSpeed", tostring(math.Round(cfg.WindSpeed)))
    smoke:SetKeyValue("SmokeMaterial", cfg.SmokeMaterial)
    smoke:SetKeyValue("Twist", tostring(math.Round(cfg.Twist)))
    smoke:SetKeyValue("Roll", tostring(math.Round(cfg.Roll)))
    smoke:SetKeyValue("rendercolor", string.format("%d %d %d", math.Round(cfg.ColorR), math.Round(cfg.ColorG), math.Round(cfg.ColorB)))
    smoke:SetKeyValue("renderamt", tostring(math.Round(cfg.RenderAmt)))

    smoke:Spawn()
    smoke:Activate()
    smoke:Fire("TurnOn", "", 0)

    self.GasStack = smoke
end

function ENT:StartGasSound()
    if self.GasSoundPatch then
        self.GasSoundPatch:Stop()
        self.GasSoundPatch = nil
    end

    self.GasSoundPatch = CreateSound(self, self.SpawnConfig.SoundPath)

    if self.GasSoundPatch then
        self.GasSoundPatch:PlayEx(self.SpawnConfig.SoundVolume, self.SpawnConfig.SoundPitch)
    end
end

function ENT:StartGas()
    self:CreateSmokeStack()
    self:StartGasSound()
    self.GasActive = true
    self:NextThink(CurTime() + 0.1)
end

function ENT:StopGas()
    if self.GasStopped then return end
    self.GasStopped = true
    self.GasActive = false

    if self.GasSoundPatch then
        self.GasSoundPatch:Stop()
        self.GasSoundPatch = nil
    end

    if IsValid(self.GasStack) then
        self.GasStack:Fire("TurnOff", "", 0)
        self.GasStack:Remove()
        self.GasStack = nil
    end
end

function ENT:Think()
    if not self.GasActive then return end

    local timeLeft = self:GetGasDieTime() - CurTime()

    if timeLeft <= 0 then
        self:StopGas()
        self:Remove()
        return
    end

    if self.GasSoundPatch then
        local volume = self.SpawnConfig.SoundVolume

        if timeLeft <= 5 then
            volume = volume * math.Clamp(timeLeft / 5, 0, 1)
        end

        self.GasSoundPatch:ChangeVolume(volume, 0.15)
    end

    self:NextThink(CurTime() + 0.1)
    return true
end

function ENT:OnRemove()
    self:StopGas()
end
