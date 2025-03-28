window.addEventListener('message', function(event) {
  const data = event.data;
  if (data.action === 'createTasks') {
    createTaskUI(data.tasks);
  } else if (data.action === 'updateTask') {
    updateTaskUI(data.taskId, data.current, data.total);
  } else if (data.action === 'finishTasks') {
    finishTaskUI();
  } else if (data.action === 'closeUI' || data.action === 'clearUI') {
    closeUI();
  }
});

function createTaskUI(tasks) {
  // Exibe o UI definindo o body para display: flex
  document.body.style.display = "flex";

  const sheet = document.querySelector('.sheet');
  let html = '<h2 class="title">Checklist</h2>';
  if (!tasks || tasks.length === 0) {
    html += '<div class="finished">Nenhuma tarefa disponível</div>';
  } else {
    tasks.forEach(task => {
      html += `<div id="task-${task.id}" class="task">`;
      html += `<span class="label">${task.label}</span>`;
      if (task.total) {
        html += `<span id="counter-${task.id}" class="counter">${task.current || 0}/${task.total}</span>`;
      }
      html += `</div>`;
    });
  }
  sheet.innerHTML = html;
}

function updateTaskUI(taskId, current, total) {
  const taskElem = document.getElementById(`task-${taskId}`);
  const counterElem = document.getElementById(`counter-${taskId}`);

  if (counterElem) {
      counterElem.innerText = `${current}/${total}`;
      if (current >= total) {
          completeTask(taskId);
      }
  } else {
      completeTask(taskId);
  }
}

function completeTask(taskId) {
  const taskElem = document.getElementById(`task-${taskId}`);
  if (taskElem && !taskElem.classList.contains('completed')) {
      taskElem.classList.add('completed');
      taskElem.style.textDecoration = 'line-through';  // Risca a task completada
  }
}

function finishTaskUI() {
  const finishedElem = document.querySelector('.finished');
  if (finishedElem) {
    finishedElem.style.display = 'block';
  }
}

function closeUI() {
  // Esconde o UI definindo o body para display: none
  document.body.style.display = "none";
  
  // Reseta o conteúdo da sheet para o estado padrão
  const sheet = document.querySelector('.sheet');
  sheet.innerHTML = '<h2>Checklist</h2><div class="finished">Nenhuma tarefa disponível</div>';
}

// Captura o pressionamento da tecla Esc para fechar o UI
document.addEventListener('keydown', function(e) {
  if (e.keyCode === 27) { // 27 é o código da tecla Esc
    // Envia o callback para o client e fecha o UI
    closeUI();
    fetch(`https://${GetParentResourceName()}/closeUI`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8'},
      body: JSON.stringify({})
    });
  }
});
