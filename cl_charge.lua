local Config = lib.require('config')
local chargeZones = {}
local oxtarget = GetResourceState('ox_target') == 'started'

function removeAllZones()
    for i = 1, #chargeZones do
        if oxtarget then
            exports.ox_target:removeZone(chargeZones[i])
        else
            exports['qb-target']:RemoveZone(chargeZones[i])
        end
    end
    table.wipe(chargeZones)
end

local function getList(data)
    local inputList = {}
    for i = 1, #data do
        local ply = data[i]
        inputList[#inputList + 1] = {
            value = ply.id,
            label = ('%s - %s'):format(ply.id, ply.name),
        }
    end
    return inputList
end

local function ChargeMenu(jobName, data)
    local jobLabel = GetJobLabel(jobName)
    local inputList = getList(data)
    
    if #inputList == 0 then
        return DoNotification("No customers nearby.", "error")
    end

    local response = lib.inputDialog(jobLabel, {
        { type = 'select', label = 'Customers', required = true, icon = 'fa-solid fa-user', options = inputList},
        { type = 'select', label = 'Account', required = true, icon = 'fa-solid fa-wallet', 
            options = {
                { value = 'cash', label = 'Cash' },
                { value = 'bank', label = 'Bank' },
            }
        },
        { type = "number", label = "How much?", icon = 'fa-solid fa-hand-holding-dollar', placeholder = "$", min = 1, description = "Input an amount to charge.", required = true   },
    })
    if not response then return end
    local data = {
        id = response[1],
        accountType = response[2],
        amount = response[3],
    }
    TriggerServerEvent('randol_billing:server:attemptCharge', data)
end

function ChargeZones(jobName)
    for job, data in pairs(Config.Jobs) do
        for i = 1, #data.locations do
            local coords = data.locations[i]
            if oxtarget then
                chargeZones[#chargeZones+1] = exports.ox_target:addSphereZone({
                    coords = vec3(coords.x, coords.y, coords.z),
                    radius = 0.5,
                    debug = Config.Debug,
                    options = {
                        {
                            icon = "fa-solid fa-money-check-dollar",
                            label = 'Charge Customer',
                            onSelect = function()
                                local data = lib.callback.await('randol_billing:server:getCharacters', false)
                                ChargeMenu(job, data)
                            end,
                            groups = job,
                        }
                    }
                })
            else
                exports['qb-target']:AddCircleZone("CHARGE_"..job..i, coords, 0.5,{ 
                    name= "CHARGE_"..job..i, 
                    debugPoly = Config.Debug, 
                    useZ=true, 
                }, {
                    options = {
                        {
                            icon = "fa-solid fa-money-check-dollar",
                            label = 'Charge Customer',
                            action = function()
                                local data = lib.callback.await('randol_billing:server:getCharacters', false)
                                ChargeMenu(job, data)
                            end,
                            job = job,
                        }
                    },
                    distance = 1.5
                })
                chargeZones[#chargeZones+1] = "CHARGE_"..job..i
            end
        end
    end
end

RegisterNetEvent("randol_billing:client:sendConfirm", function(data)
    if GetInvokingResource() then return end
    local confirmation = lib.alertDialog({
        header = ('**Do you accept the charge for $%s?**'):format(data.fee),
        centered = true,
        cancel = true,
        size = 'xs',
    })
    if confirmation == 'confirm' then
        data.confirm = true
    end
    TriggerServerEvent('randol_billing:server:chargePlayer', data)
end)

AddEventHandler('onResourceStop', function(resourceName) 
    if GetCurrentResourceName() ~= resourceName then return end
    removeAllZones()
end)

if oxtarget then
    exports.ox_target:addGlobalPlayer({
        icon = 'fa-solid fa-hand-holding-dollar',
        label = 'Bill Player',
        onSelect = function(data)
            local serverId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))

            local response = lib.inputDialog(('Charge Player: %s'):format(serverId), {
                { type = 'select', label = 'Account', required = true, icon = 'fa-solid fa-wallet', 
                    options = {
                        { value = 'cash', label = 'Cash' },
                        { value = 'bank', label = 'Bank' },
                    }
                },
                { type = "number", label = "How much?", icon = 'fa-solid fa-hand-holding-dollar', placeholder = "$", min = 1, description = "Input an amount to charge.", required = true   },
            })

            if not response then return end
            local info = { id = serverId, accountType = response[1], amount = response[2], }
            TriggerServerEvent('randol_billing:server:attemptCharge', info)
        end,
        canInteract = function(entity, distance, data)
            return IsPedAPlayer(entity) and (Config.Jobs[PlayerData.job.name] and Config.Jobs[PlayerData.job.name].useGlobal)
        end,
    })
else
    exports['qb-target']:AddGlobalPlayer({
        options = {
            {
                icon = 'fa-solid fa-hand-holding-dollar',
                label = 'Bill Player',
                action = function(entity)
                    local serverId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))

                    local response = lib.inputDialog(('Charge Player: %s'):format(serverId), {
                        { type = 'select', label = 'Account', required = true, icon = 'fa-solid fa-wallet', 
                            options = {
                                { value = 'cash', label = 'Cash' },
                                { value = 'bank', label = 'Bank' },
                            }
                        },
                        { type = "number", label = "How much?", icon = 'fa-solid fa-hand-holding-dollar', placeholder = "$", min = 1, description = "Input an amount to charge.", required = true   },
                    })

                    if not response then return end
                    local data = { id = serverId, accountType = response[1], amount = response[2], }
                    TriggerServerEvent('randol_billing:server:attemptCharge', data)
                end,
                canInteract = function(entity, distance, data)
                    return IsPedAPlayer(entity) and (Config.Jobs[PlayerData.job.name] and Config.Jobs[PlayerData.job.name].useGlobal)
                end,
            }
        },
        distance = 2.5,
    })
end