ox_inventory items.lua

['gov_tablet'] = {
    label = 'Government Tablet',
    weight = 800,
    stack = false,
    close = true,
    description = 'Official government tablet for accessing administrative functions',
    server = {
        export = 'fs-government.useGovernmentTablet'
    }
},

QBCore shared/items.lua

['gov_tablet'] = {
    ['name'] = 'gov_tablet',
    ['label'] = 'Government Tablet',
    ['weight'] = 800,
    ['type'] = 'item',
    ['image'] = 'tablet.png',
    ['unique'] = true,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['combinable'] = nil,
    ['description'] = 'Official government tablet for accessing administrative functions'
},

ESX Database SQL

INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES ('gov_tablet', 'Government Tablet', 800, 0, 1);