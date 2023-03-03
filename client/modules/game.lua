RPX.Game = {}

RPX.Game.RequestModel = function(modelHash)
    if not IsModelInCdimage(modelHash) then 
        return false
    end
    RequestModel(modelHash)
    local loaded
    for i=1, 100 do 
        if HasModelLoaded(modelHash) then
            loaded = true 
            break
        end
        Wait(100)
    end
    return loaded
end

RPX.Game.RequestAnim = function(animDict)
    if not DoesAnimDictExist(animDict) then 
        return false
    end
    RequestAnimDict(animDict)
    local loaded
    for i=1, 100 do 
        if HasAnimDictLoaded(animDict) then
            loaded = true 
            break
        end
        Wait(100)
    end
    return loaded
end

RPX.Game.CreateVehicle = function(modelHash, ...)
    if not RPX.Game.RequestModel(modelHash) then return end
    local veh = CreateVehicle(modelHash, ...)
    SetModelAsNoLongerNeeded(modelHash)
    if not DoesEntityExist(veh) then return end
    return veh
end

RPX.Game.CreatePed = function(modelHash, ...)
    if not RPX.Game.RequestModel(modelHash) then return end
    local ped = CreatePed(26, modelHash, ...)
    SetModelAsNoLongerNeeded(modelHash)
    if not DoesEntityExist(ped) then return end
    return ped
end

RPX.Game.CreateObject = function(modelHash, ...)
    if not RPX.Game.RequestModel(modelHash) then return end
    local obj = CreateObject(modelHash, ...)
    SetModelAsNoLongerNeeded(modelHash)
    if not DoesEntityExist(obj) then return end
    return obj
end

function PerformAnim(ped, dict, anim, settings)
    if settings.time then 
        Wait(settings.time)
    end
    return
end

RPX.Game.TaskPlayAnim = function(ped, dict, anim, settings, cb)
    if not RPX.Game.RequestAnim(dict) then return end
    TaskPlayAnim(ped, dict, anim, table.unpack(settings.flags))
    if cb then 
        CreateThread(function() 
            PerformAnim(ped, dict, anim, settings)
            cb()
        end)
    else
        return PerformAnim(ped, dict, anim, settings)
    end
end

RPX.Game.GetClosestPlayer = function(ped, radius)
    local activePlayers, pedCoords, closestDist, closestPlayer = GetActivePlayers(), GetEntityCoords(ped), nil, nil
    for _,playerId in ipairs(activePlayers) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= ped then
            local targetCoords, dist = GetEntityCoords(targetPed), #(targetCoords - pedCoords)
            if closestDist == nil or closestDist > dist then
                closestPlayer = playerId
                closestDist = dist
            end
        end
    end
    if closestDist ~= nil and closestDist <= radius then
        return closestPlayer, closestDist
    else
        return nil
    end
end