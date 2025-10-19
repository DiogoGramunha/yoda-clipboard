local tasks = {}
local totalTasks = 0
local completedTasks = 0
local uiOpen = false -- Variável para controlar se o UI está aberto
local clipboardProp = nil -- Variável para armazenar o prop do clipboard

local function startClipboardAnim()
    local ped = PlayerPedId()
    local dict = "amb@world_human_clipboard@male@base"
    local propModel = "p_amb_clipboard_01" -- Modelo do clipboard

    -- Requisita o modelo do prop
    RequestModel(propModel)
    while not HasModelLoaded(propModel) do
        Wait(0)
    end

    -- Cria o prop e o anexa à mão direita do personagem
    if clipboardProp == nil then
        clipboardProp = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, false)
        AttachEntityToEntity(
            clipboardProp, 
            ped, 
            GetPedBoneIndex(ped, 60309), -- Índice do osso (mão direita)
            0.01, -0.01, 0.0, -- Ajuste fino de posição (x, y, z)
            0.0, -15.0, 0.0, -- Rotação (faz o clipboard ficar horizontal e virado para a esquerda)
            true, true, false, true, 1, true
        )
    end

    -- Requisita o dicionário de animação e inicia a animação
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
    -- TaskPlayAnim com flag 49 permite andar enquanto anima
    TaskPlayAnim(ped, dict, "base", 8.0, -8.0, -1, 49, 0, false, false, false)
end

-- Função para parar a animação e remover o prop
local function stopClipboardAnim()
    local ped = PlayerPedId()
    ClearPedTasks(ped)

    -- Remove o prop, se existir
    if clipboardProp ~= nil then
        DeleteObject(clipboardProp)
        clipboardProp = nil
    end
end

-- Função para garantir que a animação continue ativa
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

    print("Final tasks: " .. json.encode(tasks))
    print("Total tasks: " .. totalTasks)

    -- Não usamos o NUI focus para permitir movimento; apenas mostramos o UI
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'createTasks',
        tasks = tasks,
        totalTasks = totalTasks,
        completedTasks = completedTasks
    })
    startClipboardAnim()

    TriggerServerEvent('yoda-clipboard:GiveClipboard', true)
end)

-- Função para fechar o UI
function closeUI()
    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeUI' })
    stopClipboardAnim()
end

-- Função para fechar o UI via NUI callback
RegisterNUICallback('closeUI', function()
    closeUI()
end)

-- Função para atualizar uma tarefa
local function updateTask(taskId, count)
    -- Verifica se a task existe antes de tentar atualizar
    if tasks[taskId] then
        -- Atualiza a quantidade completada da task
        tasks[taskId].current = tasks[taskId].current + count

        -- Verifica se a task foi completada
        if tasks[taskId].current >= tasks[taskId].total then
            -- Marcar como completada
            completedTasks = completedTasks + 1
            SendNUIMessage({
                action = 'completeTask',  -- Ação para marcar como completada no UI
                taskId = taskId
            })
        end

        -- Envia a atualização do contador da task para o UI
        SendNUIMessage({
            action = 'updateTask',
            taskId = taskId,
            current = tasks[taskId].current,  -- envia o valor atual
            total = tasks[taskId].total  -- envia o total
        })

        -- Verifica se todas as tarefas foram completadas
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
    -- Apenas abrir o UI com as tarefas existentes, sem dar o item novamente
    if #tasks > 0 then
        uiOpen = true
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = 'createTasks',
            tasks = tasks,
            totalTasks = totalTasks,
            completedTasks = completedTasks
        })
        startClipboardAnim()
    else
        -- Se não há tarefas, mostrar mensagem
        print("No tasks available")
    end
end)

-- Comando para abrir o clipboard utilizando as informações existentes em tasks
RegisterCommand('clipboard', function()
    if #tasks > 0 then
        uiOpen = true
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = 'createTasks',
            tasks = tasks,
            totalTasks = totalTasks,
            completedTasks = completedTasks
        })
        startClipboardAnim()
    else
        print("No tasks available")
    end
end)

-- Exporta a função para criar tasks (permite definir tasks via exports)
-- Handlers para chamadas vindas do servidor (quando exports forem server-side)
RegisterNetEvent('yoda-clipboard:addTaskCompleted')
AddEventHandler('yoda-clipboard:addTaskCompleted', function(taskId, count)
    updateTask(taskId, count)
end)

RegisterNetEvent('yoda-clipboard:clearClipboard')
AddEventHandler('yoda-clipboard:clearClipboard', function()
    tasks = {}
    totalTasks = 0
    completedTasks = 0
    closeUI()
    SendNUIMessage({ action = 'clearUI' })

    TriggerServerEvent('yoda-clipboard:GiveClipboard', false)
end)

-- Desabilitar o ESC e fechar o UI
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if uiOpen then
            -- Garantir que a animação esteja ativa
            ensureClipboardAnim()
            
            -- Desabilita o ESC e o Mapa (P)
            DisableControlAction(0, 322, true) -- ESC
            DisableControlAction(0, 200, true) -- Mapa (tecla 'P')
            if IsDisabledControlJustReleased(0, 322) or IsDisabledControlJustReleased(0, 200) then
                closeUI()
            end
        end
    end
end)
