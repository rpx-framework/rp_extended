registeredPlayers   = {}
registeredJobs      = Config.Jobs or {}

RPX.UsableItems = {} 

RPX.OnItemUsed = function(source, name, ...)
    if not RPX.UsableItems[name] then return end
    RPX.UsableItems[name](source, ...)
end

RPX.RegisterUsableItem = function(name, cb)
    RPX.UsableItems[name] = cb
end

RPX.GetPlayers = function()
    local array = {}
    for k,v in pairs(registeredPlayers) do 
        array[#array + 1] = v
    end
    return array
end

RPX.GetPlayerFromId = function(source)
    return registeredPlayers[source]
end

RPX.GetPlayerFromIdentifier = function(identifier)
    for k,v in pairs(registeredPlayers) do 
        if v.identifier == identifier then return v end
    end
end

RPX.GetPlayerIdentifier = function(source, key)
    for i=0, GetNumPlayerIdentifiers(source) do
        local identifier = GetPlayerIdentifier(source, i)
        if string.find(identifier, key) then return identifier end
    end
end

RPX.RegisterJob = function(name, data)
    registeredJobs[name] = data
end

function SavePlayer(source, cb)
    local player = registeredPlayers[source]
    MySQL.Async.fetchAll("SELECT * FROM players WHERE identifier=?;", { player.identifier }, 
        function(results)
            local dbPlayer = {
                skin       = player.skin,
                metadata   = player.metadata,
                activeJob  = player.activeJob,
                jobs       = player.jobs,
                licenses   = player.licenses,
                groups     = player.groups,
                accounts   = player.accounts,
                inventory  = player.inventory,
                status     = player.status
            }
            if #results > 0 then 
                MySQL.Async.execute("UPDATE players SET data=?, inventory=? WHERE identifier=?;", { json.encode(dbPlayer), player.identifier}, cb)
            else
                MySQL.Async.execute("INSERT INTO players (identifier, data) VALUES (?, ?);", { player.identifier, json.encode(dbPlayer)}, cb)
            end
        end
    )
end

function LoadPlayer(source, cb)
    local player = registeredPlayers[source]
    if player then return end
    local identifier = RPX.GetPlayerIdentifier(source, "license")
    MySQL.Async.fetchAll("SELECT data, last_updated FROM players WHERE identifier=?;", { identifier }, 
        function(results)
            local dbPlayer
            if #results > 0 then 
                local result = json.decode(results[1].data)
                dbPlayer = {
                    source     = source,
                    identifier = identifier,
                    skin       = result.skin,
                    metadata   = result.metadata,
                    activeJob  = result.activeJob,
                    jobs       = result.jobs,
                    licenses   = result.licenses,
                    groups     = result.groups,
                    accounts   = result.accounts,
                    inventory  = result.inventory,
                    status     = result.status
                }
            else
                dbPlayer = {
                    source      = source,
                    identifier  = identifier,
                    firstJoin   = true
                }
            end
            registeredPlayers[source] = PlayerObject(dbPlayer)
            Inventory.LoadPlayer(source)
            cb()
        end
    )
end

/* Test Loading of Players */

MySQL.ready(function() 
    local source = 1
    LoadPlayer(source, function()
        SavePlayer(source)
    end)
end)

if not registeredJobs["unemployed"] then 
    RPX.RegisterJob("unemployed", {
        label = "Unemployed",
        ranks = {
            {
                label = "Unemployed",
                salary = 100,
            },
        }
    })
end