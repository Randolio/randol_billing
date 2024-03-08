local Config = lib.require('config')
local Webhook = ''

local function sendLog(title, message)
    local embed = { { ['title'] = title, ['description'] = message, } }
    PerformHttpRequest(Webhook, function(err, text, headers) end, 'POST', json.encode({ username = 'TPRP Logs', embeds = embed}), { ['Content-Type'] = 'application/json' })
end

local function isJob(job)
    if Config.Jobs[job.name] then
        return true
    end
    return false
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
            local Ply = GetPlayer(playerId)
            local name = GetCharacterName(Ply)
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
    local Biller = GetPlayer(src)
    local Target = GetPlayer(data.id)
    local Billersrc = GetPlayerPed(src)
    local Targetsrc = GetPlayerPed(data.id)
    local job = GetPlayerJob(Biller)

    if not isJob(job) then 
        return 
    end

    if not Target then 
        return DoNotification(src, 'Person Not Online', 'error') 
    end

    if data.amount <= 0 then 
        return DoNotification(src, 'Must be a valid amount above 0.', 'error') 
    end

    if #(GetEntityCoords(Billersrc) - GetEntityCoords(Targetsrc)) > Config.Distance then 
        return DoNotification(src, 'The person you are charging is not near you?', 'error') 
    end
    
    local info = { srcid = src, trgid = data.id, fee = data.amount, account = data.accountType, confirm = false}
    TriggerClientEvent('randol_billing:client:sendConfirm', data.id, info)
end)

RegisterNetEvent('randol_billing:server:chargePlayer', function(data)
    local src = source
    local Biller = GetPlayer(data.srcid)
    local Target = GetPlayer(data.trgid)
    local job = GetPlayerJob(Biller)
    local perc = Config.Jobs[job.name].Percent or 0
    local commission = math.ceil(data.fee * perc)

    if not data.confirm then
        DoNotification(data.srcid, 'Customer declined the charge.', 'error', 8000)
        return
    end

    if RemovePlayerMoney(Target, data.fee, data.account) then
        if Config.EnableCommission then
            AddMoney(Biller, 'bank', commission)
            DoNotification(data.srcid, ('You billed a customer for $%s & recevied $%s commission'):format(data.fee, commission), 'success')
            addSocietyFunds(job.name, data.fee - commission, 'billing')
            sendLog("Charge/Billing", "Biller: `" .. GetCharacterName(Biller) .. "`\nCustomer: `" .. GetCharacterName(Target) .. "`\nBusiness: `" .. job.name .. "`\nAmount:`$" .. data.fee .. "`\nCommission:`$" .. commission .. "`")
        else
            DoNotification(data.srcid, ('You billed a customer for $%s.'):format(data.fee), 'success')
            addSocietyFunds(job.name, data.fee, 'billing')
            sendLog("Charge/Billing", "Biller: `" .. GetCharacterName(Biller) .. "`\nCustomer: `" .. GetCharacterName(Target) .. "`\nBusiness: `" .. job.name .. "`\nAmount:`$" .. data.fee .. "`")
        end     
        DoNotification(data.trgid, ('You have been charged $%s from %s'):format(data.fee, job.label))
    else
        DoNotification(data.trgid, "You don't have enough money for this.", "error", 8000)
        DoNotification(data.srcid, 'Customer does not have enough money for this.', 'error', 8000)
    end
end)
