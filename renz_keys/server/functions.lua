UpdateKeys = function()
    local players = Heap.ESX.GetPlayers()

    local fetchSQL = [[
        SELECT
            owner, keyData
        FROM
            world_keys
    ]]

    MySQL.Async.fetchAll(fetchSQL, {

    }, function(responses)
        for _, playerSource in ipairs(players) do
            local player = Heap.ESX.GetPlayerFromId(playerSource)        
            
            if player then
                local playerKeys = {}

                for _, response in ipairs(responses) do
                    if response.owner == player.identifier then
                        local keyData = json.decode(response.keyData)

                        table.insert(playerKeys, keyData)
                    end
                end

                TriggerClientEvent("renz_keys:updateKeys", playerSource, playerKeys)
            end
        end
    end)
end