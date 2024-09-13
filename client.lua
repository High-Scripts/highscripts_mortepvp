ESX = exports["es_extended"]:getSharedObject()

local morto = false
local displayText = true

AddEventHandler('esx:onPlayerDeath', function(data)
    morto = true
    LocalPlayer.state:set("dead", true, true)
    LocalPlayer.state.injuries = true
    displayText = true
    local killerId = data.killerServerId
    if killerId then
        spectatePlayer(killerId)
    end
    timermorto()
end)

function timermorto()
    local timer = 15
    Citizen.CreateThread(function()
        while timer > 0 and displayText do
            Citizen.Wait(1000)
            timer = timer - 1
        end
    end)

    Citizen.CreateThread(function()
        while displayText do
            Citizen.Wait(0)
            if timer > 0 then
                drawText("Potrai respawnare tra " .. '~b~' .. timer .. '~w~' .. ' Secondi', 0.42, 0.91, 0.78, 255, 255, 255, 255)
            else
                drawText("Premi ~b~[E]~w~ Per respawnare", 0.42, 0.91, 0.78, 255, 255, 255, 255)

                if IsControlJustReleased(0, 38) then
                    LocalPlayer.state:set("dead", false, false)
                    LocalPlayer.state.injuries = false
                    respawninospitale()
                    displayText = false
                end
            end
        end
    end)
end

function drawText(text, x, y, scale, r, g, b, a)
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function respawninospitale()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, true, false)
    SetEntityHealth(playerPed, 200)
    SetEntityCoords(PlayerPedId(), 296.9916, -584.3335, 43.1325)
    SetEntityHeading(PlayerPedId(), 71.7594)
    TriggerEvent('rianima')
end

function spectatePlayer(playerId)
    local playerPed = PlayerPedId()
    local killerPed = GetPlayerPed(GetPlayerFromServerId(playerId))

    if DoesEntityExist(killerPed) then
        local offset = GetOffsetFromEntityInWorldCoords(killerPed, 0.2, 2.5, 1.5)

        local camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

        SetCamCoord(camera, offset.x, offset.y, offset.z)
        PointCamAtEntity(camera, killerPed)
        SetCamActive(camera, true)
        RenderScriptCams(true, false, 0, true, true)

        NetworkSetInSpectatorMode(true, killerPed)
    end
end



function stopSpectating()
    local playerPed = PlayerPedId()
    NetworkSetInSpectatorMode(false, playerPed)
    RenderScriptCams(false, false, 0, true, true)
end

RegisterNetEvent('rianima')
AddEventHandler('rianima', function ()
    LocalPlayer.state.injuries = false
    LocalPlayer.state:set("dead", false, false)
    morto = false
    displayText = false
    ClearTimecycleModifier()
    ClearPedBloodDamage(PlayerPedId())
    stopSpectating()
end)

RegisterNetEvent('highscripts_rianima:revive')
AddEventHandler('highscripts_rianima:revive', function ()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, true, false)
    SetEntityHealth(playerPed, 200)
    LocalPlayer.state.injuries = false
    LocalPlayer.state:set("dead", false, false)
    morto = false
    displayText = false
    ClearTimecycleModifier()
    ClearPedBloodDamage(PlayerPedId())
    stopSpectating()
end)

RegisterNetEvent('highscripts_respawn')
AddEventHandler('highscripts_respawn', function ()
    respawninospitale()
end)