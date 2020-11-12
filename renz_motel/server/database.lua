MySQL.ready(function()
    local sqlTasks = {}

    table.insert(sqlTasks, function(callback)   
        local createSQL = [[
            CREATE TABLE IF NOT EXISTS `renz_motels` (
                `uuid` varchar(255) NOT NULL DEFAULT '',
                `owner` varchar(50) NOT NULL,
                `name` varchar(50) NOT NULL,
                `lastRent` bigint(20) NOT NULL DEFAULT '0',
                PRIMARY KEY (`uuid`)
            ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
        ]]

        MySQL.Async.execute(createSQL, {}, function(rowsChanged)
            if rowsChanged > 0 then
                print("Created non-existing table: renz_motels")
            end
        end)
    end)

    table.insert(sqlTasks, function(callback)   
        local createSQL = [[
            CREATE TABLE IF NOT EXISTS `world_storages` (
                `storageId` varchar(255) NOT NULL,
                `storageData` longtext NOT NULL,
                PRIMARY KEY (`storageId`)
            ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
        ]]

        MySQL.Async.execute(createSQL, {}, function(rowsChanged)
            if rowsChanged > 0 then
                print("Created non-existing table: world_storages")
            end
        end)
    end)

    Async.parallel(sqlTasks, function(responses)
        Trace("SQL Tasks Finished.")
    end)
end)