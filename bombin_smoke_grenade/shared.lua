ENT.Type       = "anim"
ENT.Base       = "base_anim"

ENT.PrintName  = "Bombin Smoke Grenade"
ENT.Author     = "Nachin Bombin"
ENT.Category   = "Bombin Addons"
ENT.Spawnable  = true
ENT.AdminOnly  = false
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "SmokeDieTime")
end
