Citizen.CreateThread(function()
    Heap.ESX.RegisterServerCallback("renz_keys:fetchKeys", function(source, callback)
        local player = Heap.ESX.GetPlayerFromId(source)
    
        if not player then return callback(false) end
    
        local sqlQuery = [[
            SELECT
                keyData
            FROM
                world_keys
            WHERE
                owner = @owner
        ]]
    
        MySQL.Async.fetchAll(sqlQuery, {
            ["@owner"] = player["identifier"]
        }, function(response)
            local playerKeys = {}
    
            for keyIndex, keyData in ipairs(response) do
                local decodedData = json.decode(keyData["keyData"])
    
                table.insert(playerKeys, decodedData)
            end
    
            callback(playerKeys)
        end)
    end)

    Heap.ESX.RegisterServerCallback("renz_keys:addKey", function(source, callback, keyData)
        local player = Heap.ESX.GetPlayerFromId(source)
    
        if not player then return callback(false) end
    
        local sqlQuery = [[
            INSERT
                INTO
            world_keys
                (uuid, owner, keyData)
            VALUES
                (@uuid, @owner, @data)
            ON DUPLICATE KEY UPDATE
                keyData = @data
        ]]
    
        MySQL.Async.execute(sqlQuery, {
            ["@uuid"] = keyData["uuid"],
            ["@owner"] = player["identifier"],
            ["@data"] = json.encode(keyData)
        }, function(rowsChanged)
            if rowsChanged > 0 then
                callback(true)
            else
                callback(false)
            end
        end)
    end)
    
    Heap.ESX.RegisterServerCallback("renz_keys:removeKey", function(source, callback, keyUUID)
        local player = Heap.ESX.GetPlayerFromId(source)
    
        if not player then return callback(false) end
    
        local sqlQuery = [[
            DELETE
                FROM
            world_keys
                WHERE
            uuid = @uuid
        ]]
    
        MySQL.Async.execute(sqlQuery, {
            ["@uuid"] = keyUUID
        }, function(rowsChanged)
            if rowsChanged > 0 then
                callback(true)
            else
                callback(false)
            end
        end)
    end)
    
    Heap.ESX.RegisterServerCallback("renz_keys:transferKey", function(source, callback, keyData, receivePlayer)
        local player = Heap.ESX.GetPlayerFromId(source)
        local receivePlayer = Heap.ESX.GetPlayerFromId(receivePlayer)
    
        if not player then return callback(false) end
    
        local sqlQuery = [[
            UPDATE
                world_keys
            SET
                owner = @newOwner
            WHERE
                uuid = @uuid
        ]]
    
        MySQL.Async.execute(sqlQuery, {
            ["@uuid"] = keyData["uuid"],
            ["@newOwner"] = receivePlayer["identifier"]
        }, function(rowsChanged)
            if rowsChanged > 0 then
                TriggerClientEvent("renz_keys:keyTransfered", receivePlayer["source"], keyData)
    
                callback(true)
            else
                callback(false)
            end
        end)
    end)
end)