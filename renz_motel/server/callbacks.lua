Citizen.CreateThread(function()
    Heap.ESX.RegisterServerCallback("renz_motels:fetchCachedMotels", function(source, callback)
        local player = Heap.ESX.GetPlayerFromId(source)

        if not player then return callback(false) end

        callback(Heap.Motels, Heap.Storages, player.identifier)
    end)

    Heap.ESX.RegisterServerCallback("renz_motels:buyMotel", function(source, callback, motelUUID, shouldRent, motelData)
        local player = Heap.ESX.GetPlayerFromId(source)
    
        if not player then return callback(false) end
    
        if Heap.Motels[motelUUID] then return callback(false) end

        if not Default.OwnMoreThanOneRoom then
            for motelUUID, motelData in pairs(Heap.Motels) do
                if motelData.owner == player.identifier then
                    return callback(false)
                end
            end
        end

        local motelPrice = shouldRent and motelData.Prices.Rent or motelData.Prices.Buy
    
        local moneyValidated = false
    
        if player.getMoney() >= motelPrice then
            moneyValidated = true
    
            player.removeMoney(motelPrice)
        elseif player.getAccount("bank").money >= motelPrice then
            moneyValidated = true
    
            player.removeAccountMoney("bank", motelPrice)
        end
    
        if moneyValidated then
            CreateMotel(player, motelUUID, motelData, shouldRent, function(created)
                Heap.Motels[motelUUID] = {
                    uuid = motelUUID,
                    owner = player.identifier,
                    name = motelData.Name,
                    lastRent = shouldRent and os.time() or -1
                }

                UpdateMotels()

                callback(created)
            end)
        else
            callback(false)
        end
    end)

    Heap.ESX.RegisterServerCallback("renz_motels:validateMoney", function(source, callback)
        local player = Heap.ESX.GetPlayerFromId(source)
    
        if not player then return callback(false) end
    
        local moneyValidated = false
    
        if player.getMoney() >= LandLord.Prices.Key then
            moneyValidated = true
    
            player.removeMoney(LandLord.Prices.Key)
        elseif player.getAccount("bank").money >= LandLord.Prices.Key then
            moneyValidated = true
    
            player.removeAccountMoney("bank", LandLord.Prices.Key)
        end

        callback(moneyValidated)
    end)

    Heap.ESX.RegisterServerCallback("renz_motels:cancelMotel", function(source, callback, motelUUID)
        local player = Heap.ESX.GetPlayerFromId(source)
    
        if not player then return callback(false) end
    
        local removeSQL = [[
            DELETE
                FROM
            renz_motels
                WHERE
            uuid = @uuid
        ]]

        MySQL.Async.execute(removeSQL, {
            ["@uuid"] = motelUUID
        }, function(rowsChanged)
            Heap.Motels[motelUUID] = nil

            UpdateMotels()

            callback(rowsChanged > 0)
        end)

        if Default.Keys then
            local removeSQL = "DELETE FROM world_keys WHERE keyData LIKE '%" .. motelUUID .. "%'"
    
            MySQL.Async.execute(removeSQL, {
                
            }, function(rowsChanged)
                Trace("Removed keys:", rowsChanged)

                exports.chames_keys:UpdateKeys()

                callback(rowsChanged > 0)
            end)
        end
    end)

    Heap.ESX.RegisterServerCallback("renz_motels:toggleLock", function(source, callback, motelUUID, forceUnlock)
        local player = Heap.ESX.GetPlayerFromId(source)
    
        if not player then return callback(false) end
    
        local cachedMotel = Heap.Motels[motelUUID]

        if not cachedMotel then return callback(false) end

        if cachedMotel.IsUnlocked and not forceUnlock then
            cachedMotel.IsUnlocked = false
        else
            cachedMotel.IsUnlocked = true
        end

        UpdateMotels()

        callback(true)
    end)

    Heap.ESX.RegisterServerCallback("renz_motels:getPlayerDressing", function(source, cb)
        local player = Heap.ESX.GetPlayerFromId(source)
      
        TriggerEvent("esx_datastore:getDataStore", "property", player.identifier, function(store)
            local count = store.count("dressing")
    
            local labels = {}
      
            for index = 1, count do
                local entry = store.get("dressing", index)
    
                table.insert(labels, entry.label)
            end
      
            cb(labels)
        end)
    end)
      
    Heap.ESX.RegisterServerCallback("renz_motels:getPlayerOutfit", function(source, cb, num)
        local player = Heap.ESX.GetPlayerFromId(source)
    
        TriggerEvent("esx_datastore:getDataStore", "property", player.identifier, function(store)
            local outfit = store.get("dressing", num)
    
            cb(outfit.skin)
        end)
    end)

    Heap.ESX.RegisterServerCallback("renz_motels:addItemToStorage", function(source, callback, newTable, newItem, storageUUID, storageName)
        local player = Heap.ESX.GetPlayerFromId(source)
    
        if player then
            local storageId = storageUUID .. "-" .. storageName

            Heap.Storages[storageId] = newTable
    
            if newItem.type == "item" then
                player.removeInventoryItem(newItem.name, newItem.count)
            elseif newItem.type == "weapon" then
                player.removeWeapon(newItem.name, newItem.count)
            elseif newItem.type == "black_money" then
                player.removeAccountMoney("black_money", newItem.count)
            end
    
            TriggerClientEvent("renz_motels:updateStorages", -1, {
                newTable = newTable,
                storageId = storageUUID,
                storageName = storageName
            })
    
            UpdateStorageDatabase(storageId, newTable)
    
            callback(true)
        else
            callback(false)
        end
    end)
    
    Heap.ESX.RegisterServerCallback("renz_motels:takeItemFromStorage", function(source, callback, newTable, newItem, storageUUID, storageName)
        local player = Heap.ESX.GetPlayerFromId(source)
    
        if player then
            local storageId = storageUUID .. "-" .. storageName

            Heap.Storages[storageId] = newTable
    
            if newItem.type == "item" then
                player.addInventoryItem(newItem.name, newItem.count)
            elseif newItem.type == "weapon" then
                player.addWeapon(newItem.name, newItem.count)
            elseif newItem.type == "black_money" then
                player.addAccountMoney("black_money", newItem.count)
            end
    
            TriggerClientEvent("renz_motels:updateStorages", -1, {
                newTable = newTable,
                storageId = storageUUID,
                storageName = storageName
            })
    
            UpdateStorageDatabase(storageId, newTable)
    
            callback(true)
        else
            callback(false)
        end
    end)
end)