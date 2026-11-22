PendingCharacter = {
    data = nil,
    set = function(d) PendingCharacter.data = d end,
    get = function() return PendingCharacter.data end,
    clear = function() PendingCharacter.data = nil end
}

-- Staging & Rooftop Management Module
Staging = {}
local isInStaging = false
local mouseEnabled = false
local mouseBlockedUntil = 0

function Staging.enable()
    if isInStaging then return end
    isInStaging = true

    CreateThread(function()
        while isInStaging do
            local wait = 250

            -- E only controls the mouse/cursor. The staging menu stays visible.
            -- When the mouse is off the game owns the input, so listen here.
            if not mouseEnabled and not IsNuiFocused() then
                wait = 0
                if GetGameTimer() >= mouseBlockedUntil and IsControlJustPressed(0, 38) then
                    Staging.setMouse(true)
                end
            end

            Wait(wait)
        end
    end)
end

function Staging.showMenu()
    if not isInStaging then return end

    -- Show the menu but leave the game playable. E turns the cursor on.
    mouseEnabled = false
    mouseBlockedUntil = 0
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'openActionModal' })
    SendNUIMessage({ action = 'setMouse', enabled = false })
end

function Staging.hideMenu()
    mouseEnabled = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeUI' })
end

function Staging.setMouse(enabled)
    if not isInStaging then return end

    mouseEnabled = enabled and true or false

    if mouseEnabled then
        SetNuiFocus(true, true)
    else
        SetNuiFocus(false, false)
        -- Stop the same E press from toggling the mouse straight back on.
        mouseBlockedUntil = GetGameTimer() + 300
    end

    SendNUIMessage({ action = 'setMouse', enabled = mouseEnabled })
end

function Staging.disable()
    isInStaging = false
    mouseEnabled = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeUI' })
    lib.hideTextUI()
end

function Staging.enterCity()
    Staging.disable()

    DoScreenFadeOut(500)
    Wait(600)

    local ped = PlayerPedId()

    -- 1. Create character in SQL if pending (FIRST TIME WRITE TO DB!)
    local pending = PendingCharacter.get()
    if pending then
        local payload = {
            firstname = pending.firstname,
            lastname = pending.lastname,
            nationality = pending.nationality or Config.DefaultNationality,
            birthdate = pending.birthdate,
            gender = pending.gender
        }
        local newCharData = lib.callback.await('qbx_core:server:createCharacter', false, payload)
        if newCharData then
            if pending.height then
                TriggerServerEvent('jacob_multicharacter:server:setHeightMetadata', pending.height)
            end

            -- 2. Save appearance to SQL now that character is created in qbx_core!
            if GetResourceState('illenium-appearance') == 'started' then
                local appearance = exports['illenium-appearance']:getPedAppearance(ped)
                if appearance then
                    TriggerServerEvent('illenium-appearance:server:saveAppearance', appearance)
                end
            end
        end
        PendingCharacter.clear()
    else
        -- If existing character, update appearance
        if GetResourceState('illenium-appearance') == 'started' then
            local appearance = exports['illenium-appearance']:getPedAppearance(ped)
            if appearance then
                TriggerServerEvent('illenium-appearance:server:saveAppearance', appearance)
            end
        end
    end

    -- 3. Teleport to city default spawn (Legion Square)
    local spawnCoords = Config.DefaultSpawn
    SetEntityCoords(ped, spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false, false)
    SetEntityHeading(ped, spawnCoords.w)
    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true, false)

    -- 4. Re-apply appearance locally to ensure ped looks right
    if GetResourceState('illenium-appearance') == 'started' then
        local appearance = exports['illenium-appearance']:getPedAppearance(ped)
        if appearance then
            exports['illenium-appearance']:setPedAppearance(ped, appearance)
        end
    end

    -- Stay in the private creation bucket until the player is actually in the
    -- city. This prevents two players at the staging point from overlapping.
    TriggerServerEvent('jacob_appearance:server:setBucket', 0)

    Wait(400)
    DoScreenFadeIn(1000)

    -- Trigger core player loaded events
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
end

-- The appearance resource owns the editor. When the player confirms the
-- creation editor, return to the staging menu instead of spawning directly.
RegisterNetEvent('jacob_appearance:client:creatorConfirmed', function()
    if not PendingCharacter.get() then return end
    Staging.enable()
    Staging.showMenu()
end)

-- Staging NUI Callbacks
RegisterNUICallback('actionDressUp', function(_, cb)
    cb('ok')

    Staging.hideMenu()
    Wait(100)

    local pending = PendingCharacter.get()
    local gender = pending and tonumber(pending.gender) or 0

    if GetResourceState('jacob_appearance') == 'started' then
        TriggerEvent('jacob_appearance:client:startCreator', gender, false, 'creation')
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
            Staging.showMenu()
        end, conf)
    else
        lib.notify({
            title = 'Appearance',
            description = 'No appearance resource is running.',
            type = 'error'
        })
    end
end)

RegisterNUICallback('actionToggleMouse', function(_, cb)
    cb('ok')
    Staging.setMouse(not mouseEnabled)
end)

RegisterNUICallback('actionEnterCity', function(_, cb)
    cb('ok')
    Staging.enterCity()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    mouseEnabled = false
    SetNuiFocus(false, false)
    lib.hideTextUI()
    TriggerServerEvent('jacob_appearance:server:setBucket', 0)
end)
