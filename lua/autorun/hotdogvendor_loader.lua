--[[
    Hot Dog Vendor addon loader.
    Runs automatically on both client and server (lua/autorun/ is auto-included).
    Do not move or rename this file.
--]]

local base = "hotdogvendor/"

-- Loaded on BOTH realms, in this order
local sharedFiles = {
    "sh_config.lua",
    "sh_util.lua",
    "sh_precache.lua",
}

-- Server-only logic
local serverFiles = {
    "sv_core.lua",
    "sv_job.lua",
    "sv_cooking.lua",
    "sv_inventory.lua",
    "sv_hunger.lua",
    "sv_purchase.lua",
    "sv_net.lua",
    "sv_admin.lua",
}

-- Client-only UI
local clientFiles = {
    "cl_notifications.lua",
    "cl_vgui_management.lua",
    "cl_vgui_purchase.lua",
    "cl_vgui_cooking.lua",
    "cl_vgui_inventory.lua",
    "cl_net.lua",
}

for _, f in ipairs(sharedFiles) do
    if SERVER then AddCSLuaFile(base .. f) end
    include(base .. f)
end

if SERVER then
    for _, f in ipairs(clientFiles) do
        AddCSLuaFile(base .. f)
    end
    for _, f in ipairs(serverFiles) do
        include(base .. f)
    end
end

if CLIENT then
    for _, f in ipairs(clientFiles) do
        include(base .. f)
    end
end
