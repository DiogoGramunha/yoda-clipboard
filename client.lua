local tasks = {}
local totalTasks = 0
local completedTasks = 0

-- Evento para criar as tasks dinamicamente
RegisterNetEvent('yoda-prancheta:createTasks')
AddEventHandler('yoda-prancheta:createTasks', function(taskList, total)
    tasks = taskList
    totalTasks = total
    completedTasks = 0
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'createTasks',
        tasks = taskList,
        totalTasks = totalTasks,
        completedTasks = completedTasks
    })
end)

-- Função para atualizar uma tarefa
local function updateTask(taskId, count)
    completedTasks = completedTasks + count
    SendNUIMessage({
        action = 'updateTask',
        taskId = taskId,
        current = count, -- envia o valor atual para atualizar o contador
        total = tasks[taskId] and tasks[taskId].total or 1
    })
    if completedTasks >= totalTasks then
         SendNUIMessage({ action = 'finishTasks' })
         SetNuiFocus(false, false)
    end
end

-- Exporta a função para criar tasks
exports('createTasks', function(taskList, total)
    TriggerEvent('yoda-prancheta:createTasks', taskList, total)
end)

-- Exporta a função para atualizar/concluir uma task
exports('addTaskCompleted', function(taskId, count)
    updateTask(taskId, count)
end)
