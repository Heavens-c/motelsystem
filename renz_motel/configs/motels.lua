Furnishings = {
    WARDROBE_CLOTHES = function(motelUUID)
        OpenWardrobe(motelUUID)
    end,
    FRIDGE_STORAGE = function(motelUUID)
        OpenStorage("FRIDGE_STORAGE", motelUUID)
    end,
    DRAWER_STORAGE = function(motelUUID)
        OpenStorage("DRAWER_STORAGE", motelUUID)
    end,
    USE_SINK = function(motelUUID)
        Heap.ESX.ShowNotification("You washed your hands!")
    end
}

RentTime = {
    Days = 7 -- If you rent the motel this is the cooldown on each payment.
}

Storage = {
    BlackMoney = true, -- Enable this if you want to store black_money.
    Weapons = true -- Enable this if you want to store weapons.
}

Motels = {
    {
        Name = "Starlite Motel", -- Blip name on the map.
        Location = vector3(959.91882324219, -201.896484375, 73.145874023438), -- Blip location on the map.
        Doors = {
            597055185 -- This is the hash of the door, you can add more if there is different models.
        },
        Prices = {
            Buy = 1199, -- If you choose to buy the motel this is the amount that will be removed from the player purchasing.
            Rent = 499 -- If you choose to rent the motel this is teh amount that will be payed each day specified above.
        },
        Furnishing = {
            {
                Offset = vector3(-1.9, 1.85, -.5),
                Distance = 1.0,
                Text = "Wardrobe",
                Function = Furnishings.WARDROBE_CLOTHES
            },
            {
                Offset = vector3(-3.2, 1.85, -.5),
                Distance = 1.0,
                Text = "Fridge",
                Function = Furnishings.FRIDGE_STORAGE
            },
            {
                Offset = vector3(.6, -.85, -.9),
                Distance = 1.0,
                Text = "Drawer",
                Function = Furnishings.DRAWER_STORAGE
            },
            {
                Offset = vector3(3.165, 2.3, -.5),
                Distance = 1.0,
                Text = "Sink",
                Function = Furnishings.USE_SINK
            },
        }
    },
    {
        Name = "Pink Cage Motel", -- Blip name on the map.
        Location = vector3(324.42291259766, -210.45881652832, 54.086227416992), -- Blip location on the map.
        Doors = {
            720693755 -- This is the hash of the door, you can add more if there is different models.
        },
        Prices = {
            Buy = 2999, -- If you choose to buy the motel this is the amount that will be removed from the player purchasing.
            Rent = 1099 -- If you choose to rent the motel this is teh amount that will be payed each day specified above.
        },
        Furnishing = {
            {
                Offset = vector3(18.8, -6.95, -5.0),
                Distance = 1.0,
                Text = "Wardrobe",
                Function = Furnishings.WARDROBE_CLOTHES
            },
            {
                Offset = vector3(18.8, -4.54, -5.4),
                Distance = 1.0,
                Text = "Drawer",
                Function = Furnishings.DRAWER_STORAGE
            },
            {
                Offset = vector3(21.8, -12.15, -5.0),
                Distance = 1.0,
                Text = "Sink",
                Function = Furnishings.USE_SINK
            },
        }
    },
    {
        Name = "Sandy Motel", -- Blip name on the map.
        Location = vector3(1142.3071289063, 2663.982421875, 38.160976409912), -- Blip location on the map.
        DoorOffset = vector3(-1.0, 0.0, 0.0),
        Doors = {
            -1663022887 -- This is the hash of the door, you can add more if there is different models.
        },
        Prices = {
            Buy = 2999, -- If you choose to buy the motel this is the amount that will be removed from the player purchasing.
            Rent = 1099 -- If you choose to rent the motel this is teh amount that will be payed each day specified above.
        },
        Furnishing = {
            {
                Offset = vector3(2.85, -.8, -1.45),
                Distance = 1.0,
                Text = "Wardrobe",
                Function = Furnishings.WARDROBE_CLOTHES
            },
            {
                Offset = vector3(2.6, 1.6, -1.8),
                Distance = 1.0,
                Text = "Drawer",
                Function = Furnishings.DRAWER_STORAGE
            },
            {
                Offset = vector3(-.8, -.69, -1.7),
                Distance = 1.0,
                Text = "Sink",
                Function = Furnishings.USE_SINK
            },
        }
    }
}