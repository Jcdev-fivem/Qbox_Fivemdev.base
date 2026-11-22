-- Register NUI Callback & Character Creation
local isSubmitting = false

local function handleAppearance(gender)
    local app = Config.Appearance
    if not app or app == 'none' then return end

    if app == 'illenium-appearance' and GetResourceState('illenium-appearance') == 'started' then
        Wait(500)
        TriggerEvent('qb-clothes:client:CreateFirstCharacter')
    elseif app == 'fivem-appearance' and GetResourceState('fivem-appearance') == 'started' then
        Wait(500)
        TriggerEvent('fivem-appearance:client:CreateFirstCharacter')
    elseif app == 'qb-clothing' and GetResourceState('qb-clothing') == 'started' then
        Wait(500)
        TriggerEvent('qb-clothing:client:openMenu')
    elseif app == 'custom' and Config.CustomAppearanceEvent then
        Wait(500)
        TriggerEvent(Config.CustomAppearanceEvent, gender)
    else
        print(('^3[jacob_multicharacter]^7 Appearance resource "%s" is not started. Character spawned without clothing menu.'):format(tostring(app)))
    end
end

local function spawnIntoCity(payload)
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(50) end

    -- 1. Create character in qbx_core database
    local newCharData = lib.callback.await('qbx_core:server:createCharacter', false, {
        firstname = payload.firstname,
        lastname = payload.lastname,
        nationality = payload.nationality or Config.DefaultNationality,
        birthdate = payload.birthdate,
        gender = payload.gender
    })

    if not newCharData then
        DoScreenFadeIn(300)
        SetNuiFocus(true, true)
        SendNUIMessage({ action = 'openRegisterDirect' })
        lib.notify({
            title = 'Registration Failed',
            description = 'Could not create character in database.',
            type = 'error'
        })
        isSubmitting = false
        return
    end

    if payload.height then
        TriggerServerEvent('jacob_multicharacter:server:setHeightMetadata', payload.height)
    end

    -- 2. Reset routing bucket to normal world
    TriggerServerEvent('jacob_multicharacter:server:setBucket', 0)

    -- 3. Spawn character at Config.DefaultSpawn (Legion Square)
    local spawnCoords = Config.DefaultSpawn
    local charModel = (tonumber(payload.gender) == 1) and `mp_f_freemode_01` or `mp_m_freemode_01`

    exports.spawnmanager:spawnPlayer({
        x = spawnCoords.x,
        y = spawnCoords.y,
        z = spawnCoords.z,
        heading = spawnCoords.w,
        model = charModel,
        skipFade = false
    }, function()
        local ped = PlayerPedId()
        SetEntityVisible(ped, true, false)
        FreezeEntityPosition(ped, false)
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'closeUI' })

        Wait(400)
        DoScreenFadeIn(1000)

        TriggerEvent('QBCore:Client:OnPlayerLoaded')
        TriggerServerEvent('QBCore:Server:OnPlayerLoaded')

        -- 4. Trigger appearance creator if configured
        handleAppearance(payload.gender)

        isSubmitting = false
    end)
end

RegisterNUICallback('submitRegister', function(data, cb)
    if isSubmitting then
        return cb({ success = false, message = 'กำลังสร้างตัวละคร กรุณารอสักครู่...' })
    end
    isSubmitting = true

    local fn = tostring(data and data.firstname or ''):gsub('^%s+', ''):gsub('%s+$', '')
    local ln = tostring(data and data.lastname or ''):gsub('^%s+', ''):gsub('%s+$', '')

    if fn == '' or ln == '' then
        isSubmitting = false
        return cb({ success = false, message = 'กรุณากรอกข้อมูลให้ครบถ้วน' })
    end

    local payload = {
        firstname = fn,
        lastname = ln,
        nationality = Config.DefaultNationality,
        birthdate = tostring(data.birthdate or '01/01/2000'),
        gender = tonumber(data.gender) or 0,
        height = data.height
    }

    cb({ success = true })

    -- Hide the multichar UI and spawn directly into the city
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeUI' })

    spawnIntoCity(payload)
end)
