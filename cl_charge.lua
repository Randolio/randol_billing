local chargeZones = {}

local function ChargeMenu(jobName)
    local jobLabel = QBCore.Shared.Jobs[jobName].label
    local response = lib.inputDialog(jobLabel, {
        { type = "number", label = "How much?", icon = 'fa-solid fa-hand-holding-dollar', placeholder = "$", min = 1, description = "Input an amount to charge.", required = true   },
        { type = "number", label = "Customer ID", icon = 'fa-solid fa-address-card', placeholder = "?", description = "Input the customer's ID number.", required = true   },
        { type = 'select', label = 'Account', required = true, icon = 'fa-solid fa-wallet', 
            options = {
                { value = 'cash', label = 'Cash' },
                { value = 'bank', label = 'Bank' },
            }
        },
    })
    if not response then return end
    local data = {
        amount = response[1],
        id = response[2],
        accountType = response[3],
    }
    TriggerServerEvent('randol_billing:server:attemptCharge', data)
end

local function ChargeZones()
    for job, locations in pairs(Config.JobZones) do
        for i = 1, #locations do
            local v = locations[i]
            local zone = exports.ox_target:addSphereZone({
                coords = v.coords,
                radius = 0.4,
                debug = false,
                options = {
                    {
                        icon = "fa-solid fa-money-check-dollar",
                        groups = job,
                        label = 'Charge Customer',
                        onSelect = function()
                            if not QBCore.Functions.GetPlayerData().jobb.onduty then
                                return QBCore.Functions.Notify("You are not clocked in.", "error")
                            end
                            ChargeMenu(job)
                        end,
                        distance = 1.5,
                    },
                }
            })
            chargeZones[#chargeZones+1] = zone
        end
    end
end

AddEventHandler('onResourceStop', function(resourceName) 
	if GetCurrentResourceName() == resourceName then
        for k, v in pairs(chargeZones) do
            exports.ox_target:removeZone(v)
        end
	end 
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    ChargeZones()
end)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        ChargeZones()
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    for k, v in pairs(chargeZones) do
        exports.ox_target:removeZone(v)
    end
    table.wipe(chargeZones)
end)

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