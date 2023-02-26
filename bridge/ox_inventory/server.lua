Inventory = {}

Inventory.SetPlayerInventory = function(source, inventory)
    local player = RPX.GetPlayerFromId(source)
    player.SetPlayerInventory(inventory)
    --exports.ox_inventory:setPlayerInventory(player, inventory)
end

Inventory.LoadPlayer = function(source)
    local identifier = RPX.GetPlayerIdentifier(source, "license")
    MySQL.Async.fetchScalar("SELECT inventory FROM players WHERE identifier=?;", { identifier }, 
        function(inventory)
            if inventory then 
                local inventory = json.decode(inventory)
                Inventory.SetPlayerInventory(source, inventory)
            end
        end
    )
end

Inventory.AddItem = function(source, item, amount, data)
    return exports.ox_inventory:AddItem(source, item, amount, data?.metadata, data?.slot)
end

Inventory.RemoveItem = function(source, item, amount, data)
    return exports.ox_inventory:RemoveItem(source, item, amount, data?.metadata, data?.slot)
end

Inventory.Search = function(source, item, data)
    return exports.ox_inventory:Search(source, "count", item, data?.metadata)
end