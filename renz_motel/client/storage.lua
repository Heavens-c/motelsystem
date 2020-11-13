OpenStorage = function(storageName, storageUUID)
    if Default.DiscInventory.Enabled then
        TriggerEvent("disc-inventoryhud:openInventory", {
            type = "RENZ_MOTEL_STORAGE",
            owner = storageUUID .. "-" .. storageName
        })

        return
    end

    local storageId = storageUUID .. "-" .. storageName

    local cachedStorage = Heap.Storages[storageId]

    if not cachedStorage then
        Heap.Storages[storageId] = {
            Items = {}
        }
    end

    local menuElements = {
        {
            label = "Put in something.",
            action = "put_item"
        }
    }

    for itemIndex, itemData in ipairs(Heap.Storages[storageId].Items) do
        if itemData.type and itemData.type == "weapon" then
            if not itemData.uniqueId then
                itemData.uniqueId = NetworkGetRandomInt()
            end
        end

        table.insert(menuElements, {
            label = itemData.label .. " - x" .. itemData.count,
            action = itemData
        })
    end

    Heap.ESX.UI.Menu.Open("default", GetCurrentResourceName(), "main_storage_menu_" .. string.sub(storageId, 6, 9), {
        title = "Förvaring",
        align = Default.MenuAlignment,
        elements = menuElements
    }, function(menuData, menuHandle)
        local action = menuData.current.action

        if action == "put_item" then
            ChooseItemMenu(function(itemPut)
                AddItemToStorage(storageUUID, storageName, itemPut)
            end)
        elseif type(action) == "table" then
            if action.type == "weapon" then
                TakeItemFromStorage(storageUUID, storageName, action)
            else
                Heap.ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "main_storage_count", {
                    title = "How many?"
                }, function(menuData, dialogHandle)
                    local newCount = tonumber(menuData.value)

                    if not newCount then
                        return Heap.ESX.ShowNotification("Please provide only a number.")
                    elseif newCount > action.count then
                        newCount = action.count
                    elseif newCount < 1 then
                        newCount = 1
                    end

                    action.count = newCount

                    dialogHandle.close()
        
                    TakeItemFromStorage(storageUUID, storageName, action)
                end, function(menuData, dialogHandle)
                    dialogHandle.close()
                end)
            end
        end
    end, function(menuData, menuHandle)
        menuHandle.close()
    end)
end

ChooseItemMenu = function(callback)
    local playerInventory = Heap.ESX.GetPlayerData()["inventory"]

    local menuElements = {}

    if Storage.BlackMoney then
        local playerAccounts = Heap.ESX.GetPlayerData()["accounts"]

        for accountIndex, accountData in pairs(playerAccounts) do
            if accountData.name == "black_money" then
                accountData.count = accountData.money
                accountData.type = "black_money"

                table.insert(menuElements, {
                    label = accountData.label .. " - $" .. accountData.count,
                    action = accountData
                })
            end
        end
    end
    
    if Storage.Weapons then
        local weaponLoadout = Heap.ESX.GetPlayerData()["loadout"]

        for loadoutIndex, loadoutData in ipairs(weaponLoadout) do
            loadoutData.count = loadoutData.ammo
            loadoutData.type = "weapon"
            
            table.insert(menuElements, {
                label = loadoutData.label .. " - x" .. loadoutData.count,
                action = loadoutData
            })
        end
    end

    for itemIndex, itemData in ipairs(playerInventory) do
        if itemData.count > 0 then
            itemData.type = "item"

            table.insert(menuElements, {
                label = itemData.label .. " - x" .. itemData.count,
                action = itemData
            })
        end
    end

    Heap.ESX.UI.Menu.Open("default", GetCurrentResourceName(), "main_storage_inventory_menu", {
        title = "Choose.",
        align = Default.MenuAlignment,
        elements = menuElements
    }, function(menuData, menuHandle)
        local action = menuData.current.action

        if type(action) == "table" then
            if action.type == "weapon" then
                callback(action)

                menuHandle.close()
            else
                Heap.ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "main_storage_inventory_count", {
                    title = "How many?"
                }, function(menuData, dialogHandle)
                    local newCount = tonumber(menuData.value)
    
                    if not newCount then
                        return ESX.ShowNotification("Please provide a number.")
                    elseif newCount > action.count then
                        newCount = action.count
                    elseif newCount < 1 then
                        newCount = 1
                    end
    
                    action.count = newCount
    
                    dialogHandle.close()
                    menuHandle.close()
        
                    callback(action)
                end, function(menuData, dialogHandle)
                    dialogHandle.close()
                end)
            end
        end
    end, function(menuData, menuHandle)
        menuHandle.close()
    end)
end

AddItemToStorage = function(storageUUID, storageName, newItem)
    local storageId = storageUUID .. "-" .. storageName

    local cachedStorage = Heap.Storages[storageId]

    if not cachedStorage then
        Heap.Storages[storageId] = {
            Items = {}
        }
    end

    local itemFound = false

    if newItem.type == "weapon" then
        newItem.uniqueId = NetworkGetRandomInt()
    else
        for itemIndex, itemData in ipairs(cachedStorage.Items) do
            if itemData.name == newItem.name then
                Heap.Storages[storageId].Items[itemIndex].count = cachedStorage.Items[itemIndex].count + newItem.count
    
                itemFound = true
    
                break
            end
        end
    end

    if not itemFound then
        table.insert(Heap.Storages[storageId].Items, newItem)
    end

    Heap.ESX.TriggerServerCallback("renz_motels:addItemToStorage", function(updated)
        if updated then
            Heap.ESX.ShowNotification("You put x" .. newItem.count .. " - " .. newItem.label)
        end
    end, Heap.Storages[storageId], newItem, storageUUID, storageName)
end

TakeItemFromStorage = function(storageUUID, storageName, newItem)
    local storageId = storageUUID .. "-" .. storageName

    local cachedStorage = Heap.Storages[storageId]

    if not cachedStorage then
        return
    end

    local itemFound = false

    for itemIndex, itemData in ipairs(cachedStorage.Items) do
        if newItem.type == "weapon" then
            if itemData.uniqueId == newItem.uniqueId then
                itemFound = true

                table.remove(Heap.Storages[storageId].Items, itemIndex)

                break
            end
        else
            if itemData.name == newItem.name then
                itemFound = true

                if cachedStorage.Items[itemIndex].count - newItem.count <= 0 then
                    newItem.count = cachedStorage.Items[itemIndex].count

                    table.remove(Heap.Storages[storageId].Items, itemIndex)
                else
                    Heap.Storages[storageId].Items[itemIndex].count = Heap.Storages[storageId].Items[itemIndex].count - newItem.count
                end

                break
            end
        end
    end

    if not itemFound then
        return
    end

    Heap.ESX.TriggerServerCallback("renz_motels:takeItemFromStorage", function(updated)
        if updated then
            Heap.ESX.ShowNotification("You took x" .. newItem.count .. " - " .. newItem.label)
        end
    end, Heap.Storages[storageId], newItem, storageUUID, storageName)
end
