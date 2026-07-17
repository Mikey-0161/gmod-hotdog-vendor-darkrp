AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(HOTDOGVENDOR.SafeModel(HOTDOGVENDOR.Config.Model_Stand))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(true)
    end

    self:SetNWInt("Stock", 0)
    self:SetNWInt("MaxStock", HOTDOGVENDOR.Config.MaxStock)
    self:SetNWInt("Price", HOTDOGVENDOR.Config.DefaultPrice)

    self.HDV_TodayEarnings = 0
    self.HDV_LifetimeEarnings = 0

    HOTDOGVENDOR.RegisterStand(self)
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if not HOTDOGVENDOR.IsWithinRange(activator, self) then return end
    if not HOTDOGVENDOR.CanAct(activator, "use_" .. self:EntIndex(), 0.35) then return end

    -- Safe CPPI Owner retrieval (Fully powered by your FPP addon)
    local owner = self.CPPIGetOwner and self:CPPIGetOwner()

    -- Fallback to your engine-level network variable if CPPI returns world/server (Entity 0)
    if not IsValid(owner) or owner:IsWorld() then
        owner = self:GetNWEntity("HDV_Owner")
    end

    -- Server-Authoritative UI routing
    if IsValid(owner) and activator == owner then
        net.Start(HOTDOGVENDOR.Net.OpenManagement)
            net.WriteEntity(self)
            net.WriteInt(self.HDV_TodayEarnings or 0, 32)
            net.WriteInt(self.HDV_LifetimeEarnings or 0, 32)
        net.Send(activator)
    else
        -- If ownership was stripped, it falls straight to here safely!
        net.Start(HOTDOGVENDOR.Net.OpenPurchase)
            net.WriteEntity(self)
        net.Send(activator)
    end
end

function ENT:OnRemove()
    HOTDOGVENDOR.UnregisterStand(self)
end