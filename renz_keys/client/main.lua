Heap = {
    Keys = {}
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

RegisterCommand("keymenu", function()
    ShowKeyMenu()
end)