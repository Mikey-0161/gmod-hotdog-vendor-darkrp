--[[
    Minimal fallback inventory viewer. Only meaningful if your server has NOT
    hooked up a real inventory addon via HotdogVendor_GiveItem/HasRoom/RemoveItem
    (see sv_inventory.lua) - in that case this is what holds/shows purchased
    hot dogs. Bind a key to it, e.g.:  bind "b" "hdv_openinventory"
    PLACEMENT: garrysmod/addons/hotdog_vendor/lua/hotdogvendor/cl_vgui_inventory.lua
--]]

HOTDOGVENDOR.FallbackInventory = HOTDOGVENDOR.FallbackInventory or {}

function HOTDOGVENDOR.RefreshFallbackInventory()
    local frame = HOTDOGVENDOR.FallbackInvFrame
    if not IsValid(frame) then return end

    frame.List:Clear(true)

    if #HOTDOGVENDOR.FallbackInventory == 0 then
        local empty = vgui.Create("DLabel")
        empty:SetText("Your inventory is empty.")
        empty:SetTextColor(HOTDOGVENDOR.Config.Colors.SubText)
        empty:SizeToContents()
        frame.List:AddItem(empty)
        return
    end

    for _, stack in ipairs(HOTDOGVENDOR.FallbackInventory) do
        local row = vgui.Create("DPanel")
        row:SetSize(230, 40)
        row.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, HOTDOGVENDOR.Config.Colors.Panel)
            draw.SimpleText(stack.name .. " x" .. stack.amount, "DermaDefault", 8, h / 2,
                HOTDOGVENDOR.Config.Colors.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        local useBtn = vgui.Create("DButton", row)
        useBtn:SetText("Use")
        useBtn:SetSize(50, 26)
        useBtn:SetPos(230 - 58, 7)
        useBtn.DoClick = function()
            if stack.id == "hotdog" then
                net.Start(HOTDOGVENDOR.Net.EatItem)
                net.SendToServer()
            end
        end

        frame.List:AddItem(row)
    end
end

concommand.Add("hdv_openinventory", function()
    if IsValid(HOTDOGVENDOR.FallbackInvFrame) then
        HOTDOGVENDOR.FallbackInvFrame:Remove()
        return
    end

    local cfg = HOTDOGVENDOR.Config
    local frame = vgui.Create("DFrame")
    frame:SetSize(260, 320)
    frame:Center()
    frame:SetTitle("Hot Dog Inventory (fallback)")
    frame:MakePopup()
    HOTDOGVENDOR.FallbackInvFrame = frame

    local list = vgui.Create("DPanelList", frame)
    list:SetPos(10, 30)
    list:SetSize(240, 280)
    list:EnableVerticalScrollbar(true)
    frame.List = list

    HOTDOGVENDOR.RefreshFallbackInventory()
end)
