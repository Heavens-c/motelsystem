RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(response)
    Heap.ESX.PlayerData = response

    LoadMotels()
end)

RegisterNetEvent("renz_keys:updateKeys")
AddEventHandler("renz_keys:updateKeys", function(keys)
    Heap.Keys = keys
end)
