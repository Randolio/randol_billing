Config = {}

Config.JobZones = {
    vanilla = { -- Job name [Example is setup for Gabz VU with job name vanilla]
        {coords = vec3(129.15, -1284.95, 29.29)}, -- Multi location support using zones.
        {coords = vec3(132.96, -1286.05, 29.40)},
    },
    burgershot = { -- Mirror Park burgershot G&N studios.
        {coords = vec3(1248.8, -356.36, 69.21)},
        {coords = vec3(1246.87, -355.94, 69.21)},
    },
}

Config.OXTarget = true -- set to false to use qb-target.

Config.Debug = false

Config.EnableCommission = false

Config.Percent = 0.20

Config.Distance = 10.0

Config.Society = 'renewed' -- renewed / qb-management / qb-banking (new system they use)

QBCore = exports['qb-core']:GetCoreObject()
