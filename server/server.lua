ESX = exports["es_extended"]:getSharedObject()

local function getNumberOfCops()
    local cops = 0
    local xPlayers = ESX.GetPlayers()

    for i = 1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer and xPlayer.job.name == 'police' then
            cops = cops + 1
        end
    end

    return cops
end

local lastHackAttempt = {}

local COOLDOWN_TIME = Config.Cooldown

RegisterNetEvent('gramour_atmrobbery:tryHack')
AddEventHandler('gramour_atmrobbery:tryHack', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local playerId = xPlayer.identifier
    local currentTime = os.time()

    if lastHackAttempt[playerId] and currentTime - lastHackAttempt[playerId] < COOLDOWN_TIME then
        local remainingTime = COOLDOWN_TIME - (currentTime - lastHackAttempt[playerId])
        local remainingMinutes = math.ceil(remainingTime / 60)
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'You have cooldown',
            description = ('You must wait for ~r~%s~s~.'):format(remainingMinutes .. ' minutes'),
            type = 'error',
            position = 'top-right'
        })
        return
    end

    if xPlayer then
        local copsOnline = getNumberOfCops()
        
        if copsOnline >= Config.PoliceCount then
            local hasItem = xPlayer.getInventoryItem(Config.Item).count
            print(hasItem)
            if hasItem >= 1 then
                lastHackAttempt[playerId] = currentTime
                local coords = GetEntityCoords(GetPlayerPed(src))
                xPlayer.removeInventoryItem(Config.Item, 1)
                TriggerClientEvent('gramour_atmrobbery:startHack', src)
            else
                TriggerClientEvent('gramour_atmrobbery:missingItem', src)
            end
        else
            TriggerClientEvent('gramour_atmrobbery:notEnoughCops', src)
        end
    end
end)


RegisterNetEvent('gramour_atmrobbery:giveMoney')
AddEventHandler('gramour_atmrobbery:giveMoney', function(amount)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if xPlayer then
        xPlayer.addAccountMoney(Config.Money, amount)
    end
end)

