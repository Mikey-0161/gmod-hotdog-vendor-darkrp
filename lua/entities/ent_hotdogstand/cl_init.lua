include("shared.lua")

-- Local attachment offsets where cooked hot dogs stack up visually on the stand.
-- Tweak these to match your stand model's actual counter/shelf geometry.
local ATTACH_POSITIONS = {
    Vector(-6, -6, 12), Vector(6, -6, 12), Vector(-6, 6, 12), Vector(6, 6, 12),
    Vector(-6, -6, 20), Vector(6, -6, 20), Vector(-6, 6, 20), Vector(6, 6, 20),
    Vector(0, 0, 26), Vector(-10, 0, 26), Vector(10, 0, 26), Vector(0, -10, 26), Vector(0, 10, 26),
    Vector(0, 0, 34), Vector(-6, -6, 34), Vector(6, -6, 34), Vector(-6, 6, 34), Vector(6, 6, 34),
    Vector(0, -10, 34), Vector(0, 10, 34),
}

function ENT:Initialize()
    self.HDV_DisplayModels = {}
    self.HDV_LastStock = -1
end

local function spawnDisplayHotdog(self, index)
    local pos = ATTACH_POSITIONS[index] or ATTACH_POSITIONS[#ATTACH_POSITIONS]
    local m = ClientsideModel(HOTDOGVENDOR.SafeModel(HOTDOGVENDOR.Config.Model_Hotdog), RENDERGROUP_OPAQUE)
    if not IsValid(m) then return nil end

    m:SetParent(self)
    m:SetPos(self:LocalToWorld(pos))
    m:SetAngles(self:GetAngles())
    m:SetNoDraw(false)
    return m
end

local function rebuildDisplay(self, stock)
    for _, m in ipairs(self.HDV_DisplayModels) do
        if IsValid(m) then m:Remove() end
    end
    self.HDV_DisplayModels = {}

    for i = 1, stock do
        local m = spawnDisplayHotdog(self, i)
        if m then table.insert(self.HDV_DisplayModels, m) end
    end
end

function ENT:Think()
    local stock = self:GetNWInt("Stock", 0)
    if stock ~= self.HDV_LastStock then
        self.HDV_LastStock = stock
        rebuildDisplay(self, stock)
    end
end

function ENT:OnRemove()
    for _, m in ipairs(self.HDV_DisplayModels or {}) do
        if IsValid(m) then m:Remove() end
    end
end

function ENT:Draw()
    self:DrawModel()

    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local distSqr = ply:GetPos():DistToSqr(self:GetPos())
    if distSqr > (HOTDOGVENDOR.Config.MaxInteractDistance * 1.4) ^ 2 then return end

    local trace = ply:GetEyeTrace()
    if trace.Entity ~= self then return end

    local owner = self:GetNWEntity("spawner")
    local isOwner = (IsValid(owner) and owner == ply) or (ply:IsAdmin())
    local text = isOwner and "Press [E] to manage your stand" or "Press [E] to buy a hot dog"

    local pos = self:GetPos() + Vector(0, 0, 45)
    local ang = (ply:EyePos() - pos):Angle()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)

    cam.Start3D2D(pos, ang, 0.1)
        draw.SimpleTextOutlined(text, "DermaDefaultBold", 0, 0, HOTDOGVENDOR.Config.Colors.Text,
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
    cam.End3D2D()
end
