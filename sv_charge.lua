local Config = lib.require('config')
local Webhook = ''

local function sendLog(title, message)
    local embed = { { ['title'] = title, ['description'] = message, } }
    PerformHttpRequest(Webhook, function(err, text, headers) end, 'POST', json.encode({ username = 'TPRP Logs', embeds = embed}), { ['Content-Type'] = 'application/json' })
end

local function isJob(src)
    local src = src
    local Biller = QBCore.Functions.GetPlayer(src)
    if Config.JobZones[Biller.PlayerData.job.name] then
        return true
    end
    return false
end

local function addSocietyFunds(job, amount, reason)
    if Config.Society == 'renewed' then
        exports['Renewed-Banking']:addAccountMoney(job, amount)
    elseif Config.Society == 'qb-banking' then
        exports['qb-banking']:AddMoney(job, amount, reason)
    elseif Config.Society == 'qb-management' then
        exports['qb-management']:AddMoney(job, amount)
    else
        print("INVALID SOCIETY FUNDS EXPORT.")
    end
end

local function getNearbyCharacters(coords) -- Modification from ox lib.
    local players = GetActivePlayers()
    local nearby = {}

    for i = 1, #players do
        local playerId = players[i]
        local playerPed = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(coords - playerCoords)

        if distance <= Config.Distance then
            local Ply = QBCore.Functions.GetPlayer(playerId)
            local name = Ply.PlayerData.charinfo.firstname .. ' ' .. Ply.PlayerData.charinfo.lastname
            nearby[#nearby+1] = {
                id = playerId,
                name = name,
            }
        end
    end

    return nearby
end

lib.callback.register('randol_billing:server:getCharacters', function(source)
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local nearby = getNearbyCharacters(coords)
    return nearby
end)

RegisterNetEvent('randol_billing:server:attemptCharge', function(data)
    local src = source
    local Biller = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(data.id)
    local Billersrc = GetPlayerPed(src)
    local Targetsrc = GetPlayerPed(data.id)

    if not isJob(src) then 
        return 
    end

    if not Target then 
        return QBCore.Functions.Notify(src, 'Person Not Online', 'error') 
    end

    if data.amount <= 0 then 
        return QBCore.Functions.Notify(src, 'Must be a valid amount above 0.', 'error') 
    end

    if #(GetEntityCoords(Billersrc) - GetEntityCoords(Targetsrc)) > Config.Distance then 
        return QBCore.Functions.Notify(src, 'The person you are charging is not near you?', 'error') 
    end
    
    local info = { srcid = src, trgid = data.id, fee = data.amount, account = data.accountType, confirm = false}
    TriggerClientEvent('randol_billing:client:sendConfirm', data.id, info)
end)

RegisterNetEvent('randol_billing:server:chargePlayer', function(data)
    local src = source
    local Biller = QBCore.Functions.GetPlayer(data.srcid)
    local Target = QBCore.Functions.GetPlayer(data.trgid)
    local commission = math.ceil(data.fee * Config.Percent)
    local success = false
    if not data.confirm then
        QBCore.Functions.Notify(Biller.PlayerData.source, 'Customer declined the charge.', 'error', 8000)
        return
    end
    if Target.PlayerData.money[data.account] >= data.fee then
        Target.Functions.RemoveMoney(data.account, data.fee, 'Billed by '..Biller.PlayerData.job.label)
        if Config.EnableCommission then
            Biller.Functions.AddMoney('bank', commission)
            QBCore.Functions.Notify(Biller.PlayerData.source, ('You billed a customer for $%s & recevied $%s commission'):format(data.fee, commission), 'success')
            addSocietyFunds(Biller.PlayerData.job.name, data.fee - commission, 'billing')
            sendLog("Charge/Billing", "Biller: `" .. Biller.PlayerData.charinfo.firstname .. " " .. Biller.PlayerData.charinfo.lastname .. "`\nCustomer: `" .. Target.PlayerData.charinfo.firstname .. " " .. Target.PlayerData.charinfo.lastname .. "`\nBusiness: `" .. Biller.PlayerData.job.name .. "`\nAmount:`$" .. data.fee .. "`\nCommission:`$" .. commission .. "`")
        else
            QBCore.Functions.Notify(Biller.PlayerData.source, ('You billed a customer for $%s.'):format(data.fee), 'success')
            addSocietyFunds(Biller.PlayerData.job.name, data.fee, 'billing')
            sendLog("Charge/Billing", "Biller: `" .. Biller.PlayerData.charinfo.firstname .. " " .. Biller.PlayerData.charinfo.lastname .. "`\nCustomer: `" .. Target.PlayerData.charinfo.firstname .. " " .. Target.PlayerData.charinfo.lastname .. "`\nBusiness: `" .. Biller.PlayerData.job.name .. "`\nAmount:`$" .. data.fee .. "`")
        end     
        QBCore.Functions.Notify(Target.PlayerData.source, ('You have been charged $%s from %s'):format(data.fee, Biller.PlayerData.job.label))
    else
        QBCore.Functions.Notify(Target.PlayerData.source, "You don't have enough money for this.", "error", 8000)
        QBCore.Functions.Notify(Biller.PlayerData.source, 'Customer does not have enough money for this.', 'error', 8000)
    end
end)
