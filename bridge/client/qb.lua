if GetResourceState('qb-core') ~= 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

local PlayerData = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    ChargeZones(PlayerData.job.name)
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    table.wipe(PlayerData)
    removeAllZones()
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
    initGlobal(PlayerData.job.name)
end)

AddEventHandler('onResourceStart', function(res)
    if GetCurrentResourceName() ~= res or not LocalPlayer.state.isLoggedIn then return end
    PlayerData = QBCore.Functions.GetPlayerData()
    ChargeZones(PlayerData.job.name)
end)

function hasPlyLoaded()
    return LocalPlayer.state.isLoggedIn
end

function DoNotification(text, nType)
    QBCore.Functions.Notify(text, nType)
end

function GetJobLabel(job)
    return QBCore.Shared.Jobs[job].label
end