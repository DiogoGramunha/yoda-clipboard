// Recebe mensagens do client.lua
window.addEventListener('message', function(event) {
  const data = event.data;
  if (data.action === 'createTasks') {
    createTaskUI(data.tasks);
  } else if (data.action === 'updateTask') {
    updateTaskUI(data.taskId, data.current, data.total);
  } else if (data.action === 'finishTasks') {
    finishTaskUI();
  }
});

// Função que cria a UI de tasks dinamicamente
function createTaskUI(tasks) {
  const sheet = document.querySelector('.sheet');
  let html = '<h2>Checklist</h2>';
  tasks.forEach(task => {
    html += `<div id="task-${task.id}" class="task">`;
    html += `<span class="label">${task.label}</span>`;
    // Se a task possuir propriedades de contagem, exibe o contador
    if(task.total) {
      html += `<span id="counter-${task.id}" class="counter">${task.current || 0}/${task.total}</span>`;
    }
    html += `</div>`;
  });
  html += '<div class="finished">Todas as tarefas concluídas!</div>';
  sheet.innerHTML = html;
}

// Função para atualizar task sem contador (usada para tasks sem repetição)
function updateTaskUI(taskId, current, total) {
  // Se for task com contador, atualiza-o
  const counterElem = document.getElementById(`counter-${taskId}`);
  if(counterElem){
    counterElem.innerText = `${current}/${total}`;
    if(current >= total) {
      completeTask(taskId);
    }
  } else {
    completeTask(taskId);
  }
}

// Marca a task como concluída (adiciona classe 'completed')
function completeTask(taskId) {
  const taskElem = document.getElementById(`task-${taskId}`);
  if (taskElem && !taskElem.classList.contains('completed')) {
    taskElem.classList.add('completed');
  }
}

// Exibe a mensagem de conclusão
function finishTaskUI() {
  const finishedElem = document.querySelector('.finished');
  if(finishedElem) {
    finishedElem.style.display = 'block';
  }
}

// Simulação para testes locais (remova em produção)
// Exemplo de criação dinâmica de tasks:
if(document.location.href.indexOf("http") === 0) {
  // Simula o envio do evento 'createTasks' com uma lista de tasks
  const tasks = [
    { id: 1, label: "Verificar veículo" },
    { id: 2, label: "Coletar encomenda" },
    { id: 3, label: "Apanhar caixas", current: 0, total: 5 }
  ];
  createTaskUI(tasks);

  // Simula a conclusão das tasks:
  setTimeout(() => {
    completeTask(1);
  }, 1000);

  setTimeout(() => {
    completeTask(2);
  }, 2000);

  let currentCount = 0;
  const totalCount = 5;
  const interval = setInterval(() => {
    currentCount++;
    updateTaskUI(3, currentCount, totalCount);
    if(currentCount >= totalCount) {
      clearInterval(interval);
      finishTaskUI();
    }
  }, 1000);
}
