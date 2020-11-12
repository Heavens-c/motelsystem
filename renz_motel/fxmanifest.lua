fx_version 'bodacious'
games { 'rdr3', 'gta5' }    

author 'JRenZ'
description "Motel resource, using MLO by JRenZ."

version "1.1"

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