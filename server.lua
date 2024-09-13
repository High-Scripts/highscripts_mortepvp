ESX = exports["es_extended"]:getSharedObject()

local guildId = Config.IdServerDs
local server_token = Config.TokenBotDs

RegisterCommand('revive', function(src, args)
    if src == 0 or src == nil then
        TriggerClientEvent("highscripts_rianima:revive", tonumber(args[1]))
    else
        local xPlayer = ESX.GetPlayerFromId(src)

        if xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'mod' then
            if #args > 0 and tonumber(args[1]) then
                TriggerClientEvent("highscripts_rianima:revive", tonumber(args[1]))
            else 
                TriggerClientEvent("highscripts_rianima:revive", src)
            end
        end
    end
end, false)

RegisterCommand('r', function(src, args)
    local roleId = Config.idRuoloPermessoSLASHr

    if src == 0 or src == nil then
        TriggerClientEvent("highscripts_respawn", tonumber(args[1]))
    else
        local xPlayer = ESX.GetPlayerFromId(src)

        if hasDiscordRole(src, roleId) or xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'mod' or xPlayer.getGroup() == 'rapido' then
            if #args > 0 and tonumber(args[1]) then
                TriggerClientEvent("highscripts_respawn", tonumber(args[1]))
            else 
                TriggerClientEvent("highscripts_respawn", src)
            end
        end
    end
end, false)

function hasDiscordRole(user, role)
    local discordId = nil

    for _, id in ipairs(GetPlayerIdentifiers(user)) do
        if string.match(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            break
        end
    end

    local theRole = tostring(role)

    if discordId then
        local endpoint = ("guilds/%s/members/%s"):format(guildId, discordId)
        local member = DiscordRequest("GET", endpoint, {})

        if member.code == 200 then
            local data = json.decode(member.data)
            local roles = data.roles
            for _, roleId in ipairs(roles) do
                if roleId == theRole then
                    return true
                end
            end
            return false
        else
            return false
        end
    else
        return false
    end
end

function DiscordRequest(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discord.com/api/v10/" .. endpoint, function(errorCode, resultData, resultHeaders)
        data = { data = resultData, code = errorCode, headers = resultHeaders }
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {["Content-Type"] = "application/json", ["Authorization"] = "Bot " .. server_token})

    while data == nil do
        Citizen.Wait(0)
    end

    return data
end