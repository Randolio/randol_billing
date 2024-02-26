local Config = lib.require('config')
local chargeZones = {}
local PlayerData = {}

local function removeAllZones()
    for i = 1, #chargeZones do
        exports['qb-target']:RemoveZone(chargeZones[i])
    end
    table.wipe(chargeZones)
end

local function getList(data)
    local inputList = {}
    for i = 1, #data do
        local ply = data[i]
        if ply.id ~= cache.serverId then
            inputList[#inputList + 1] = {
                value = ply.id,
                label = ('%s - %s'):format(ply.id, ply.name),
            }
        end
    end
    return inputList
end

local function ChargeMenu(jobName, data)
    local jobLabel = QBCore.Shared.Jobs[jobName].label
    local inputList = getList(data)
    
    if #inputList == 0 then
        return QBCore.Functions.Notify("No customers nearby.", "error")
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
        amount = response[2],
        accountType = response[3],
    }
    TriggerServerEvent('randol_billing:server:attemptCharge', data)
end

local function ChargeZones()
    for job, locations in pairs(Config.JobZones) do
        for i = 1, #locations do
            local v = locations[i]
            local zone = exports['qb-target']:AddCircleZone("CHARGE_"..job..i, v.coords, 0.5,{ 
                name= "CHARGE_"..job..i, 
                debugPoly = Config.Debug, 
                useZ=true, 
            }, {
                options = {
                    {
                        icon = "fa-solid fa-money-check-dollar",
                        label = 'Charge Customer',
                        action = function()
                            if not PlayerData.job.onduty then
                                return QBCore.Functions.Notify("You are not clocked in.", "error")
                            end
                            local data = lib.callback.await('randol_billing:server:getCharacters', false)
                            ChargeMenu(job, data)
                        end,
                        job = job,
                    }
                },
                distance = 1.5
            })
            chargeZones[#chargeZones+1] = zone.name
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
    if GetCurrentResourceName() == resourceName then
        removeAllZones()
    end 
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    ChargeZones()
end)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        PlayerData = QBCore.Functions.GetPlayerData()
        ChargeZones()
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    removeAllZones()
    table.wipe(PlayerData)
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)
