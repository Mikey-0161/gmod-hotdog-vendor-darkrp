--[[
    Handles assigning ownership when a stand is bought from the F4 menu,
    enforces one stand per player, and removes a player's stand if they
    leave the Hot Dog Vendor job.
    PLACEMENT: garrysmod/addons/hotdog_vendor/lua/hotdogvendor/sv_job.lua
--]]

-- DarkRP fires this after spawning any entity bought through DarkRP.createEntity.
hook.Add("PlayerSpawnedSENT", "HotdogVendor_AssignOwner", function(ply, ent)
    if not IsValid(ent) or ent:GetClass() ~= "ent_hotdogstand" then return end

    local existing = HOTDOGVENDOR.GetPlayerStand(ply)
    if IsValid(existing) and existing ~= ent then
        ent:Remove()
        if DarkRP and DarkRP.notify then
            DarkRP.notify(ply, 1, 4, "You already own a hot dog stand!")
        end
        return
    end

    if ent.SetupOwner then
        ent:SetupOwner(ply)
    end
end)

-- Changing away from the vendor job removes any stand the player owns.
hook.Add("OnPlayerChangedTeam", "HotdogVendor_JobChange", function(ply, oldTeam, newTeam)
    if newTeam == TEAM_HOTDOGVENDOR then return end

    local stand = HOTDOGVENDOR.GetPlayerStand(ply)
    if IsValid(stand) then
        HOTDOGVENDOR.Debug(ply, "left the vendor job, removing their stand")
        stand:Remove()
    end
end)

hook.Add("playerBoughtCustomEntity", "HotdogVendor_LocalSync", function(ply, entTable, ent, price)
    if IsValid(ent) and ent:GetClass() == "ent_hotdogstand" then
        -- Secure the stand using Falco's Prop Protection (FPP)
        if ent.CPPISetOwner then 
            ent:CPPISetOwner(ply) 
        end
        
        -- Safe engine-level network sync for the client-side visuals
        ent:SetNWEntity("HDV_Owner", ply)
    end
end)