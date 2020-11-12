RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(response)
    Heap.ESX.PlayerData = response

    LoadMotels()
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(response)
    Heap.ESX.PlayerData.job = response
end)

RegisterNetEvent("renz_motels:updateMotels")
AddEventHandler("renz_motels:updateMotels", function(motels)
    Heap.Motels = motels
end)

RegisterNetEvent("renz_motels:updateStorages")
AddEventHandler("renz_motels:updateStorages", function(eventData)
    Heap.Storages[eventData.storageId] = eventData.newTable

    if Heap.ESX.UI.Menu.IsOpen("default", GetCurrentResourceName(), "main_storage_menu_" .. string.sub(eventData.storageId .. "-" .. eventData.storageName, 6, 9)) then
        local openedMenu = Heap.ESX.UI.Menu.GetOpened("default", GetCurrentResourceName(), "main_storage_menu_" .. string.sub(eventData.storageId .. "-" .. eventData.storageName, 6, 9))

        if openedMenu then
            openedMenu.close()

            OpenStorage(eventData.storageName, eventData.storageId)
        end
    end
end)

RegisterNetEvent("onResourceStop")
AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        for _, pedHandle in ipairs(Heap.Peds) do
            if DoesEntityExist(pedHandle) then
                DeleteEntity(pedHandle)
            end
        end
    end
end)
