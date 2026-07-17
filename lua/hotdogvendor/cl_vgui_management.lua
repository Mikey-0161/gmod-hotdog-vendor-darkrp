--[[
    Owner-facing "Management Menu" derma panel: price control, stock/earnings
    display, start cooking, and remove stand.
    PLACEMENT: garrysmod/addons/hotdog_vendor/lua/hotdogvendor/cl_vgui_management.lua
--]]

function HOTDOGVENDOR.UpdateEarnings(ent, today, lifetime)
    if not IsValid(ent) then return end
    ent.HDV_Today = today
    ent.HDV_Lifetime = lifetime
end

function HOTDOGVENDOR.OpenManagementMenu(ent, today, lifetime)
    if IsValid(HOTDOGVENDOR.ManagementFrame) then HOTDOGVENDOR.ManagementFrame:Remove() end
    local cfg = HOTDOGVENDOR.Config

    local frame = vgui.Create("DFrame")
    frame:SetSize(360, 420)
    frame:Center()
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame:MakePopup()
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, cfg.Colors.Background)
        draw.RoundedBox(8, 0, 0, w, 36, cfg.Colors.Accent)
        draw.SimpleText("Hot Dog Stand — Management", "DermaDefaultBold", 12, 18, cfg.Colors.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    HOTDOGVENDOR.ManagementFrame = frame

    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetText("X")
    closeBtn:SetSize(24, 24)
    closeBtn:SetPos(360 - 32, 6)
    closeBtn.DoClick = function() frame:Remove() end

    local stockLabel = vgui.Create("DLabel", frame)
    stockLabel:SetPos(20, 50)
    stockLabel:SetSize(320, 24)
    stockLabel:SetFont("DermaDefaultBold")
    stockLabel:SetTextColor(cfg.Colors.Text)

    local earningsLabel = vgui.Create("DLabel", frame)
    earningsLabel:SetPos(20, 78)
    earningsLabel:SetSize(320, 40)
    earningsLabel:SetFont("DermaDefault")
    earningsLabel:SetTextColor(cfg.Colors.SubText)

    local function refreshLabels()
        if not IsValid(ent) then return end
        local stock = ent:GetNWInt("Stock", 0)
        local max = ent:GetNWInt("MaxStock", cfg.MaxStock)
        stockLabel:SetText(string.format("Stock: %d / %d", stock, max))
        earningsLabel:SetText(string.format("Today: %s     Lifetime: %s",
            HOTDOGVENDOR.FormatMoney(ent.HDV_Today or today or 0),
            HOTDOGVENDOR.FormatMoney(ent.HDV_Lifetime or lifetime or 0)))
    end
    refreshLabels()

    local priceLabel = vgui.Create("DLabel", frame)
    priceLabel:SetPos(20, 128)
    priceLabel:SetSize(200, 20)
    priceLabel:SetText("Selling Price")
    priceLabel:SetFont("DermaDefaultBold")
    priceLabel:SetTextColor(cfg.Colors.Text)

    local priceSlider = vgui.Create("DNumSlider", frame)
    priceSlider:SetPos(16, 150)
    priceSlider:SetSize(328, 40)
    priceSlider:SetText("")
    priceSlider:SetMin(cfg.MinSellPrice)
    priceSlider:SetMax(cfg.MaxSellPrice)
    priceSlider:SetDecimals(0)
    priceSlider:SetValue(ent:GetNWInt("Price", cfg.DefaultPrice))

    local applyBtn = vgui.Create("DButton", frame)
    applyBtn:SetPos(20, 195)
    applyBtn:SetSize(155, 32)
    applyBtn:SetText("Apply Price")
    applyBtn.DoClick = function()
        net.Start(HOTDOGVENDOR.Net.SetPrice)
            net.WriteEntity(ent)
            net.WriteInt(math.Round(priceSlider:GetValue()), 32)
        net.SendToServer()
    end

    local resetBtn = vgui.Create("DButton", frame)
    resetBtn:SetPos(185, 195)
    resetBtn:SetSize(155, 32)
    resetBtn:SetText("Reset Price")
    resetBtn.DoClick = function()
        priceSlider:SetValue(cfg.DefaultPrice)
        net.Start(HOTDOGVENDOR.Net.SetPrice)
            net.WriteEntity(ent)
            net.WriteInt(cfg.DefaultPrice, 32)
        net.SendToServer()
    end

    local cookBtn = vgui.Create("DButton", frame)
    cookBtn:SetPos(20, 240)
    cookBtn:SetSize(320, 44)
    cookBtn:SetText("START COOKING")
    cookBtn:SetFont("DermaDefaultBold")
    cookBtn.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and cfg.Colors.Accent or cfg.Colors.Panel)
    end
    cookBtn.DoClick = function()
        frame:Remove()
        net.Start(HOTDOGVENDOR.Net.RequestCook)
            net.WriteEntity(ent)
        net.SendToServer()
    end

    local removeBtn = vgui.Create("DButton", frame)
    removeBtn:SetPos(20, 300)
    removeBtn:SetSize(320, 32)
    removeBtn:SetText(string.format("Remove Stand (%.0f%% refund)", cfg.RefundPercent * 100))
    removeBtn.DoClick = function()
        Derma_Query("Are you sure you want to remove your stand?", "Confirm", "Yes", function()
            net.Start(HOTDOGVENDOR.Net.RemoveStand)
                net.WriteEntity(ent)
            net.SendToServer()
            frame:Remove()
        end, "No", function() end)
    end

    frame.Think = function(self)
        if not IsValid(ent) then
            self:Remove()
            return
        end
        refreshLabels()
    end
end
