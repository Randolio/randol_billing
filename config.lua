QBCore = exports['qb-core']:GetCoreObject()

return {
    JobZones = {
        vanilla = { -- Job name [Example is setup for Gabz VU with job name vanilla]
            {coords = vec3(129.15, -1284.95, 29.29)}, -- Multi location support using zones.
            {coords = vec3(132.96, -1286.05, 29.40)},
        },
        burgershot = { -- Mirror Park burgershot G&N studios.
            {coords = vec3(1248.8, -356.36, 69.21)},
            {coords = vec3(1246.87, -355.94, 69.21)},
        },
    },
    OXTarget = true,-- set to false to use qb-target.
    Debug = false,
    EnableCommission = false,
    Percent = 0.20,
    Distance = 10.0,
    Society = 'renewed', -- renewed / qb-management / qb-banking (new system they use)
}
