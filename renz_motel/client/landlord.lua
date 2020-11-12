Citizen.CreateThread(function()


    while true do
        local sleepThread = 500
        
        local ped = Heap.Ped
        local pedCoords = GetEntityCoords(ped)

        for _, landlordData in ipairs(LandLords) do
            local dstCheck = #(pedCoords - landlordData.Location.Position)

            if dstCheck <= 5.0 then
                sleepThread = 5

                local displayText = "Landlord"

                if dstCheck <= 1.3 then
                    displayText = "[~y~E~s~] " .. displayText

                    if IsControlJustPressed(0, 38) then
                        OpenLandLordMenu(landlordData.Trigger)
                    end
                end

                DrawScriptText(landlordData.Location.Position, displayText)
            end
        end

        Citizen.Wait(sleepThread)
    end
end)  

LoadLandlordPeds = function()
    Heap.Peds = {}

    for _, landlordData in ipairs(LandLords) do
        if landlordData.Model then
            LoadModels({ landlordData.Model })

            local pedHandle = CreatePed(5, landlordData.Model, landlordData.Location.Position, landlordData.Location.Heading, false)

            SetEntityAsMissionEntity(pedHandle, true, true)
            SetEntityAsMissionEntity(pedHandle, true, true)
            SetBlockingOfNonTemporaryEvents(pedHandle, true)

            PlayAnimation(pedHandle, "amb@code_human_cross_road@female@idle_a", "idle_a", {
                flag = 11
            })

            table.insert(Heap.Peds, pedHandle)

            CleanupModels({ landlordData.Model })
        end
    end
end

OpenLandLordMenu = function(motelName)
    if not Default.Keys then return Heap.ESX.ShowNotification("You need the keys resource to use this function.") end

    local menuElements = {}

    for motelUUID, motelData in pairs(Heap.Motels) do
        if motelData.name == motelName and motelData.owner == Heap.Identifier then
            table.insert(menuElements, {
                label = "Extra Key - " .. motelName .. " - Room " .. string.sub(motelUUID, 5, 7),
                room = motelUUID
            })
        end
    end

    Heap.ESX.UI.Menu.Open("default", GetCurrentResourceName(), "landlord_menu", {
        title = "Landlord - " .. motelName,
        align = Default.MenuAlignment,
        elements = menuElements
    }, function(menuData, menuHandle)
        local currentRoom = menuData.current.room

        if currentRoom then
            Heap.ESX.TriggerServerCallback("renz_motels:validateMoney", function(validated)
                if validated then
                    exports.chames_keys:AddKey({
                        id = currentRoom,
                        label = "Motel Key - " .. motelName .. " - Room " .. string.sub(currentRoom, 5, 7)
                    })

                    Heap.ESX.ShowNotification("You bought a new key.")

                    menuHandle.close()
                else
                    Heap.ESX.ShowNotification("You don't afford a new key.")
                end
            end)
        end
    end, function(menuData, menuHandle)
        menuHandle.close()
    end)
end