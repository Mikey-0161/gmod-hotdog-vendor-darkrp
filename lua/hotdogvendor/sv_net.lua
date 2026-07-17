--[[
    All server-side net message receivers. Every handler re-validates the
    entity class and re-checks ownership/range/throttle before doing
    anything - the individual functions being called are also safe on
    their own, but this belt-and-braces approach keeps abuse surface small.
    PLACEMENT: garrysmod/addons/hotdog_vendor/lua/hotdogvendor/sv_net.lua
--]]

net.Receive(HOTDOGVENDOR.Net.SetPrice, function(len, ply)
    local ent = net.ReadEntity()
    local price = net.ReadInt(32)
    if not IsValid(ent) or ent:GetClass() ~= "ent_hotdogstand" then return end
    HOTDOGVENDOR.SetPrice(ply, ent, price)
end)

net.Receive(HOTDOGVENDOR.Net.RequestCook, function(len, ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) or ent:GetClass() ~= "ent_hotdogstand" then return end
    HOTDOGVENDOR.StartCookingSession(ply, ent)
end)

net.Receive(HOTDOGVENDOR.Net.CookingInput, function(len, ply)
    local ent = net.ReadEntity()
    local colorId = net.ReadUInt(3)
    if not IsValid(ent) or ent:GetClass() ~= "ent_hotdogstand" then return end
    HOTDOGVENDOR.HandleCookingInput(ply, ent, colorId)
end)

net.Receive(HOTDOGVENDOR.Net.CookingCancel, function(len, ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    HOTDOGVENDOR.CancelCookingSession(ply, ent)
end)

net.Receive(HOTDOGVENDOR.Net.Purchase, function(len, ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) or ent:GetClass() ~= "ent_hotdogstand" then return end
    HOTDOGVENDOR.TryPurchase(ply, ent)
end)

net.Receive(HOTDOGVENDOR.Net.RemoveStand, function(len, ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) or ent:GetClass() ~= "ent_hotdogstand" then return end
    HOTDOGVENDOR.RemoveStandRequest(ply, ent)
end)

net.Receive(HOTDOGVENDOR.Net.EatItem, function(len, ply)
    if not HOTDOGVENDOR.CanAct(ply, "eat", 0.4) then return end

    local removed = HOTDOGVENDOR.Inventory.RemoveHotdog(ply)
    if removed then
        HOTDOGVENDOR.Hunger.Restore(ply, HOTDOGVENDOR.Config.HungerRestoreAmount)
        if HOTDOGVENDOR.Config.EnableSounds then
            ply:EmitSound(HOTDOGVENDOR.Config.Sounds.Eat)
        end
        HOTDOGVENDOR.Notify(ply, "You ate a hot dog", "success")
    else
        HOTDOGVENDOR.Notify(ply, "No Hot Dog To Eat", "error")
    end
end)
