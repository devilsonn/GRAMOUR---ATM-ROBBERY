ESX = exports["es_extended"]:getSharedObject()

local PlayerData = {}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

Citizen.CreateThread(function()
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
    if ESX.IsPlayerLoaded() then
        ESX.PlayerData = ESX.GetPlayerData()
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

local atmProps = {
    `prop_atm_01`,
    `prop_atm_02`,
    `prop_atm_03`,
    `prop_fleeca_atm`
}

exports.ox_target:addModel(atmProps, {
    {
        name = 'atm_menu',
        icon = 'fas fa-credit-card',
        label = 'Hack ATM',
        onSelect = function()
            local playerPed = PlayerPedId()
            local playerPos = GetEntityCoords(playerPed)
            TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_STAND_MOBILE', 0, true)
            TriggerServerEvent('gramour_atmrobbery:tryHack', ped, gender, playerPos, within, npc)
            DispatchCall(playerPos)
            Wait(10000)
            ClearPedTasks(playerPed)
        end,
        canInteract = function(entity, distance, coords, name)
            return true
        end
    }
})

RegisterNetEvent('gramour_atmrobbery:startHack')
AddEventHandler('gramour_atmrobbery:startHack', function()
    lib.notify({
        title = 'You started hacking ATM',
        description = 'Hurry up!',
        type = 'success',
    })      
    Wait(3000)
    TriggerEvent("utk_fingerprint:Start", 4, 6, 2, function(output)
        if output == true then
            TriggerEvent('gramour_atmrobbery:hackSuccess')
        else
            TriggerEvent('gramour_atmrobbery:hackFailed')
        end
    end)
end)

RegisterNetEvent('gramour_atmrobbery:hackSuccess')
AddEventHandler('gramour_atmrobbery:hackSuccess', function()
    lib.notify({
        title = 'You successfully hacked ATM',
        description = 'Grab that money and get the fuck out!',
        type = 'success',
    })

    local bagProp = CreateObject(GetHashKey('prop_cs_heist_bag_02'), 0, 0, 0, true, true, true)

    AttachEntityToEntity(bagProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.1, 0.0, -0.2, 180.0, 150.0, 90.0, true, true, false, true, 1, true)

    if lib.progressCircle({
        duration = 20000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
        },
        anim = {
            dict = 'anim@heists@ornate_bank@grab_cash_heels',
            clip = 'grab'
        },
        prop = {
            model = `prop_anim_cash_pile_02`,
            pos = vec3(0.03, 0.03, 0.02),
            rot = vec3(0.0, 0.0, -1.5)
        },
    }) then
        print('Do stuff when complete')

        DeleteObject(bagProp)

    else
        print('Do stuff when cancelled')

        DeleteObject(bagProp)
    end

    local amount = math.random(Config.minReward, Config.maxReward)
    TriggerServerEvent('gramour_atmrobbery:giveMoney', amount)
end)

RegisterNetEvent('gramour_atmrobbery:hackFailed')
AddEventHandler('gramour_atmrobbery:hackFailed', function()
    lib.notify({
        title = 'You fucked it up!',
        description = 'You failed hacking ATM',
        type = 'error',
    })      
end)

RegisterNetEvent('gramour_atmrobbery:notEnoughCops')
AddEventHandler('gramour_atmrobbery:notEnoughCops', function()
    lib.notify({
        title = 'There are not many cops in this city!',
        description = 'Try it later',
        type = 'error',
    })     
end)

RegisterNetEvent('gramour_atmrobbery:missingItem')
AddEventHandler('gramour_atmrobbery:missingItem', function()
    lib.notify({
        title = 'You don´t have item that you need to hack it!',
        description = 'Go find it',
        type = 'error',
    })     
end)
