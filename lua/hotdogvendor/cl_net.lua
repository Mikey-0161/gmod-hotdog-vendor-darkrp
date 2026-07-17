--[[
    Client-side net receivers - the glue between server events and the UI
    functions defined in the other cl_*.lua files.
    PLACEMENT: garrysmod/addons/hotdog_vendor/lua/hotdogvendor/cl_net.lua
--]]

net.Receive(HOTDOGVENDOR.Net.OpenManagement, function()
    local ent = net.ReadEntity()
    local today = net.ReadInt(32)
    local lifetime = net.ReadInt(32)
    if not IsValid(ent) then return end
    HOTDOGVENDOR.OpenManagementMenu(ent, today, lifetime)
end)

net.Receive(HOTDOGVENDOR.Net.OpenPurchase, function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    HOTDOGVENDOR.OpenPurchaseMenu(ent)
end)

net.Receive(HOTDOGVENDOR.Net.CookingRound, function()
    local ent = net.ReadEntity()
    local round = net.ReadUInt(8)
    local len = net.ReadUInt(8)
    local seq = {}
    for i = 1, len do seq[i] = net.ReadUInt(3) end
    local speed = net.ReadFloat()
    HOTDOGVENDOR.PlayCookingRound(ent, round, seq, speed)
end)

net.Receive(HOTDOGVENDOR.Net.CookingResult, function()
    local success = net.ReadBool()
    local ended = net.ReadBool()
    HOTDOGVENDOR.OnCookingResult(success, ended)
end)

net.Receive(HOTDOGVENDOR.Net.EarningsUpdate, function()
    local ent = net.ReadEntity()
    local today = net.ReadInt(32)
    local lifetime = net.ReadInt(32)
    HOTDOGVENDOR.UpdateEarnings(ent, today, lifetime)
end)

net.Receive(HOTDOGVENDOR.Net.Notify, function()
    local msg = net.ReadString()
    local kind = net.ReadString()
    HOTDOGVENDOR.ShowNotification(msg, kind)
end)

net.Receive(HOTDOGVENDOR.Net.InventorySync, function()
    local inv = net.ReadTable()
    HOTDOGVENDOR.FallbackInventory = inv
    if IsValid(HOTDOGVENDOR.FallbackInvFrame) then
        HOTDOGVENDOR.RefreshFallbackInventory()
    end
end)
