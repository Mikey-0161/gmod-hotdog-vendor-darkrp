--[[
    Server-authoritative cooking minigame (Simon Says).

    The server generates the color sequence, tracks each player's progress
    round-by-round, and is the ONLY thing that decides whether a hotdog is
    awarded. The client is just a display + input device - it cannot grant
    itself stock no matter what it sends.

    PLACEMENT: garrysmod/addons/hotdog_vendor/lua/hotdogvendor/sv_cooking.lua
--]]

HOTDOGVENDOR = HOTDOGVENDOR or {}

local COLORS = {1, 2, 3, 4} -- 1=Red 2=Blue 3=Green 4=Yellow (must match client button ids)

local function showSpeedForRound(round)
    local cfg = HOTDOGVENDOR.Config.Cooking
    local speed = cfg.BaseShowSpeed - (round - 1) * cfg.SpeedStep
    return math.max(speed, cfg.MinShowSpeed)
end

local function sequenceLengthForRound(round)
    local cfg = HOTDOGVENDOR.Config.Cooking
    return math.min(cfg.StartLength + (round - 1), cfg.MaxLength)
end

local function endSession(ent)
    if not IsValid(ent) then return end
    ent.HDV_Cooking = nil
    timer.Remove("HDV_CookTimeout_" .. ent:EntIndex())
end

function HOTDOGVENDOR.StartCookingSession(ply, ent)
    if not IsValid(ent) or ent:GetClass() ~= "ent_hotdogstand" then return end
    if not HOTDOGVENDOR.IsOwner(ent, ply) then return end
    if not HOTDOGVENDOR.IsWithinRange(ply, ent) then return end
    if not HOTDOGVENDOR.CanAct(ply, "startcook_" .. ent:EntIndex(), 0.5) then return end

    local stock = ent:GetNWInt("Stock", 0)
    local max = ent:GetNWInt("MaxStock", HOTDOGVENDOR.Config.MaxStock)
    if stock >= max then
        HOTDOGVENDOR.Notify(ply, "Stand Full", "error")
        return
    end
    if ent.HDV_Cooking and ent.HDV_Cooking.active then return end

    ent.HDV_Cooking = {
        round    = 0,
        sequence = {},
        inputIdx = 1,
        active   = true,
        player   = ply,
    }

    HOTDOGVENDOR.NextRound(ply, ent)

    -- Hard safety timeout in case a client stalls mid-session.
    timer.Create("HDV_CookTimeout_" .. ent:EntIndex(), HOTDOGVENDOR.Config.Cooking.RoundTimeout, 1, function()
        if IsValid(ent) and ent.HDV_Cooking and ent.HDV_Cooking.active then
            endSession(ent)
            if IsValid(ply) then
                net.Start(HOTDOGVENDOR.Net.CookingResult)
                    net.WriteBool(false)
                    net.WriteBool(true)
                net.Send(ply)
                HOTDOGVENDOR.Notify(ply, "Cooking Failed", "error")
            end
        end
    end)
end

function HOTDOGVENDOR.NextRound(ply, ent)
    local session = ent.HDV_Cooking
    if not session then return end

    session.round = session.round + 1
    session.inputIdx = 1

    local len = sequenceLengthForRound(session.round)
    while #session.sequence < len do
        table.insert(session.sequence, COLORS[math.random(1, #COLORS)])
    end
    while #session.sequence > len do
        table.remove(session.sequence, 1)
    end

    net.Start(HOTDOGVENDOR.Net.CookingRound)
        net.WriteEntity(ent)
        net.WriteUInt(session.round, 8)
        net.WriteUInt(#session.sequence, 8)
        for _, c in ipairs(session.sequence) do
            net.WriteUInt(c, 3)
        end
        net.WriteFloat(showSpeedForRound(session.round))
    net.Send(ply)

    -- Refresh the hard timeout each round so long games aren't cut short.
    timer.Adjust("HDV_CookTimeout_" .. ent:EntIndex(), HOTDOGVENDOR.Config.Cooking.RoundTimeout)
end

function HOTDOGVENDOR.HandleCookingInput(ply, ent, colorId)
    if not IsValid(ent) or ent:GetClass() ~= "ent_hotdogstand" then return end
    local session = ent.HDV_Cooking
    if not session or not session.active then return end
    if not HOTDOGVENDOR.IsOwner(ent, ply) then return end
    if session.player ~= ply then return end

    local expected = session.sequence[session.inputIdx]
    if colorId ~= expected then
        session.active = false
        endSession(ent)

        if HOTDOGVENDOR.Config.EnableSounds then
            ent:EmitSound(HOTDOGVENDOR.Config.Sounds.CookFail)
        end

        net.Start(HOTDOGVENDOR.Net.CookingResult)
            net.WriteBool(false)
            net.WriteBool(true)
        net.Send(ply)
        return
    end

    session.inputIdx = session.inputIdx + 1
    if session.inputIdx <= #session.sequence then return end

    -- Full sequence completed correctly -> award exactly one hot dog.
    local stock = ent:GetNWInt("Stock", 0)
    local max = ent:GetNWInt("MaxStock", HOTDOGVENDOR.Config.MaxStock)
    stock = math.min(stock + 1, max)
    ent:SetNWInt("Stock", stock)

    if HOTDOGVENDOR.Config.EnableSounds then
        ent:EmitSound(HOTDOGVENDOR.Config.Sounds.CookSuccess)
    end

    local isFull = stock >= max

    net.Start(HOTDOGVENDOR.Net.CookingResult)
        net.WriteBool(true)
        net.WriteBool(isFull)
    net.Send(ply)

    if isFull then
        endSession(ent)
        if HOTDOGVENDOR.Config.EnableSounds then
            ent:EmitSound(HOTDOGVENDOR.Config.Sounds.StockComplete)
        end
        HOTDOGVENDOR.Notify(ply, "Stand Full", "info")
        return
    end

    timer.Simple(0.9, function()
        if IsValid(ent) and ent.HDV_Cooking and ent.HDV_Cooking.active then
            HOTDOGVENDOR.NextRound(ply, ent)
        end
    end)
end

function HOTDOGVENDOR.CancelCookingSession(ply, ent)
    if not IsValid(ent) then return end
    if HOTDOGVENDOR.IsOwner(ent, ply) then
        endSession(ent)
    end
end
