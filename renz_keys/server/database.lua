MySQL.ready(function() 
    local sqlTasks = {}

    table.insert(sqlTasks, function(callback)     
        MySQL.Async.execute([[
            CREATE TABLE IF NOT EXISTS `world_keys` (
                `uuid` bigint(20) NOT NULL DEFAULT '0',
                `owner` varchar(50) NOT NULL,
                `keyData` longtext NOT NULL,
                PRIMARY KEY (`uuid`)
            ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
        ]], {
            callback(true)
        }, function(rowsChanged)
            Trace("Refreshed keys in database.")
        end)
    end)

    -- Perform all sql tasks.
    Async.parallel(sqlTasks, function(responses)
            
    end)
end)