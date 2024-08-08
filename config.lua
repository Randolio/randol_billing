return {
    Debug = false,
    EnableCommission = false,
    Distance = 10.0,
    Jobs = {
        vanilla = { -- Job name [Example is setup for Gabz VU with job name vanilla]
            useGlobal = false, -- if true, Provides a global player target option for billing from anywhere.
            Percent = 0.20, -- commission per job if EnableCommission = true
            locations = {
                vec3(129.15, -1284.95, 29.29), -- Multi location support using zones.
                vec3(132.96, -1286.05, 29.40),
            },
        },
        burgershot = { -- Mirror Park burgershot G&N studios.
            useGlobal = false, -- if true, Provides a global player target option for billing from anywhere.
            Percent = 0.20,
            locations = {
                vec3(1248.8, -356.36, 69.21),
                vec3(1246.87, -355.94, 69.21),
            },
        },
        taxi = { -- Mirror Park burgershot G&N studios.
            useGlobal = true, -- if true, Provides a global player target option for billing from anywhere.
            Percent = 0.20,
            locations = {

            },
        },
    },
}