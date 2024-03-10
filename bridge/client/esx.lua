if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

local PlayerData = {}

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    ESX.PlayerLoaded = true
    ChargeZones(PlayerData.job.name)
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    removeAllZones()
    table.wipe(PlayerData)
    ESX.PlayerLoaded = false
end)

AddEventHandler('onResourceStart', function(res)
    if GetCurrentResourceName() ~= res or not ESX.PlayerLoaded then return end
    PlayerData = ESX.PlayerData
    ChargeZones(PlayerData.job.name)
end)

AddEventHandler('esx:setPlayerData', function(key, value)
    PlayerData[key] = value
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
    initGlobal(PlayerData.job.name)
end)

function hasPlyLoaded()
    return ESX.PlayerLoaded
end

function DoNotification(text, nType)
    ESX.ShowNotification(text, nType)
end

function GetJobLabel(job)
    return lib.callback.await('randol_billing:server:esxJobs', false, job)
end
