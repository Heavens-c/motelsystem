if Default.Raid.Enabled then
    local commandName = Default.Raid.Command and (#Default.Raid.Command > 0 and Default.Raid.Command or "raidmotel") or "raidmotel"

    RegisterCommand(commandName, function()
        if not Default.Raid.Enabled then return Trace("Raid is not enabled, canceling.") end

        if Default.Raid.Job.Enabled then
            local canRaid = false

            for _, jobName in ipairs(Default.Raid.Job.Jobs) do
                if Heap.ESX.PlayerData.job and Heap.ESX.PlayerData.job.name == jobName then
                    canRaid = true

                    break
                end
            end

            if not canRaid then return Heap.ESX.ShowNotification("You cannot raid this room, you need to have the rights to do it.") end
        end

        if Default.Raid.Weapon.Enabled then
            local hasWeapon = false

            if not (#Default.Raid.Weapon.Hashes > 0) then hasWeapon = true end

            for _, weaponHash in ipairs(Default.Raid.Weapon.Hashes) do
                if GetSelectedPedWeapon(Heap.Ped) == weaponHash then
                    hasWeapon = true

                    break
                end
            end

            if not hasWeapon then return Heap.ESX.ShowNotification("You need to have a specified tool to break this lock.") end
        end

        local closestMotelDoor = Heap.ClosestDoor

        if DoesEntityExist(closestMotelDoor) then
            local dstCheck = #(GetEntityCoords(Heap.Ped) - GetEntityCoords(closestMotelDoor))

            if dstCheck < 3.0 then
                RaidMotelRoom(closestMotelDoor)
            else
                Heap.ESX.ShowNotification("You need to be closer to raid the door.")
            end
        end
    end)
end