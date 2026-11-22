-- Select Character Callback
RegisterNUICallback('selectCharacter', function(data, cb)
    cb('ok')

    local citizenid = data.citizenid
    local savedPos = data.position

    -- Load character in Qbox
    local success = lib.callback.await('jacob_multicharacter:server:loadCharacter', false, citizenid)

    -- Cleanup NUI
    SetNuiFocus(false, false)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true, false)

    DoScreenFadeOut(500)
    Wait(500)

    ped = PlayerPedId()

    -- Spawn at last location or default
    if savedPos and savedPos.x and savedPos.y and savedPos.z then
        SetEntityCoords(ped, savedPos.x, savedPos.y, savedPos.z, false, false, false, false)
        local heading = savedPos.w or savedPos.h or savedPos.a or savedPos.heading or 0.0
        SetEntityHeading(ped, heading)
    else
        local def = Config.DefaultSpawn
        SetEntityCoords(ped, def.x, def.y, def.z, false, false, false, false)
        SetEntityHeading(ped, def.w)
    end

    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true, false)

    DoScreenFadeIn(1000)

    -- Trigger framework load events
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
end)

-- Delete Character Callback
RegisterNUICallback('deleteCharacter', function(data, cb)
    cb('ok')
    if not Config.AllowDelete then return end

    local success = lib.callback.await('jacob_multicharacter:server:deleteCharacter', false, data.citizenid)
    if success then
        -- Refresh character list
        local characters, maxSlots = lib.callback.await('jacob_multicharacter:server:getCharacters', false)
        SendNUIMessage({
            action = 'openMulticharacter',
            characters = characters,
            maxSlots = maxSlots
        })
    end
end)
