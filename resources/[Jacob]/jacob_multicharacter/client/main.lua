local isStarted = false

local function startMulticharacter()
    if isStarted then return end
    isStarted = true

    -- Clear any leftover creation bucket from a previous session on this client.
    TriggerServerEvent('jacob_multicharacter:server:setBucket', 0)

    -- Force kill FiveM loading screen immediately
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()

    -- Fetch characters from server
    local characters, maxSlots = lib.callback.await('jacob_multicharacter:server:getCharacters', false)

    -- 1. If player already has characters:
    if characters and #characters > 0 then
        if Config.SingleCharacterMode then
            local char = characters[1]
            local success = lib.callback.await('jacob_multicharacter:server:loadCharacter', false, char.citizenid)

            local savedPos = char.position
            local spawnCoords = (savedPos and savedPos.x and savedPos.y and savedPos.z) 
                and vec4(savedPos.x, savedPos.y, savedPos.z, savedPos.w or savedPos.h or savedPos.a or savedPos.heading or 0.0) 
                or Config.DefaultSpawn

            local charModel = (tonumber(char.gender) == 1) and `mp_f_freemode_01` or `mp_m_freemode_01`

            exports.spawnmanager:spawnPlayer({
                x = spawnCoords.x,
                y = spawnCoords.y,
                z = spawnCoords.z,
                heading = spawnCoords.w,
                model = charModel,
                skipFade = false
            }, function()
                SetNuiFocus(false, false)
                SendNUIMessage({ action = 'closeUI' })
                TriggerEvent('QBCore:Client:OnPlayerLoaded')
                TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
            end)
            return
        else
            -- Multi-character selection mode
            local staging = Config.SkinStaging
            RequestCollisionAtCoord(staging.pedCoords.x, staging.pedCoords.y, staging.pedCoords.z)

            exports.spawnmanager:spawnPlayer({
                x = staging.pedCoords.x,
                y = staging.pedCoords.y,
                z = staging.pedCoords.z,
                heading = staging.pedCoords.w,
                model = `mp_m_freemode_01`,
                skipFade = true
            }, function()
                local ped = PlayerPedId()
                FreezeEntityPosition(ped, true)
                SetEntityVisible(ped, false, false)

                ShutdownLoadingScreen()
                ShutdownLoadingScreenNui()

                DoScreenFadeIn(300)
                SetNuiFocus(true, true)

                SendNUIMessage({
                    action = 'openMulticharacter',
                    characters = characters,
                    maxSlots = maxSlots or Config.DefaultSlots
                })
            end)
            return
        end
    end

    -- 2. If no character exists: Spawn dummy ped at Staging to satisfy FiveM engine & avoid Story Mode timeout!
    local staging = Config.SkinStaging
    RequestCollisionAtCoord(staging.pedCoords.x, staging.pedCoords.y, staging.pedCoords.z)

    exports.spawnmanager:spawnPlayer({
        x = staging.pedCoords.x,
        y = staging.pedCoords.y,
        z = staging.pedCoords.z,
        heading = staging.pedCoords.w,
        model = `mp_m_freemode_01`,
        skipFade = true
    }, function()
        local ped = PlayerPedId()
        FreezeEntityPosition(ped, true)
        SetEntityVisible(ped, false, false) -- Keep invisible while in Register form

        -- Isolate the player while they are in the registration/creation zone so
        -- two new characters cannot stand inside each other at the staging point.
        TriggerServerEvent('jacob_multicharacter:server:setBucket', 900000 + GetPlayerServerId(PlayerId()))

        -- Force loading screen off once more
        ShutdownLoadingScreen()
        ShutdownLoadingScreenNui()

        DoScreenFadeIn(300)
        SetNuiFocus(true, true)

        SendNUIMessage({
            action = 'openRegisterDirect'
        })
    end)
end

-- Proper session initialization and auto-spawn disabling
CreateThread(function()
    while not NetworkIsSessionStarted() do 
        Wait(50) 
    end

    pcall(function() 
        exports.spawnmanager:setAutoSpawn(false) 
    end)

    Wait(200)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()

    startMulticharacter()
end)

-- Support resource restarts while testing
AddEventHandler('onClientResourceStart', function(resName)
    if GetCurrentResourceName() ~= resName then return end
    if isStarted then return end
    Wait(500)
    startMulticharacter()
end)

-- Handle Qbox logout event
RegisterNetEvent('qbx_core:client:playerLoggedOut', function()
    isStarted = false
    startMulticharacter()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local ped = PlayerPedId()
    SetEntityVisible(ped, true, false)
    FreezeEntityPosition(ped, false)
    SetNuiFocus(false, false)
end)

-- Debug / Admin commands
RegisterCommand('multichar', function()
    isStarted = false
    startMulticharacter()
end, false)

RegisterCommand('newchar', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openRegisterDirect'
    })
end, false)

RegisterCommand('skincreator', function()
    local ok, hasGroup = pcall(function()
        return exports.qbx_core:HasGroup('admin')
    end)
    if not ok or not hasGroup then
        lib.notify({
            title = 'No permission',
            description = 'This command is for admins.',
            type = 'error'
        })
        return
    end

    if GetResourceState('jacob_appearance') == 'started' then
        TriggerEvent('jacob_appearance:client:startCreator', 0, false, 'admin')
    elseif GetResourceState('illenium-appearance') == 'started' then
        local conf = {
            ped = true,
            headBlend = true,
            faceFeatures = true,
            headOverlays = true,
            components = true,
            props = true,
            tattoos = true,
        }
        exports['illenium-appearance']:startPlayerCustomization(function(appearance)
            if appearance then
                TriggerServerEvent('illenium-appearance:server:saveAppearance', appearance)
            end
        end, conf)
    else
        lib.notify({
            title = 'Appearance',
            description = 'No appearance resource is running.',
            type = 'error'
        })
    end
end, false)
