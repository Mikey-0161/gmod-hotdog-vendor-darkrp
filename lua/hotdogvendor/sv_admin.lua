--[[
    Admin tools. Aim your crosshair at a stand and run these in console/chat.
    PLACEMENT: garrysmod/addons/hotdog_vendor/lua/hotdogvendor/sv_admin.lua
--]]

local function isAdmin(ply)
    return IsValid(ply) and ply:IsAdmin()
end

local function getLookedAtStand(ply)
    local trace = ply:GetEyeTrace()
    local ent = trace.Entity
    if IsValid(ent) and ent:GetClass() == "ent_hotdogstand" then
        return ent
    end
    return nil
end

concommand.Add("hdv_removestand", function(ply, cmd, args)
    if not isAdmin(ply) then return end
    local ent = getLookedAtStand(ply)
    if ent then
        ent:Remove()
        HOTDOGVENDOR.Notify(ply, "Stand Removed", "success")
    end
end)

concommand.Add("hdv_resetstock", function(ply, cmd, args)
    if not isAdmin(ply) then return end
    local ent = getLookedAtStand(ply)
    if ent then
        ent:SetNWInt("Stock", 0)
        HOTDOGVENDOR.Notify(ply, "Stock Reset", "success")
    end
end)

concommand.Add("hdv_resetprice", function(ply, cmd, args)
    if not isAdmin(ply) then return end
    local ent = getLookedAtStand(ply)
    if ent then
        ent:SetNWInt("Price", HOTDOGVENDOR.Config.DefaultPrice)
        HOTDOGVENDOR.Notify(ply, "Price Reset", "success")
    end
end)

concommand.Add("hdv_owner", function(ply, cmd, args)
    if not isAdmin(ply) then return end
    local ent = getLookedAtStand(ply)
    if ent then
        local owner = ent.CPPIGetOwner and ent:CPPIGetOwner()
        ply:ChatPrint("Hot Dog Stand owner: " .. (IsValid(owner) and owner:Nick() or "unknown/abandoned"))
    end
end)

concommand.Add("hdv_spawnstand", function(ply, cmd, args)
    if not isAdmin(ply) then return end
    local trace = ply:GetEyeTrace()

    local ent = ents.Create("ent_hotdogstand")
    if not IsValid(ent) then return end
    ent:SetPos(trace.HitPos + trace.HitNormal * 5)
    ent:SetAngles(Angle(0, ply:EyeAngles().y, 0))
    ent:Spawn()
    ent:Activate()

    if ent.SetupOwner then
        ent:SetupOwner(ply)
    end
    HOTDOGVENDOR.RegisterStand(ent)
end)
