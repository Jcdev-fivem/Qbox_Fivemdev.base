-- Get player's identifiers (handles license2, license, and stripped forms)
local function getIdentifiers(source)
    local license2 = GetPlayerIdentifierByType(source, 'license2')
    local license = GetPlayerIdentifierByType(source, 'license')
    local ids = {}
    local seen = {}

    local function addId(val)
        if val and val ~= '' and not seen[val] then
            seen[val] = true
            ids[#ids + 1] = val
        end
    end

    addId(license2)
    addId(license)
    if license2 then addId((license2:gsub('^license2:', ''))) end
    if license then addId((license:gsub('^license:', ''))) end

    return ids
end

-- Callback: Fetch all characters for source
lib.callback.register('jacob_multicharacter:server:getCharacters', function(source)
    local ids = getIdentifiers(source)
    if not ids or #ids == 0 then return {}, Config.DefaultSlots end

    local placeholders = string.rep('?, ', #ids - 1) .. '?'
    local players = MySQL.query.await([[
        SELECT citizenid, cid, charinfo, money, job, position, metadata 
        FROM players 
        WHERE license IN (]] .. placeholders .. [[) 
        ORDER BY cid ASC
    ]], ids)

    local characters = {}
    if players and #players > 0 then
        for i = 1, #players do
            local row = players[i]
            local charinfo = json.decode(row.charinfo) or {}
            local money = json.decode(row.money) or {}
            local job = json.decode(row.job) or {}
            local position = json.decode(row.position) or nil

            characters[#characters + 1] = {
                citizenid = row.citizenid,
                cid = row.cid or i,
                firstname = charinfo.firstname or 'Unknown',
                lastname = charinfo.lastname or '',
                birthdate = charinfo.birthdate or '01/01/2000',
                gender = tonumber(charinfo.gender) or 0,
                cash = money.cash or 0,
                bank = money.bank or 0,
                job = job.label or job.name or 'Unemployed',
                position = position
            }
        end
    end

    return characters, Config.DefaultSlots
end)

-- Callback: Load character via qbx_core
lib.callback.register('jacob_multicharacter:server:loadCharacter', function(source, citizenid)
    if not citizenid then return false end
    local existingPlayer = exports.qbx_core:GetPlayer(source)
    if existingPlayer then
        if existingPlayer.PlayerData and existingPlayer.PlayerData.citizenid == citizenid then
            return true
        end
    end
    local success = exports.qbx_core:Login(source, citizenid)
    return success ~= false
end)

-- Callback: Delete character via qbx_core
lib.callback.register('jacob_multicharacter:server:deleteCharacter', function(source, citizenid)
    if not Config.AllowDelete or not citizenid then return false end
    exports.qbx_core:DeleteCharacter(citizenid)
    return true
end)

-- Event: Save height metadata upon character creation
RegisterNetEvent('jacob_multicharacter:server:setHeightMetadata', function(height)
    local src = source
    if not height then return end
    local player = exports.qbx_core:GetPlayer(src)
    if player then
        player.Functions.SetMetaData('height', tostring(height))
    end
end)

-- Event: Set player routing bucket (staging / creation isolation)
RegisterNetEvent('jacob_multicharacter:server:setBucket', function(bucket)
    local src = source
    SetPlayerRoutingBucket(src, tonumber(bucket) or 0)
end)

RegisterNetEvent('jacob_appearance:server:setBucket', function(bucket)
    local src = source
    SetPlayerRoutingBucket(src, tonumber(bucket) or 0)
end)
