Default = {
    EnableDebug = false, -- This will enable debug mode and will print things in F8

    MenuAlignment = "left", -- This is the alignment of every menu in the resource. existing alignments: "center", "top-left", "left", "bottom" etc.

    Keys = true, -- If enabled you will need to have chames_keys to make it work.

    OwnMoreThanOneRoom = false, -- If enabled every player can buy multiple rooms.

    DiscInventory = { 
        Enabled = false, -- This will enable disc-inventoryhud as storages.

        Slots = 16
    },

    Raid = {
        Enabled = true, -- If enabled you will be able to raid rooms with the command chosen below.

        Command = "raidmotel", -- The command to raid the closest room default = /raidmotel.

        Weapon = {
            Enabled = true, -- If enabled you will need to carry a weapon added under.

            Hashes = { -- These are the weapons you will be able to raid with if the bool above is on ``true``.
                GetHashKey("WEAPON_HATCHET"),
                GetHashKey("WEAPON_BATTLEAXE")
            }
        },

        Job = {
            Enabled = true, -- If enabled you will need to be a specified job written below.

            Jobs = { -- These are all jobs allowed to breach the door.
                "police",
                "firefighter"
            }
        }
    }
}