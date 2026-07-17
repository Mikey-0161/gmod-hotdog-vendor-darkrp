--[[
    Core stand registry + shared server-side helper functions.
    PLACEMENT: garrysmod/addons/hotdog_vendor/lua/hotdogvendor/sv_core.lua
--]]

HOTDOGVENDOR = HOTDOGVENDOR or {}
HOTDOGVENDOR.Stands = HOTDOGVENDOR.Stands or {} -- [ent] = true

function HOTDOGVENDOR.RegisterStand(ent)
    HOTDOGVENDOR.Stands[ent] = true
end

function HOTDOGVENDOR.UnregisterStand(ent)
    HOTDOGVENDOR.Stands[ent] = nil
end

-- Returns the (single) stand owned by a player, or nil.
function HOTDOGVENDOR.GetPlayerStand(ply)
    for ent in pairs(HOTDOGVENDOR.Stands) do
        if IsValid(ent) and ent.CPPIGetOwner and ent:CPPIGetOwner() == ply then
            return ent
        end
    end
    return nil
end

function HOTDOGVENDOR.IsOwner(ent, ply)
    if not IsValid(ent) or not IsValid(ply) then return false end
    if not ent.CPPIGetOwner then return false end
    return ent:CPPIGetOwner() == ply
end

-- Server-authoritative distance check used before ANY stand action.
function HOTDOGVENDOR.IsWithinRange(ply, ent)
    if not IsValid(ply) or not IsValid(ent) then return false end
    return ply:GetPos():DistToSqr(ent:GetPos()) <= (HOTDOGVENDOR.Config.MaxInteractDistance ^ 2)
end

-- Stub kept for compatibility with admin tools/future features.
-- The physical hot dog display models are handled client-side by simply
-- watching the networked Stock int, so there's nothing to push here,
-- but this gives us one place to hook into if that ever changes.
function HOTDOGVENDOR.UpdateStandDisplay(ent) end

function HOTDOGVENDOR.Notify(ply, message, kind)
    if not IsValid(ply) then return end
    net.Start(HOTDOGVENDOR.Net.Notify)
        net.WriteString(message)
        net.WriteString(kind or "info")
    net.Send(ply)
end
