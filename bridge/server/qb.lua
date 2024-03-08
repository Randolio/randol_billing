if GetResourceState('qb-core') ~= 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

function GetPlayer(id)
    return QBCore.Functions.GetPlayer(id)
end

function DoNotification(src, text, nType)
    TriggerClientEvent('QBCore:Notify', src, text, nType)
end

function GetCharacterName(Player)
    return Player.PlayerData.charinfo.firstname.. ' ' ..Player.PlayerData.charinfo.lastname
end

function GetPlayerJob(Player)
    return Player.PlayerData.job
end

function addSocietyFunds(job, amount, reason)
    -- exports['Renewed-Banking']:addAccountMoney(job, amount)
    exports['qb-banking']:AddMoney(job, amount, reason) -- These are 3 examples, i'll leave qb-banking as default. Just remove the ones you are not using.
    -- exports['qb-management']:AddMoney(job, amount)
end

function AddMoney(Player, moneyType, amount)
    Player.Functions.AddMoney(account, amount, 'commission')
end

function RemovePlayerMoney(Player, amount, moneyType)
    local balance = Player.Functions.GetMoney(moneyType)
    if balance >= amount then
        Player.Functions.RemoveMoney(moneyType, amount, 'billing')
        return true
    end
    return false
end