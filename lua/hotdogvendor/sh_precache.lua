--[[
    Precaches models/sounds so they're ready the moment they're needed.
    PLACEMENT: garrysmod/addons/hotdog_vendor/lua/hotdogvendor/sh_precache.lua
--]]

if SERVER then
    local C = HOTDOGVENDOR.Config

    util.PrecacheModel(C.Model_Stand)
    util.PrecacheModel(C.Model_Hotdog)
    util.PrecacheModel(C.Model_Fallback)

    for _, snd in pairs(C.Sounds) do
        util.PrecacheSound(snd)
    end
end
