--[[
    Customer-facing purchase menu.
    PLACEMENT: garrysmod/addons/hotdog_vendor/lua/hotdogvendor/cl_vgui_purchase.lua
--]]

function HOTDOGVENDOR.OpenPurchaseMenu(ent)
    if IsValid(HOTDOGVENDOR.PurchaseFrame) then HOTDOGVENDOR.PurchaseFrame:Remove() end
    local cfg = HOTDOGVENDOR.Config

    local frame = vgui.Create("DFrame")
    frame:SetSize(300, 230)
    frame:Center()
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame:MakePopup()
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, cfg.Colors.Background)
        draw.RoundedBox(8, 0, 0, w, 36, cfg.Colors.Accent)
        draw.SimpleText("Hot Dog Stand", "DermaDefaultBold", 12, 18, cfg.Colors.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    HOTDOGVENDOR.PurchaseFrame = frame

    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetText("X")
    closeBtn:SetSize(24, 24)
    closeBtn:SetPos(300 - 32, 6)
    closeBtn.DoClick = function() frame:Remove() end

    local info = vgui.Create("DLabel", frame)
    info:SetPos(20, 50)
    info:SetSize(260, 70)
    info:SetFont("DermaDefault")
    info:SetTextColor(cfg.Colors.Text)
    info:SetWrap(true)

    local buyBtn = vgui.Create("DButton", frame)
    buyBtn:SetPos(20, 160)
    buyBtn:SetSize(260, 44)
    buyBtn:SetFont("DermaDefaultBold")
    buyBtn.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and cfg.Colors.Accent or cfg.Colors.Panel)
    end
    buyBtn.DoClick = function()
        net.Start(HOTDOGVENDOR.Net.Purchase)
            net.WriteEntity(ent)
        net.SendToServer()
    end

    frame.Think = function(self)
        if not IsValid(ent) then
            self:Remove()
            return
        end
        local stock = ent:GetNWInt("Stock", 0)
        local price = ent:GetNWInt("Price", cfg.DefaultPrice)
        local ownerName = ent:GetNWString("OwnerName", "")

        info:SetText(string.format("Vendor: %s\nStock: %d\nPrice: %s",
            ownerName ~= "" and ownerName or "Unknown", stock, HOTDOGVENDOR.FormatMoney(price)))

        buyBtn:SetText(stock > 0 and ("Buy for " .. HOTDOGVENDOR.FormatMoney(price)) or "Out of Stock")
        buyBtn:SetEnabled(stock > 0)
    end
end
