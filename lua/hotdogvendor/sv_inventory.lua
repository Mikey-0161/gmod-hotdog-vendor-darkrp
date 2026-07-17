--[[
    Inventory integration layer.
    PLACEMENT: garrysmod/addons/hotdog_vendor/lua/hotdogvendor/sv_inventory.lua

    HOW TO HOOK UP YOUR SERVER'S REAL INVENTORY ADDON:
    Add a separate small addon/file with these three hooks and return a
    value from each - once any of them return non-nil, this file's fallback
    logic is skipped automatically for that call.

        hook.Add("HotdogVendor_HasRoom", "MyInv_HasRoom", function(ply)
            return MyInventory.HasSpace(ply) -- return true/false
        end)

        hook.Add("HotdogVendor_GiveItem", "MyInv_Give", function(ply, itemData)
            MyInventory.AddItem(ply, "hotdog", 1)
            return true -- returning any non-nil/true value marks it as handled
        end)

        hook.Add("HotdogVendor_RemoveItem", "MyInv_Remove", function(ply, itemId)
            return MyInventory.RemoveItem(ply, "hotdog", 1) -- return true if removed
        end)

    If you don't add these hooks, the addon uses its own minimal built-in
    inventory automatically (bind a key to the "hdv_openinventory" console
    command to view/eat items from it) so nothing breaks out of the box.
--]]

HOTDOGVENDOR.Inventory = HOTDOGVENDOR.Inventory or {}

local FALLBACK_MAX_ITEMS = 30

local function fallbackInv(ply)
    ply.HDV_Inventory = ply.HDV_Inventory or {}
    return ply.HDV_Inventory
end

function HOTDOGVENDOR.SyncFallbackInventory(ply)
    if not IsValid(ply) then return end
    net.Start(HOTDOGVENDOR.Net.InventorySync)
        net.WriteTable(ply.HDV_Inventory or {})
    net.Send(ply)
end

function HOTDOGVENDOR.Inventory.HasRoom(ply)
    local override = hook.Run("HotdogVendor_HasRoom", ply)
    if override ~= nil then return override end

    local inv = fallbackInv(ply)
    local count = 0
    for _, stack in pairs(inv) do count = count + (stack.amount or 1) end
    return count < FALLBACK_MAX_ITEMS
end

function HOTDOGVENDOR.Inventory.GiveHotdog(ply)
    local handled = hook.Run("HotdogVendor_GiveItem", ply, HOTDOGVENDOR.Config.HotdogItem)
    if handled then return end

    local inv = fallbackInv(ply)
    local cfg = HOTDOGVENDOR.Config.HotdogItem

    for _, stack in pairs(inv) do
        if stack.id == "hotdog" and stack.amount < cfg.maxStack then
            stack.amount = stack.amount + 1
            HOTDOGVENDOR.SyncFallbackInventory(ply)
            return
        end
    end

    table.insert(inv, {id = "hotdog", name = cfg.name, model = cfg.model, amount = 1})
    HOTDOGVENDOR.SyncFallbackInventory(ply)
end

-- Returns true if a hot dog was found and removed.
function HOTDOGVENDOR.Inventory.RemoveHotdog(ply)
    local handled = hook.Run("HotdogVendor_RemoveItem", ply, "hotdog")
    if handled ~= nil then return handled end

    local inv = fallbackInv(ply)
    for i, stack in ipairs(inv) do
        if stack.id == "hotdog" then
            stack.amount = stack.amount - 1
            if stack.amount <= 0 then table.remove(inv, i) end
            HOTDOGVENDOR.SyncFallbackInventory(ply)
            return true
        end
    end
    return false
end
