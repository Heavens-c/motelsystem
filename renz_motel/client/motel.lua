Heap.Motels = {}

DrawMotel = function(motelUUID, motelData, doorHandle)
    local cachedMotel = Heap.Motels[motelUUID]

    DrawDoor(motelUUID, motelData, cachedMotel, doorHandle)

    if not cachedMotel then return end

    local interiorId = GetInteriorFromEntity(Heap.Ped)

    if interiorId == 0 then return end

    local pedCoords = GetEntityCoords(Heap.Ped)

    for _, offsetData in ipairs(motelData.Furnishing) do
        local offsetCoords = GetOffsetFromInteriorInWorldCoords(interiorId, offsetData.Offset)

        local dstCheck = #(pedCoords - offsetCoords)

        local isUsable = dstCheck <= offsetData.Distance
        local displayText = (isUsable and "[~y~G~s~] " or "") .. offsetData.Text

        if isUsable then
            if IsControlJustPressed(0, 47) then
                UseFurnishing(motelUUID, offsetData.Function)
            end
        end

        DrawScriptText(offsetCoords, displayText)
    end
end

DrawDoor = function(motelUUID, motelData, cachedMotel, doorHandle)
    local pedCoords = GetEntityCoords(Heap.Ped)

    local doorCoordsOffset = GetOffsetFromEntityInWorldCoords(doorHandle, motelData.DoorOffset or vector3(1.2, 0.0, 0.0))

    local dstCheck = #(pedCoords - doorCoordsOffset)

    local isUsable = dstCheck <= 1.0

    local doorDisplayText = "Room ~b~" .. string.sub(motelUUID, 5, 7) .. "~s~ | "

    if cachedMotel then 
        if cachedMotel.IsUnlocked then
            doorDisplayText = doorDisplayText .. (isUsable and "[~y~E~s~] " or "") .. "~g~Unlocked~s~"
        else
            doorDisplayText = doorDisplayText .. (isUsable and "[~y~E~s~] " or "") .. "~r~Locked~s~"
        end

        if cachedMotel.owner == Heap.Identifier then
            local isRented = cachedMotel.lastRent ~= -1

            doorDisplayText = doorDisplayText .. " | " .. (isUsable and "[~y~G~s~] " or "") .. "Cancel " .. (isRented and "Rent" or "Ownership")

            if isUsable and IsControlJustPressed(0, 47) then
                local input = OpenInput('Are you sure? Enter "CANCEL" to cancel room.', "CANCEL_MOTEL")

                if not input then return end
                if not (#input > 0) then return Heap.ESX.ShowNotification("Ok, happy living!") end
                if not (input == "CANCEL") then return Heap.ESX.ShowNotification("Ok, happy living!") end

                Heap.ESX.TriggerServerCallback("renz_motels:cancelMotel", function(canceled)
                    if canceled then
                        Heap.ESX.ShowNotification("You canceled your " .. (isRented and "rent" or "purchase") .. ", the motel is now anyones to take.")
                    else
                        Heap.ESX.ShowNotification("You can't cancel your motel, i'm sorry.")
                    end
                end, motelUUID)
            end 
        end

        if isUsable and IsControlJustPressed(0, 38) then
            if Default.Keys then
                if not exports.chames_keys then return Trace("Chames keys is not loaded, please start it if you're using keys.") end

                if not exports.chames_keys:HasKey(motelUUID) then return Heap.ESX.ShowNotification("You don't have the right key to use this lock.") end
            else
                if cachedMotel.owner ~= Heap.Identifier then return Heap.ESX.ShowNotification("You don't own this room and cannot use this lock.") end
            end

            Heap.ESX.TriggerServerCallback("renz_motels:toggleLock", function(toggled)
                if toggled then
                    Heap.ESX.ShowNotification("You " .. (cachedMotel.IsUnlocked and "locked" or "unlocked") .. " the door, remember to shut the door!")
                end
            end, motelUUID)
        end
    else
        if isUsable then
            if IsControlJustPressed(0, 47) then
                BuyMotel(motelUUID, false, motelData)
            elseif IsControlJustPressed(0, 38) then
                BuyMotel(motelUUID, true, motelData)
            end
        end

        doorDisplayText = doorDisplayText .. (isUsable and "[~y~G~s~] " or "") .. "Buy Room ~g~$" .. motelData.Prices.Buy .. "~s~ | " .. (isUsable and "[~y~E~s~] " or "") .. "Rent ~g~$" .. motelData.Prices.Rent .. "~s~/" .. RentTime.Days .. "d"
    end

    if not IsDoorRegisteredWithSystem(doorHandle) then
        AddDoorToSystem(doorHandle, GetEntityModel(doorHandle), GetEntityCoords(doorHandle), false, true, false) 
    end

    if DoorSystemGetDoorState(doorHandle) ~= (cachedMotel and (cachedMotel.IsUnlocked and 0 or 1) or 1) then
        DoorSystemSetDoorState(doorHandle, (cachedMotel and (cachedMotel.IsUnlocked and 0 or 1) or 1), true, true)
    end

    DrawScriptText(doorCoordsOffset, doorDisplayText)
end

BuyMotel = function(motelUUID, rentMotel, motelData)
    local input = OpenInput('Are you sure? Enter "BUY" to confirm.', "BUY_MOTEL")

    if not input then return end
    if not (#input > 0) then return Heap.ESX.ShowNotification("Ok, no worries, choose another room if you like.") end
    if not (input == "BUY") then return Heap.ESX.ShowNotification("Ok, no worries, choose another room if you like.") end

    Heap.ESX.TriggerServerCallback("renz_motels:buyMotel", function(bought)
        if bought then
            if rentMotel then
                Heap.ESX.ShowNotification("You rented the motel for $" .. motelData.Prices.Rent ..", next payment is in " .. RentTime.Days .. " days.")
            else
                Heap.ESX.ShowNotification("You bought the motel for $" .. motelData.Prices.Buy .. ".")
            end

            if Default.Keys then
                exports.chames_keys:AddKey({
                    id = motelUUID,
                    label = "Motel Key - " .. motelData.Name .. " - Room " .. string.sub(motelUUID, 5, 7)
                })
            end
        else
            Heap.ESX.ShowNotification("You don't afford this, or you already own a room.")
        end 
    end, motelUUID, rentMotel, motelData)
end

UseFurnishing = function(motelUUID, furnishingFunction)
    if furnishingFunction then
        furnishingFunction(motelUUID)

        Trace("Used Furnishing in motelUUID:", motelUUID)
    end
end

OpenWardrobe = function(motelUUID)
	Heap.ESX.TriggerServerCallback("renz_motels:getPlayerDressing", function(dressings)
		local menuElements = {}

		for dressingIndex, dressingLabel in ipairs(dressings) do
		    table.insert(menuElements, {
                label = dressingLabel, 
                outfit = dressingIndex
            })
		end

		Heap.ESX.UI.Menu.Open("default", GetCurrentResourceName(), "motel_main_dressing_menu", {
			title = "Wardrobe",
			align = Default.MenuAlignment,
			elements = menuElements
        }, function(menuData, menuHandle)
            local currentOutfit = menuData.current.outfit

			TriggerEvent("skinchanger:getSkin", function(skin)
                Heap.ESX.TriggerServerCallback("renz_motels:getPlayerOutfit", function(clothes)
                    TriggerEvent("skinchanger:loadClothes", skin, clothes)
                    TriggerEvent("esx_skin:setLastSkin", skin)

                    TriggerEvent("skinchanger:getSkin", function(skin)
                        TriggerServerEvent("esx_skin:save", skin)
                    end)
                    
                    Heap.ESX.ShowNotification("You switched outfit.")
                end, currentOutfit)
			end)
        end, function(menuData, menuHandle)
			menuHandle.close()
        end)
	end)
end

RaidMotelRoom = function(doorHandle)
    local doorCoords = GetEntityCoords(doorHandle)

    local motelUUID = tostring(doorCoords.x) .. tostring(doorCoords.y) .. tostring(doorCoords.z)

    local cachedMotel = Heap.Motels[motelUUID]

    if not cachedMotel then return Heap.ESX.ShowNotification("You can only raid owned rooms.") end
    if cachedMotel.IsUnlocked then return Heap.ESX.ShowNotification("The door is open, why break it?") end

    PlayAnimation(Heap.Ped, "missheist_agency3aig_14", "explosion_player0")

    Citizen.Wait(1200)

    Heap.ESX.TriggerServerCallback("renz_motels:toggleLock", function(toggled)
        if toggled then
            Heap.ESX.ShowNotification("You broke the lock and the door opened.")
        end
    end, motelUUID, true)

    Citizen.Wait(300)

    ClearPedTasks(Heap.Ped)
end