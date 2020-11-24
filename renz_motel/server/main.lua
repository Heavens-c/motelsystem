Heap = {
    Motels = {},
    Storages = {}
}

TriggerEvent("esx:getSharedObject", function(library)
    Heap.ESX = library
end)

MySQL.ready(function()
    Citizen.Wait(100)

    local fetchSQL = [[
        SELECT
            *
        FROM
            renz_motels
    ]]

    MySQL.Async.fetchAll(fetchSQL, {

    }, function(responses)
        for _, response in ipairs(responses) do
            Heap.Motels[response.uuid] = {
                uuid = response.uuid,
                owner = response.owner,
                name = response.name,
                lastRent = response.lastRent
            }
        end
    end)

    local fetchSQL = [[
        SELECT
            storageId, storageData
        FROM
            world_storages
    ]]
        
    MySQL.Async.fetchAll(fetchSQL, {
        
    }, function(response)
        if #response <= 0 then return end

        for storageIndex, storageData in ipairs(response) do
            local decodedData = json.decode(storageData.storageData)

            if not Heap.Storages[storageData.storageId] then
                Heap.Storages[storageData.storageId] = {}
                Heap.Storages[storageData.storageId].Items = {}
            end

            Heap.Storages[storageData.storageId] = decodedData
        end
    end)
end)

Citizen.CreateThread(function()
    while true do
        local sleepThread = 15000

        for motelUUID, motelData in pairs(Heap.Motels) do
            if motelData.lastRent ~= -1 then
                local currentTime = os.time()
                local rentTime = motelData.lastRent

                local hoursSinceRent = os.difftime(currentTime, rentTime) / 3600

                Trace("Hours since lastrent:", hoursSinceRent, RentTime.Days * 24)

                if hoursSinceRent > RentTime.Days * 24 then
                    PayRent(motelUUID, motelData)
                end
            end
        end

        Citizen.Wait(sleepThread)
    end
end)

if Default.DiscInventory.Enabled then
    Citizen.CreateThread(function()
        TriggerEvent("disc-inventoryhud:RegisterInventory", {
            name = "RENZ_MOTEL_STORAGE",
            label = "Motel Storage",
            slots = Default.DiscInventory.Slots
        })
    end)
end
