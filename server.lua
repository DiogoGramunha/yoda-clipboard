-- Server-side handler to give/remove clipboard item to the player
RegisterNetEvent('yoda-clipboard:GiveClipboard')
AddEventHandler('yoda-clipboard:GiveClipboard', function(state)
    local src = source
    if not src or src == 0 then return end

    print("=== GIVING CLIPBOARD ITEM ===")
    print("Player: " .. src)
    print("State: " .. tostring(state))
    print("Inventory: " .. Config.inventory)

    if Config.inventory == 'ox' then
        if state then
            local success = exports.ox_inventory:AddItem(src, 'clipboard', 1)
            print("ox_inventory AddItem result: " .. tostring(success))
        else
            local success = exports.ox_inventory:RemoveItem(src, 'clipboard', 1)
            print("ox_inventory RemoveItem result: " .. tostring(success))
        end
    elseif Config.inventory == 'qb' then
        if state then
            TriggerEvent('QBCore:Server:AddItem', src, 'clipboard', 1)
        else
            TriggerEvent('QBCore:Server:RemoveItem', src, 'clipboard', 1)
        end
    else
        local xPlayer = ESX and ESX.GetPlayerFromId(src) or nil
        if xPlayer then
            if state then
                xPlayer.addInventoryItem('clipboard', 1)
            else
                xPlayer.removeInventoryItem('clipboard', 1)
            end
        end
    end
end)

-- Server-side exports: these functions can be called via exports from other resources
-- createTasks(playerId, taskList, total)
function createTasks(target, taskList, total)
    print("=== YODA-CLIPBOARD SERVER ===")
    print("createTasks called with target: " .. tostring(target))
    print("taskList: " .. json.encode(taskList))
    print("total: " .. tostring(total))
    
    -- target can be a player id or source; trigger client event to open UI
    local playerId = tonumber(target) or target
    if not playerId then 
        print("❌ Invalid playerId")
        return false 
    end

    -- Backwards/ flexible compatibility:
    -- If caller passed (playerId, total) with no taskList, handle that.
    if type(taskList) == 'number' and total == nil then
        total = taskList
        taskList = {}
    end

    -- Ensure taskList is a table
    if type(taskList) ~= 'table' then
        taskList = {}
    end

    -- Determine total safely
    local tot = tonumber(total) or (#taskList)
    if not tot then tot = 0 end

    print("Sending to client " .. playerId .. " with " .. tot .. " tasks")
    TriggerClientEvent('yoda-clipboard:createTasks', playerId, taskList, tot)
    return true
end

-- addTaskCompleted(playerId, taskId, count)
function addTaskCompleted(target, taskId, count)
    local playerId = tonumber(target) or target
    if not playerId then return false end
    TriggerClientEvent('yoda-clipboard:addTaskCompleted', playerId, taskId, count or 1)
    return true
end

-- clearClipboard(playerId)
function clearClipboard(target)
    local playerId = tonumber(target) or target
    if not playerId then return false end
    TriggerClientEvent('yoda-clipboard:clearClipboard', playerId)
    return true
end

-- Export the functions for other server resources to use
exports('createTasks', createTasks)
exports('addTaskCompleted', addTaskCompleted)
exports('clearClipboard', clearClipboard)