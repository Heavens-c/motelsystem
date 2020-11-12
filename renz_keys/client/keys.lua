RegisterNetEvent("renz_keys:keyTransfered")
AddEventHandler("renz_keys:keyTransfered", function(keyData)
    table.insert(Heap.Keys, keyData)

    Heap.ESX.ShowNotification("You received a key.", "error", 3500)
end)

RegisterNetEvent("renz_keys:addKey")
AddEventHandler("renz_keys:addKey", function(keyData)
    AddKey(keyData)
end)

AddKey = function(keyData)
    if not keyData["id"] then return end
    if not keyData["label"] then keyData["label"] = "Key - Unknown" end

    keyData["uuid"] = UUID()

    Heap.ESX.TriggerServerCallback("renz_keys:addKey", function(added)
        if added then
            table.insert(Heap.Keys, keyData)

            Heap.ESX.ShowNotification("Key received.", "warning", 3500)
        end
    end, keyData)
end

RemoveKey = function(keyUUID)
    if not keyUUID then return end

    for keyIndex, keyData in ipairs(Heap.Keys) do
        if keyData["uuid"] == keyUUID then
            Heap.ESX.TriggerServerCallback("renz_keys:removeKey", function(removed)
                if removed then
                    table.remove(Heap.Keys, keyIndex)

                    Heap.ESX.ShowNotification("Key removed.", "error", 3500)
                end
            end, keyUUID)

            return
        end
    end
end

TransferKey = function(keyData, newPlayer)
    if not keyData["uuid"] then return end

    for keyIndex, currentKeyData in ipairs(Heap.Keys) do
        if keyData["uuid"] == currentKeyData["uuid"] then
            Heap.ESX.TriggerServerCallback("renz_keys:transferKey", function(removed)
                if removed then
                    table.remove(Heap.Keys, keyIndex)

                    Heap.ESX.ShowNotification("Key sent.", "error", 3500)
                end
            end, keyData, GetPlayerServerId(newPlayer))

            return
        end
    end
end

HasKey = function(keyId)
    if not keyId then return end

    local function trim(s)
        return (s:gsub("^%s*(.-)%s*$", "%1"))
    end

    for keyIndex, keyData in ipairs(Heap.Keys) do
        if trim(keyData["id"]) == trim(keyId) then
            return true
        end
    end

    return false
end

ShowKeyMenu = function()
    local menuElements = {}

    if #Heap.Keys == 0 then return Heap.ESX.ShowNotification("You don't have any keys on you.", "error", 3000) end

    for keyIndex, keyData in ipairs(Heap.Keys) do
        table.insert(menuElements, {
            ["label"] = keyData["label"],
            ["key"] = keyData
        })
    end

    Heap.ESX.UI.Menu.Open("default", GetCurrentResourceName(), "key_main_menu", {
        ["title"] = "Key storage",
        ["align"] = Default.MenuAlignment,
        ["elements"] = menuElements
    }, function(menuData, menuHandle)
        local currentKey = menuData["current"]["key"]

        if not currentKey then return end

        menuHandle.close()

        ConfirmGiveKey(currentKey, function(confirmed)
            if confirmed then
                TransferKey(currentKey, confirmed)

                DrawBusySpinner("Handing over key...")

                Citizen.Wait(1000)

                RemoveLoadingPrompt()
            end

            ShowKeyMenu()
        end)
    end, function(menuData, menuHandle)
        menuHandle.close()
    end)
end

ConfirmGiveKey = function(keyData, callback)
    local closestPlayer, closestPlayerDistance = Heap.ESX.Game.GetClosestPlayer()

    if closestPlayer == -1 or closestPlayerDistance > 3.0 then
        callback(false)

        return Heap.ESX.ShowNotification("You aren't close to any individual.")
    end

    Citizen.CreateThread(function()
        while Heap.ESX.UI.Menu.IsOpen("default", GetCurrentResourceName(), "main_accept_key") do
            Citizen.Wait(5)

            local cPlayer, cPlayerDst = ESX.Game.GetClosestPlayer()

            if cPlayer ~= closestPlayer then
                closestPlayer = cPlayer
            end

            local cPlayerPed = GetPlayerPed(closestPlayer)

            if DoesEntityExist(cPlayerPed) then
                DrawScriptMarker({
					["type"] = 2,
					["pos"] = GetEntityCoords(cPlayerPed) + vector3(0.0, 0.0, 1.2),
					["r"] = 0,
					["g"] = 0,
					["b"] = 255,
					["sizeX"] = 0.3,
					["sizeY"] = 0.3,
					["sizeZ"] = 0.3,
                    ["rotate"] = true,
                    ["bob"] = true
				})
            end
        end
    end)

    Heap.ESX.UI.Menu.Open("default", GetCurrentResourceName(), "main_accept_key", {
        ["title"] = "Do you wan't to hand over the key?",
        ["align"] = Config.AlignMenu,
        ["elements"] = {
            {
                ["label"] = "Yes, hand over.",
                ["action"] = "yes"
            },
            {
                ["label"] = "No, cancel.",
                ["action"] = "no"
            }
        }
    }, function(menuData, menuHandle)
        local action = menuData["current"]["action"]
        
        menuHandle.close()

        if action == "yes" then
            callback(closestPlayer)
        else
            callback(false)
        end
    end, function(menuData, menuHandle)
        menuHandle.close()
    end)
end