Heap = {}

TriggerEvent("esx:getSharedObject", function(library)
    Heap.ESX = library
end)