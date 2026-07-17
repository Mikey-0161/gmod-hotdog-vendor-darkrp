--[[
    Price setting, the customer purchase transaction, and stand removal/refund.
    Every check here happens server-side; nothing is trusted from the client
    beyond "this is the price/entity the player clicked on".
    PLACEMENT: garrysmod/addons/hotdog_vendor/lua/hotdogvendor/sv_purchase.lua
--]]

function HOTDOGVENDOR.SetPrice(ply, ent, price)
    if not IsValid(ent) or ent:GetClass() ~= "ent_hotdogstand" then return end
    if not HOTDOGVENDOR.IsOwner(ent, ply) then return end
    if not HOTDOGVENDOR.IsWithinRange(ply, ent) then return end
    if not HOTDOGVENDOR.CanAct(ply, "setprice_" .. ent:EntIndex(), 0.5) then return end

    local cfg = HOTDOGVENDOR.Config
    price = math.floor(tonumber(price) or -1)

    if price < cfg.MinSellPrice or price > cfg.MaxSellPrice then
        HOTDOGVENDOR.Notify(ply, "Invalid Price", "error")
        return
    end

    ent:SetNWInt("Price", price)
    HOTDOGVENDOR.Notify(ply, "Price Updated", "success")
end

function HOTDOGVENDOR.TryPurchase(buyer, ent)
    if not IsValid(buyer) or not IsValid(ent) or ent:GetClass() ~= "ent_hotdogstand" then return end
    if not HOTDOGVENDOR.IsWithinRange(buyer, ent) then return end
    if not HOTDOGVENDOR.CanAct(buyer, "purchase_" .. ent:EntIndex(), 0.75) then return end

    local owner = ent.CPPIGetOwner and ent:CPPIGetOwner()
    if not IsValid(owner) then
        HOTDOGVENDOR.Notify(buyer, "Stand Unavailable", "error")
        return
    end
    if owner == buyer then
        HOTDOGVENDOR.Notify(buyer, "You Own This Stand", "error")
        return
    end

    local stock = ent:GetNWInt("Stock", 0)
    if stock <= 0 then
        HOTDOGVENDOR.Notify(buyer, "Out of Stock", "error")
        return
    end

    local price = ent:GetNWInt("Price", HOTDOGVENDOR.Config.DefaultPrice)
    if not buyer.canAfford or not buyer:canAfford(price) then
        HOTDOGVENDOR.Notify(buyer, "Not Enough Money", "error")
        return
    end

    if HOTDOGVENDOR.Config.EnableInventorySupport and not HOTDOGVENDOR.Inventory.HasRoom(buyer) then
        HOTDOGVENDOR.Notify(buyer, "Inventory Full", "error")
        return
    end

    -- === Server-authoritative transaction ===
    buyer:addMoney(-price)
    owner:addMoney(price)
    ent:SetNWInt("Stock", stock - 1)

    if HOTDOGVENDOR.Config.EnableInventorySupport then
        HOTDOGVENDOR.Inventory.GiveHotdog(buyer)
    end

    ent.HDV_TodayEarnings = (ent.HDV_TodayEarnings or 0) + price
    ent.HDV_LifetimeEarnings = (ent.HDV_LifetimeEarnings or 0) + price
    HOTDOGVENDOR.SendEarnings(owner, ent)

    if HOTDOGVENDOR.Config.EnableSounds then
        ent:EmitSound(HOTDOGVENDOR.Config.Sounds.CashRegister)
    end

    HOTDOGVENDOR.Notify(buyer, "Hot Dog Purchased", "success")
end

function HOTDOGVENDOR.SendEarnings(owner, ent)
    if not IsValid(owner) then return end
    net.Start(HOTDOGVENDOR.Net.EarningsUpdate)
        net.WriteEntity(ent)
        net.WriteInt(ent.HDV_TodayEarnings or 0, 32)
        net.WriteInt(ent.HDV_LifetimeEarnings or 0, 32)
    net.Send(owner)
end

function HOTDOGVENDOR.RemoveStandRequest(ply, ent)
    if not IsValid(ent) or ent:GetClass() ~= "ent_hotdogstand" then return end
    if not HOTDOGVENDOR.IsOwner(ent, ply) then return end
    if not HOTDOGVENDOR.IsWithinRange(ply, ent) then return end

    local refund = math.floor(HOTDOGVENDOR.Config.EntityShopPrice * HOTDOGVENDOR.Config.RefundPercent)
    if refund > 0 and ply.addMoney then
        ply:addMoney(refund)
    end
    ent:Remove()
end
