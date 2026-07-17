# 🌭 Hot Dog Vendor Addon (Super Easy Setup Guide!)

Welcome! This guide will help you install your custom Hot Dog Vendor job and cooking stand in less than 5 minutes. No coding experience needed! 

---

## 📦 What is inside the download?
When you unzip your download, you will see two main folders:
1. `darkrpmodification` (Goes into your existing server files)
2. `hotdog_vendor` (Goes straight into your main addons folder)

---

## 🛠️ Step 1: Copy & Paste the F4 Menu Files
Almost every DarkRP server uses an addon called `darkrpmodification` to hold custom jobs and items. We need to add our hot dog vendor and stand into it.

⚠️ **IMPORTANT:** Do NOT delete or overwrite your old files! Just copy and paste our text inside them.

### A) Add the Custom Job 
1. Open this file on your server: `addons/darkrpmodification/lua/darkrp_customthings/jobs.lua`
2. Scroll all the way to the very bottom of the file.
3. Paste the code from our bundle's `jobs.lua` right at the bottom on a brand new line.

### B) Add the Vendor to the Shop 
1. Open this file on your server: `addons/darkrpmodification/lua/darkrp_customthings/entities.lua`
2. Scroll all the way to the very bottom of the file.
3. Paste the code from our bundle's `entities.lua` right at the bottom on a brand new line.

---

## 📂 Step 2: Drop in the Main Addon Folder
This part is super easy! 

1. Find the folder named `hotdog_vendor` in your download.
2. Drag and drop that entire folder straight into your server's main addon directory: `garrysmod/addons/`

*That's it! Your directory should now look like this: `garrysmod/addons/hotdog_vendor/`*

---

## 🎨 Step 3: Get the 3D Models
Your players need to see the hot dog stand and the delicious food! 

1. Go to this Steam Workshop page: https://steamcommunity.com/sharedfiles/filedetails/?id=171255331
2. Click the green **+ Subscribe** button to download the models.
3. Add this Workshop ID to your server's workshop collection so your players download it automatically when they join!

---

## ⚙️ How to Connect Your Own Inventory (Optional)
By default, this addon has a built-in pocket inventory system so it works instantly. 

If you use a premium inventory addon (like ItemStore, Xenin, Void, etc.) and want hot dogs to go into your real bags instead, follow these 3 steps:
1. Create a clean file inside your inventory addon named `sv_integration.lua`.
2. Place it inside your inventory addon's server folder.
3. Paste these lines inside it to link them together:

```lua

hook.Add("HotdogVendor_HasRoom", "MyInv_HasRoom", function(ply)
    return MyInventory.HasSpace(ply) -- Tells the stand if your bag is full
end)

hook.Add("HotdogVendor_GiveItem", "MyInv_Give", function(ply, itemData)
    MyInventory.AddItem(ply, "hotdog", 1) -- Puts the hot dog in your bag
    return true 
end)

hook.Add("HotdogVendor_RemoveItem", "MyInv_Remove", function(ply, itemId)
    return MyInventory.RemoveItem(ply, "hotdog", 1) -- Takes it out when eaten
end)
```

---

## 👑 Admin Cheat Codes (Console Commands)
Look directly at a hot dog stand in-game, open your developer console (`~`), and type these commands to control it:

* `hdv_removestand` → 🚫 Instantly deletes the stand you are looking at.
* `hdv_resetstock`  → 🧼 Empties the stand back to 0 hot dogs.
* `hdv_resetprice`  → 💵 Resets the hot dog price back to default.
* `hdv_owner`       → 🗣️ Prints the name of the player who owns it into chat.
* `hdv_spawnstand`  → 🪄 Magic-spawns a stand right where you are looking.

---

## ⭐ Cool Features Already Handled For You:
* **Anti-Cheat Cooking:** The server creates and checks the minigame patterns. Hackers cannot spawn hot dogs out of nowhere!
* **Job Lock:** Only players who change their job to "Hot Dog Vendor" can interact with or buy the stand.
* **Smart Cleanup:** If a vendor leaves the server or changes their job to a police officer, their hot dog stand vanishes automatically so it doesn't clutter the map.
* **Lag Free:** The physical hot dogs sitting on the counter are high-performance client models. They won't cause server lag or drop your server's tickrate!
