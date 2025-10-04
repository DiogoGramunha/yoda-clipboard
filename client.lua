local tasks = {}
local totalTasks = 0
local completedTasks = 0
local uiOpen = false -- Variable to control whether the UI is open
local clipboardProp = nil -- Variable to store the clipboard prop

local function startClipboardAnim()
    local ped = PlayerPedId()
    local dict = "amb@world_human_clipboard@male@base"
    local propModel = "p_amb_clipboard_01" -- Clipboard model

    -- Request the prop model
    RequestModel(propModel)
    while not HasModelLoaded(propModel) do
        Wait(0)
    end

    -- Create the prop and attach it to the character's right hand
    if clipboardProp == nil then
        clipboardProp = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, false)
        AttachEntityToEntity(
            clipboardProp, 
            ped, 
            GetPedBoneIndex(ped, 60309), -- Bone index (right hand)
            0.01, -0.01, 0.0, -- Fine position adjustment (x, y, z)
            0.0, -15.0, 0.0, -- Rotation (makes the clipboard horizontal and turned to the left)
            true, true, false, true, 1, true
        )
    end

    -- Request the animation dictionary and start the animation
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
    -- TaskPlayAnim with flag 49 allows walking while animating
    TaskPlayAnim(ped, dict, "base", 8.0, -8.0, -1, 49, 0, false, false, false)
end

-- Function to stop the animation and remove the prop
local function stopClipboardAnim()
    local ped = PlayerPedId()
    ClearPedTasks(ped)

    -- Delete the prop, if it exists
    if clipboardProp ~= nil then
        DeleteObject(clipboardProp)
        clipboardProp = nil
    end
end

-- Function to ensure the animation stays active
local function ensureClipboardAnim()
    local ped = PlayerPedId()
    if not IsEntityPlayingAnim(ped, "amb@world_human_clipboard@male@base", "base", 3) then
        startClipboardAnim()
    end
end

RegisterNetEvent('yoda-clipboard:createTasks')
AddEventHandler('yoda-clipboard:createTasks', function(taskList, total)
    tasks = taskList or {}

    for _, task in ipairs(tasks) do
        if task.current == nil then
            task.current = 0
        end
        if task.total == nil then
            task.total = 1
        end
    end    

    totalTasks = total or (#tasks or 0)
    completedTasks = 0
    uiOpen = true

    -- We don't use NUI focus to allow movement; we only show the UI
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'createTasks',
        tasks = tasks,
        totalTasks = totalTasks,
        completedTasks = completedTasks
    })
    startClipboardAnim()

    if Config.framework == 'qb' then
        TriggerServerEvent('QBCore:Server:AddItem', 'clipboard', 1)
    else
        TriggerServerEvent('esx:addInventoryItem', 'clipboard', 1)
    end
end)

-- Function to close the UI
function closeUI()
    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeUI' })
    stopClipboardAnim()
end

-- Function to close the UI via NUI callback
RegisterNUICallback('closeUI', function()
    closeUI()
end)

-- Function to update a task
local function updateTask(taskId, count)
    -- Check if the task exists before trying to update
    if tasks[taskId] then
        -- Update the task's completed amount
        tasks[taskId].current = tasks[taskId].current + count

        -- Check if the task is completed
        if tasks[taskId].current >= tasks[taskId].total then
            -- Mark as completed
            completedTasks = completedTasks + 1
            SendNUIMessage({
                action = 'completeTask',  -- Action to mark as completed in the UI
                taskId = taskId
            })
        end

        -- Send the updated task count to the UI
        SendNUIMessage({
            action = 'updateTask',
            taskId = taskId,
            current = tasks[taskId].current,  -- send current value
            total = tasks[taskId].total  -- send total
        })

        -- Check if all tasks are completed
        if completedTasks >= totalTasks then
            SendNUIMessage({ action = 'finishTasks' })
            closeUI()
        end
    else
        print("Task with ID " .. taskId .. " does not exist.")
    end
end

RegisterNetEvent('yoda-clipboard:useClipboard')
AddEventHandler('yoda-clipboard:useClipboard', function()
    -- Trigger the event to open the clipboard UI. Adjust this to your needs.
    TriggerEvent('yoda-clipboard:createTasks', tasks, #tasks)
end)

-- Command to open the clipboard using the existing task info
RegisterCommand('clipboard', function()
    TriggerEvent('yoda-clipboard:createTasks', tasks, (#tasks or 0))
end)

-- Export function to create tasks (allows setting tasks via exports)
exports('createTasks', function(taskList, total)
    TriggerEvent('yoda-clipboard:createTasks', taskList, total)
end)

-- Export function to update/complete a task
exports('addTaskCompleted', function(taskId, count)
    updateTask(taskId, count)
end)

-- Export function to clear the clipboard
exports('clearClipboard', function()
    tasks = {}
    totalTasks = 0
    completedTasks = 0
    closeUI()
    SendNUIMessage({ action = 'clearUI' })

    if Config.framework == 'qb' then
        TriggerServerEvent('QBCore:Server:RemoveItem', 'clipboard', 1)
    else
        TriggerServerEvent('esx:removeInventoryItem', 'clipboard', 1)
    end
end)

-- Disable ESC and close the UI
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if uiOpen then
            -- Ensure the animation is active
            ensureClipboardAnim()
            
            -- Disable ESC and Map (P)
            DisableControlAction(0, 322, true) -- ESC
            DisableControlAction(0, 200, true) -- Map (key 'P')
            if IsDisabledControlJustReleased(0, 322) or IsDisabledControlJustReleased(0, 200) then
                closeUI()
            end
        end
    end
end)
