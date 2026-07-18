include("shared.lua")

-- PERFECTED GRID: 20 slots all offset based on perfect Vector(9, -5, 39) baseline!
local ATTACH_POSITIONS = {
    -- Layer 1
    Vector(9, -5, 39), Vector(9, -10, 39), Vector(9, -15, 39), Vector(9, -20, 39),
    -- Layer 2
    Vector(9, -5, 42),  Vector(9, -10, 42),  Vector(9, -15, 42),  Vector(9, -20, 42),
    -- Layer 3 
    Vector(9, -5, 45), Vector(9, -10, 45), Vector(9, -15, 45), Vector(9, -20, 45),
    -- Layer 4 
    Vector(9, -5, 48), Vector(9, -10, 48), Vector(9, -15, 48), Vector(9, -20, 48),
    -- Layer 5
	Vector(9, -5, 51), Vector(9, -10, 51), Vector(9, -15, 51), Vector(9, -20, 51),
}   

function ENT:Initialize()
    self.HDV_DisplayModels = {}
    self.HDV_LastStock = -1
end

local function spawnDisplayHotdog(self, index)
    local m = ClientsideModel(HOTDOGVENDOR.SafeModel(HOTDOGVENDOR.Config.Model_Hotdog), RENDERGROUP_OPAQUE)
    if not IsValid(m) then return nil end

    m:SetNoDraw(true) -- handles rendering explicitly inside the ENT:Draw routine
    return m
end

local function rebuildDisplay(self, stock)
    for _, m in ipairs(self.HDV_DisplayModels) do
        if IsValid(m) then m:Remove() end
    end
    self.HDV_DisplayModels = {}

    -- UNLOCKED: Dynamically draw up to 20 individual hot dogs as stock increases
    local drawCount = math.min(stock, #ATTACH_POSITIONS)
    for i = 1, drawCount do
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
    self:DrawModel() -- Renders the physical hot dog stand structure prop frame

    -- RENDER THE HOTDOG STACKS SEAMLESSLY
    for i, m in ipairs(self.HDV_DisplayModels or {}) do
        if IsValid(m) then
            local localPos = ATTACH_POSITIONS[i]
            if localPos then
                -- 1. Grab the current physical angles of the main hot dog cart entity
                local worldPos, worldAng = LocalToWorld(localPos, Angle(0, 0, 0), self:GetPos(), self:GetAngles())
                
                -- 2. Pass the exact angle orientation that matched your baseline screenshot
                worldAng:RotateAroundAxis(worldAng:Up(), 0)
                
                -- 3. Pass the newly corrected alignment data directly down to the engine graphics cards
                m:SetPos(worldPos)
                m:SetAngles(worldAng)
                m:SetupBones()
                m:DrawModel() -- Forces visual output extraction cleanly above the table line
            end
        end
    end

    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local distSqr = ply:GetPos():DistToSqr(self:GetPos())
    if distSqr > (HOTDOGVENDOR.Config.MaxInteractDistance * 1.4) ^ 2 then return end

    local trace = ply:GetEyeTrace()
    if trace.Entity ~= self then return end

    -- Synchronized network keys to point exactly to our native FPP variable definitions
    local owner = self:GetNWEntity("HDV_Owner")
    local isOwner = (IsValid(owner) and owner == ply) or (ply:IsAdmin())
    local text = isOwner and "Press [E] to manage your stand" or "Press [E] to buy a hot dog"

    local pos = self:GetPos() + Vector(0, 0, 45)
    local ang = (ply:EyePos() - pos):Angle()
    ang:RotateAroundAxis(ang:Forward(), 0)
    ang:RotateAroundAxis(ang:Right(), 0)

    cam.Start3D2D(pos, ang, 0.1)
        draw.SimpleTextOutlined(text, "DermaDefaultBold", 0, 0, HOTDOGVENDOR.Config.Colors.Text,
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
    cam.End3D2D()
end
