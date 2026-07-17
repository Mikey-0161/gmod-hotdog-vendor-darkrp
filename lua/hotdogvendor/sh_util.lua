--[[
    Shared helpers + the full list of net message names used by the addon.
    PLACEMENT: garrysmod/addons/hotdog_vendor/lua/hotdogvendor/sh_util.lua
--]]

HOTDOGVENDOR = HOTDOGVENDOR or {}

HOTDOGVENDOR.Net = {
    OpenManagement = "HDV_OpenManagement",
    OpenPurchase   = "HDV_OpenPurchase",
    SetPrice       = "HDV_SetPrice",
    RequestCook    = "HDV_RequestCook",
    CookingRound   = "HDV_CookingRound",
    CookingInput   = "HDV_CookingInput",
    CookingResult  = "HDV_CookingResult",
    CookingCancel  = "HDV_CookingCancel",
    Purchase       = "HDV_Purchase",
    RemoveStand    = "HDV_RemoveStand",
    Notify         = "HDV_Notify",
    EarningsUpdate = "HDV_EarningsUpdate",
    InventorySync  = "HDV_InventorySync",
    EatItem        = "HDV_EatItem",
}

if SERVER then
    for _, name in pairs(HOTDOGVENDOR.Net) do
        util.AddNetworkString(name)
    end
end

function HOTDOGVENDOR.Debug(...)
    if HOTDOGVENDOR.Config.DebugMode then
        print("[HotdogVendor]", ...)
    end
end

function HOTDOGVENDOR.FormatMoney(amount)
    if DarkRP and DarkRP.formatMoney then
        return DarkRP.formatMoney(amount)
    end
    return "$" .. string.Comma(math.Round(amount or 0))
end

-- Returns a safe model path: the configured model if it exists on disk,
-- otherwise a guaranteed-valid fallback so the entity never fails to spawn.
function HOTDOGVENDOR.SafeModel(path)
    if util.IsValidModel and util.IsValidModel(path) then
        return path
    end
    HOTDOGVENDOR.Debug("Model missing, using fallback:", path)
    return HOTDOGVENDOR.Config.Model_Fallback
end

-- Simple per-player action throttle to prevent network/spam abuse.
-- key should be unique per action type (and per-entity where relevant).
function HOTDOGVENDOR.CanAct(ply, key, cooldown)
    if not IsValid(ply) then return false end
    ply.HDV_Throttle = ply.HDV_Throttle or {}
    local now = CurTime()
    local last = ply.HDV_Throttle[key] or 0
    if now - last < cooldown then return false end
    ply.HDV_Throttle[key] = now
    return true
end

function HOTDOGVENDOR.IsOwner(ent, ply)
    if not IsValid(ent) or not IsValid(ply) then return false end
    
    -- Maps your custom framework check to DarkRP's native ownership
    return ent:Getowning_ent() == ply
end