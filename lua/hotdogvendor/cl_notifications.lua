--[[
    Modern stacking toast notifications.
    PLACEMENT: garrysmod/addons/hotdog_vendor/lua/hotdogvendor/cl_notifications.lua
--]]

HOTDOGVENDOR.ActiveToasts = HOTDOGVENDOR.ActiveToasts or {}

function HOTDOGVENDOR.ShowNotification(message, kind)
    local cfg = HOTDOGVENDOR.Config
    local colorMap = {
        success = cfg.Colors.Success,
        error   = cfg.Colors.Fail,
        info    = cfg.Colors.Accent,
    }
    local barColor = colorMap[kind] or cfg.Colors.Accent

    local toast = vgui.Create("DPanel")
    toast:SetSize(280, 46)
    toast:SetPos(ScrW() - 300, 60 + (#HOTDOGVENDOR.ActiveToasts * 52))
    toast.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, cfg.Colors.Panel)
        draw.RoundedBox(6, 0, 0, 4, h, barColor)
        draw.SimpleText(message, "DermaDefaultBold", 16, h / 2, cfg.Colors.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    toast:SetAlpha(0)
    if HOTDOGVENDOR.Config.EnableAnimations then
        toast:AlphaTo(255, 0.25, 0)
    else
        toast:SetAlpha(255)
    end

    table.insert(HOTDOGVENDOR.ActiveToasts, toast)

    timer.Simple(3, function()
        if not IsValid(toast) then return end
        local function cleanup()
            if IsValid(toast) then toast:Remove() end
            for i, t in ipairs(HOTDOGVENDOR.ActiveToasts) do
                if t == toast then
                    table.remove(HOTDOGVENDOR.ActiveToasts, i)
                    break
                end
            end
        end

        if HOTDOGVENDOR.Config.EnableAnimations then
            toast:AlphaTo(0, 0.3, 0, cleanup)
        else
            cleanup()
        end
    end)
end
