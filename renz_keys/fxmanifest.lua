fx_version 'bodacious'
games { 'rdr3', 'gta5' }    

author 'JRenZ'
description "Keys resource, by RenZ."

server_scripts {
    "@async/async.lua",
    "@mysql-async/lib/MySQL.lua",
    "server/*"
}

client_scripts {
    "client/*"
}

shared_scripts {
    "configs/*",
    "shared/*"
}

exports {
    "HasKey",
    "AddKey",
    "RemoveKey"
}

server_exports {
    "UpdateKeys"
}