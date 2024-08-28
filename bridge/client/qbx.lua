if GetResourceState('qbx_core') ~= 'started' then return end

PlayerData = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = exports.qbx_core:GetPlayerData()
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
end)

AddEventHandler('onResourceStart', function(res)
    if GetCurrentResourceName() ~= res or not LocalPlayer.state.isLoggedIn then return end
    PlayerData = exports.qbx_core:GetPlayerData()
    ChargeZones(PlayerData.job.name)
end)

function hasPlyLoaded()
    return LocalPlayer.state.isLoggedIn
end

function DoNotification(text, nType)
    exports.qbx_core:Notify(text, nType)
end

function GetJobLabel(job)
    return exports.qbx_core:GetJobs()[job].label
end