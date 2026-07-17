--[[
    Hunger integration layer.
    PLACEMENT: garrysmod/addons/hotdog_vendor/lua/hotdogvendor/sv_hunger.lua

    HOW TO HOOK UP YOUR SPECIFIC DARKRP HUNGER ADDON:
    Add this hook anywhere (its own folder is fine) and return true
    once you've restored hunger yourself - that fully overrides the
    fallback attempts below.

        hook.Add("HotdogVendor_RestoreHunger", "MyHunger_Restore", function(ply, amount)
            ply:setHunger(math.min(ply:getHunger() + amount, ply:getMaxHunger()))
            return true
        end)

    Without that hook, the addon tries a few common DarkRP hunger mod
    APIs automatically before giving up (safely, with no errors either way).
--]]

HOTDOGVENDOR.Hunger = HOTDOGVENDOR.Hunger or {}

function HOTDOGVENDOR.Hunger.Restore(ply, amount)
    if not HOTDOGVENDOR.Config.EnableHungerSupport then return end
    if not IsValid(ply) then return end

    if hook.Run("HotdogVendor_RestoreHunger", ply, amount) then return end

    -- Common convention #1: ply:setHunger()/ply:getHunger()/ply:getMaxHunger()
    if ply.setHunger and ply.getHunger then
        local maxHunger = (ply.getMaxHunger and ply:getMaxHunger()) or 100
        ply:setHunger(math.min(ply:getHunger() + amount, maxHunger))
        return
    end

    -- Common convention #2: ply:SetHunger()/ply:GetHunger()/ply:GetMaxHunger()
    if ply.SetHunger and ply.GetHunger then
        local maxHunger = (ply.GetMaxHunger and ply:GetMaxHunger()) or 100
        ply:SetHunger(math.min(ply:GetHunger() + amount, maxHunger))
        return
    end

    -- Last-resort generic NWInt convention used by several lightweight scripts
    if ply.SetNWInt and ply.GetNWInt then
        local cur = ply:GetNWInt("Hunger", 100)
        local maxHunger = ply:GetNWInt("MaxHunger", 100)
        ply:SetNWInt("Hunger", math.min(cur + amount, maxHunger))
        return
    end

    HOTDOGVENDOR.Debug("No compatible hunger API found for", ply, "- add a HotdogVendor_RestoreHunger hook for your addon.")
end
