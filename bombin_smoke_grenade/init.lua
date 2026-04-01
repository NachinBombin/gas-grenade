AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local MIN_DURATION = 40
local MAX_DURATION = 120

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

    local duration = math.Rand(MIN_DURATION, MAX_DURATION)
    self:SetSmokeDieTime(CurTime() + duration)
    self:SetSmokeActive(true)

    self:NextThink(CurTime() + 0.1)
end

function ENT:Think()
    if CurTime() >= self:GetSmokeDieTime() then
        self:SetSmokeActive(false)
        -- Give client particles time to fully fade before removing the entity.
        -- Longest particle die time is 12s; add a small buffer.
        timer.Simple(14, function()
            if IsValid(self) then self:Remove() end
        end)
        return
    end

    self:NextThink(CurTime() + 0.5)
    return true
end
