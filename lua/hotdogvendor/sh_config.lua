--[[
    Central configuration.
    PLACEMENT: garrysmod/addons/hotdog_vendor/lua/hotdogvendor/sh_config.lua
    Everything gameplay-related can be tuned from this single file.
--]]

HOTDOGVENDOR = HOTDOGVENDOR or {}
HOTDOGVENDOR.Config = HOTDOGVENDOR.Config or {}

local C = HOTDOGVENDOR.Config

-- === Job / Shop ===
C.JobName            = "Hot Dog Vendor"
C.EntityShopName      = "Hot Dog Stand"
C.EntityShopCategory  = "Food Vendors"
C.EntityShopPrice     = 250     -- keep in sync with darkrpmodification/entities.lua
C.MaxStandsPerPlayer  = 1

-- === Models ===
C.Model_Stand    = "models/hotdogstand.mdl"
C.Model_Hotdog   = "models/hotdog.mdl"
C.Model_Fallback = "models/props_c17/oildrum001.mdl" -- used only if the models above are missing

-- === Stock / Pricing ===
C.MaxStock     = 20
C.MinSellPrice = 10
C.MaxSellPrice = 500
C.DefaultPrice = 25

-- === Cooking minigame (Simon Says) ===
C.Cooking = {
    StartLength   = 1,     -- sequence length on round 1
    MaxLength     = 8,     -- difficulty cap; game keeps going at this length after
    BaseShowSpeed = 0.6,   -- seconds each color is shown/held on round 1
    MinShowSpeed  = 0.22,  -- fastest the game will ever get
    SpeedStep     = 0.035, -- seconds shaved off per round
    RoundTimeout  = 30,    -- hard server-side timeout (seconds) per cooking session
}

-- === Hunger integration ===
C.EnableHungerSupport = true
C.HungerRestoreAmount = 25

-- === Inventory integration ===
C.EnableInventorySupport = true
C.HotdogItem = {
    name        = "Hot Dog",
    description = "Freshly cooked hot dog.",
    model       = C.Model_Hotdog,
    category    = "Food",
    weight      = 0.05,
    maxStack    = 100,
    droppable   = true,
    tradable    = true,
    usable      = true,
}

-- === Economy ===
C.RefundPercent = 0.65 -- refund fraction of EntityShopPrice when an owner removes their own stand

-- === Feature toggles ===
C.EnableSounds     = true
C.EnableEffects    = true
C.EnableAnimations = true

-- === Sounds ===
-- Defaults use stock HL2 sounds so the addon works out of the box.
-- Drop your own files in sound/hotdogvendor/ and point these at them if you want custom audio.
C.Sounds = {
    ButtonClick   = "buttons/button15.wav",
    CookSuccess   = "buttons/button14.wav",
    CookFail      = "buttons/button10.wav",
    CashRegister  = "cart/cart_beep1.wav",
    Purchase      = "items/ammo_pickup.wav",
    Eat           = "npc/barnacle/barnacle_gulp1.wav",
    StockComplete = "hl1/fvox/beep.wav",
}

-- === UI Colors ===
C.Colors = {
    Background = Color(24, 24, 28, 245),
    Panel      = Color(32, 32, 38, 255),
    Accent     = Color(235, 110, 40, 255),
    Success    = Color(80, 200, 120, 255),
    Fail       = Color(220, 80, 80, 255),
    Text       = Color(235, 235, 235, 255),
    SubText    = Color(170, 170, 175, 255),
}

-- === Misc ===
C.MaxInteractDistance = 96 -- server-enforced max distance (units) for any stand interaction
C.DebugMode = false
