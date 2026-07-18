--[[
    Simon Says cooking minigame UI.
    The client only ever displays what the server sent (sh_config, then
    sv_cooking.lua's CookingRound message) and reports each button press
    back to the server for real validation - it never grants itself stock.
    PLACEMENT: garrysmod/addons/hotdog_vendor/lua/hotdogvendor/cl_vgui_cooking.lua
--]]

HOTDOGVENDOR.CookingState = HOTDOGVENDOR.CookingState or nil

local COLOR_DEFS = {
    {id = 1, name = "Red",    col = Color(210, 60, 60)},
    {id = 2, name = "Blue",   col = Color(60, 110, 210)},
    {id = 3, name = "Green",  col = Color(70, 180, 90)},
    {id = 4, name = "Yellow", col = Color(220, 190, 60)},
}

local function buildCookingFrame(ent)
    local cfg = HOTDOGVENDOR.Config

    local frame = vgui.Create("DFrame")
    frame:SetSize(320, 440)
    frame:Center()
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame:MakePopup()
    frame:SetKeyboardInputEnabled(false)
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, cfg.Colors.Background)
        draw.RoundedBox(8, 0, 0, w, 36, cfg.Colors.Accent)
        draw.SimpleText("Cooking — Simon Says", "DermaDefaultBold", 12, 18, cfg.Colors.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local roundLabel = vgui.Create("DLabel", frame)
    roundLabel:SetPos(0, 46)
    roundLabel:SetSize(320, 24)
    roundLabel:SetContentAlignment(5)
    roundLabel:SetFont("DermaDefaultBold")
    roundLabel:SetTextColor(cfg.Colors.Text)
    frame.RoundLabel = roundLabel

    local statusLabel = vgui.Create("DLabel", frame)
    statusLabel:SetPos(0, 70)
    statusLabel:SetSize(320, 20)
    statusLabel:SetContentAlignment(5)
    statusLabel:SetTextColor(cfg.Colors.SubText)
    frame.StatusLabel = statusLabel

    local btnHolder = vgui.Create("DPanel", frame)
    btnHolder:SetPos(20, 110)
    btnHolder:SetSize(280, 280)
    btnHolder.Paint = function() end

    frame.Buttons = {}
    local positions = {
        {0, 0}, {140, 0},
        {0, 140}, {140, 140},
    }
    for i, def in ipairs(COLOR_DEFS) do
        local b = vgui.Create("DButton", btnHolder)
        b:SetPos(positions[i][1], positions[i][2])
        b:SetSize(140, 140)
        b:SetText("")
        b:SetEnabled(false)
        b.ColorDef = def
        b.Lit = false
        b.Paint = function(self, w, h)
            local base = def.col
            local c = self.Lit and base or Color(base.r * 0.4, base.g * 0.4, base.b * 0.4)
            draw.RoundedBox(10, 4, 4, w - 8, h - 8, c)
            draw.SimpleText(def.name, "DermaDefaultBold", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        b.DoClick = function(self)
            if HOTDOGVENDOR.Config.EnableSounds then
                surface.PlaySound(HOTDOGVENDOR.Config.Sounds.ButtonClick)
            end
            
            -- FIX: Force the clicked button to light up visually for 0.15 seconds
            self.Lit = true
            timer.Simple(0.15, function()
                if IsValid(self) then self.Lit = false end
            end)

            HOTDOGVENDOR.SubmitCookingInput(def.id)
        end
        frame.Buttons[def.id] = b
    end

    local cancelBtn = vgui.Create("DButton", frame)
    cancelBtn:SetPos(20, 400)
    cancelBtn:SetSize(280, 30)
    cancelBtn:SetText("Cancel")
    cancelBtn.DoClick = function()
        net.Start(HOTDOGVENDOR.Net.CookingCancel)
            net.WriteEntity(ent)
        net.SendToServer()
        frame:Remove()
        HOTDOGVENDOR.CookingState = nil
    end

    return frame
end

local function flashButton(frame, colorId, duration, callback)
    local btn = frame.Buttons[colorId]
    if not IsValid(btn) then
        if callback then callback() end
        return
    end
    btn.Lit = true
    timer.Simple(duration, function()
        if IsValid(btn) then btn.Lit = false end
        if callback then callback() end
    end)
end

function HOTDOGVENDOR.PlayCookingRound(ent, round, seq, speed)
    if not IsValid(HOTDOGVENDOR.CookingFrame) then
        HOTDOGVENDOR.CookingFrame = buildCookingFrame(ent)
    end
    local frame = HOTDOGVENDOR.CookingFrame

    frame.RoundLabel:SetText("Round " .. round)
    frame.StatusLabel:SetText("Watch closely...")

    HOTDOGVENDOR.CookingState = {
        ent = ent,
        seq = seq,
        expectedIdx = 1,
        accepting = false,
    }

    for _, btn in pairs(frame.Buttons) do btn:SetEnabled(false) end

    local i = 1
    local function playNext()
        if not IsValid(frame) then return end
        if i > #seq then
            frame.StatusLabel:SetText("Your turn!")
            HOTDOGVENDOR.CookingState.accepting = true
            for _, btn in pairs(frame.Buttons) do btn:SetEnabled(true) end
            return
        end
        flashButton(frame, seq[i], speed * 0.8, function()
            i = i + 1
            timer.Simple(speed * 0.2, playNext)
        end)
    end
    playNext()
end

function HOTDOGVENDOR.SubmitCookingInput(colorId)
    local state = HOTDOGVENDOR.CookingState
    if not state or not state.accepting then return end
    if not IsValid(state.ent) then return end

    -- Report the press to the server; it decides pass/fail authoritatively.
    net.Start(HOTDOGVENDOR.Net.CookingInput)
        net.WriteEntity(state.ent)
        net.WriteUInt(colorId, 3)
    net.SendToServer()

    -- Local, non-authoritative feedback so the UI feels instant.
    local expected = state.seq[state.expectedIdx]
    if colorId ~= expected then
        state.accepting = false
        if IsValid(HOTDOGVENDOR.CookingFrame) then
            HOTDOGVENDOR.CookingFrame.StatusLabel:SetText("Wrong! Cooking failed.")
            for _, btn in pairs(HOTDOGVENDOR.CookingFrame.Buttons) do btn:SetEnabled(false) end
        end
        return
    end

    state.expectedIdx = state.expectedIdx + 1
    if state.expectedIdx > #state.seq then
        state.accepting = false
        if IsValid(HOTDOGVENDOR.CookingFrame) then
            HOTDOGVENDOR.CookingFrame.StatusLabel:SetText("Nice! Waiting on the kitchen...")
            for _, btn in pairs(HOTDOGVENDOR.CookingFrame.Buttons) do btn:SetEnabled(false) end
        end
    end
end

function HOTDOGVENDOR.OnCookingResult(success, ended)
    local frame = HOTDOGVENDOR.CookingFrame
    if not IsValid(frame) then return end

    frame.StatusLabel:SetText(success and "Hot dog cooked!" or "Cooking failed.")
    if HOTDOGVENDOR.Config.EnableSounds then
        surface.PlaySound(success and HOTDOGVENDOR.Config.Sounds.CookSuccess or HOTDOGVENDOR.Config.Sounds.CookFail)
    end

    if ended then
        timer.Simple(1.2, function()
            if IsValid(frame) then frame:Remove() end
            HOTDOGVENDOR.CookingState = nil
        end)
    end
end
