if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

function GetPlayer(id)
    return ESX.GetPlayerFromId(id)
end

function DoNotification(src, text, nType)
    TriggerClientEvent('esx:showNotification', src, text, nType)
end

function GetCharacterName(xPlayer)
    return xPlayer.getName()
end

function GetPlayerJob(xPlayer)
    return xPlayer.job
end

function addSocietyFunds(job, amount, reason)
    TriggerEvent('esx_addonaccount:getSharedAccount', ('society_%s'):format(job), function(account) -- Society accoutns by default, feel free to change.
        account.addMoney(amount)
    end)
end

function AddMoney(xPlayer, moneyType, amount)
    local account = moneyType == 'cash' and 'money' or moneyType
    xPlayer.addAccountMoney(account, amount, 'commission')
end

function RemovePlayerMoney(xPlayer, amount, moneyType)
    local account = (moneyType == 'cash' and 'money') or moneyType

    if xPlayer.getAccount(account).money >= amount then
        xPlayer.removeAccountMoney(account, amount, 'billing')
        return true
    end

    return false
end

lib.callback.register('randol_billing:server:esxJobs', function(source, job)
    return ESX.GetJobs()[job].label
end)