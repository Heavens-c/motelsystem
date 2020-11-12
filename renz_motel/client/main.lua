Heap = {
    Motels = {},
    Storages = {}
}

Citizen.CreateThread(function()
    while not Heap.ESX do
        Heap.ESX = exports["es_extended"]:getSharedObject()

        Citizen.Wait(100)
    end

    Initialized()
end)

Citizen.CreateThread(function()
    while true do
        local sleepThread = 5000

        local newPed = PlayerPedId()

        if Heap.Ped ~= newPed then
            Heap.Ped = newPed
        end

        Citizen.Wait(sleepThread)
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleepThread = 500

        local ped = Heap.Ped
        local pedCoords = GetEntityCoords(ped)

        for _, motelData in ipairs(Motels) do
            local dstCheck = #(pedCoords - motelData.Location)

            if dstCheck <= 50.0 then
                for _, doorHash in ipairs(motelData.Doors) do
                    local closestDoorHandle = GetClosestObjectOfType(pedCoords, 7.5, doorHash)

                    if DoesEntityExist(closestDoorHandle) then
                        local doorCoords = GetEntityCoords(closestDoorHandle)

                        local dstCheck = #(pedCoords - doorCoords)

                        if dstCheck <= 10.0 then
                            if GetInteriorFromEntity(ped) == 0 or not Heap.ClosestDoor then
                                Heap.ClosestDoor = closestDoorHandle
                            end

                            sleepThread = 5

                            local motelUUID = tostring(doorCoords.x) .. tostring(doorCoords.y) .. tostring(doorCoords.z)

                            DrawMotel(motelUUID, motelData, Heap.ClosestDoor)
                        end
                    end
                end
            end
        end

        Citizen.Wait(sleepThread)
    end
end)