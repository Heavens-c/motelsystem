CreateMotel = function(player, motelUUID, motelData, isRented, callback)
    local createSQL = [[
        INSERT
            INTO
        renz_motels
            (uuid, owner, name, lastRent)
        VALUES
            (@uuid, @owner, @name, @rent)
        ON DUPLICATE KEY UPDATE
            uuid = @uuid
    ]]

    MySQL.Async.execute(createSQL, {
        ["@uuid"] = motelUUID,
        ["@owner"] = player.identifier,
        ["@name"] = motelData.Name,
        ["@rent"] = isRented and os.time() or -1
    }, function(rowsChanged)
        callback(rowsChanged > 0)
    end)
end

PayRent = function(motelUUID, motelData)
    local player = Heap.ESX.GetPlayerFromIdentifier(motelData.owner)

    local motel = GetMotel(motelData.name)

    if not motel then return end

    if player then
        player.removeMoney(motel.Prices.Rent)

        TriggerClientEvent("esx:showNotification", player.source, "You paid your motel rent $" .. motel.Prices.Rent .. ".")

        UpdateMotelRentTime(motelUUID)

        Trace("Rent paid online for:", motelData.owner)
    else
        local fetchSQL = [[
            SELECT
                accounts
            FROM    
                users
            WHERE
                identifier = @identifier
        ]]

        MySQL.Async.fetchScalar(fetchSQL, {
            ["@identifier"] = motelData.owner
        }, function(response)
            if response then
                local accounts = json.decode(response)

                accounts.money = accounts.money - motel.Prices.Rent

                local updateSQL = [[
                    UPDATE
                        users
                    SET
                        accounts = @newAccounts
                    WHERE
                        identifier = @identifier
                ]]

                MySQL.Async.execute(updateSQL, {
                    ["@identifier"] = motelData.owner,
                    ["@newAccounts"] = json.encode(accounts)
                }, function(rowsChanged)
                    if rowsChanged > 0 then
                        Trace("Rent paid offline for:", motelData.owner)

                        UpdateMotelRentTime(motelUUID)
                    end
                end)
            end
        end)
    end
end

GetMotel = function(motelName)
    for _, motelData in ipairs(Motels) do
        if motelData.Name == motelName then
            return motelData
        end
    end
    
    return false
end

UpdateMotelRentTime = function(motelUUID)
    local updateSQL = [[
        UPDATE
            renz_motels
        SET
            lastRent = @newRent
        WHERE
            uuid = @uuid
    ]]

    MySQL.Async.execute(updateSQL, {
        ["@uuid"] = motelUUID,
        ["@newRent"] = os.time()
    }, function(rowsChanged)
        if rowsChanged > 0 then
            if not Heap.Motels[motelUUID] then return end

            Heap.Motels[motelUUID].lastRent = os.time()

            UpdateMotels()
        end
    end)
end

UpdateStorageDatabase = function(storageId, newTable)
    local sqlQuery = [[
        INSERT
            INTO
        world_storages
            (storageId, storageData)
        VALUES
            (@id, @data)
        ON DUPLICATE KEY UPDATE
            storageData = @data
    ]]

    MySQL.Async.execute(sqlQuery, {
        ["@id"] = storageId,
        ["@data"] = json.encode(newTable)
    })
end

UpdateMotels = function()
    TriggerClientEvent("renz_motels:updateMotels", -1, Heap.Motels)
end