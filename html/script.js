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
  // Show the UI by setting the body to display: flex
  document.body.style.display = "flex";

  const sheet = document.querySelector('.sheet');
  let html = '<h2 class="title">Checklist</h2>';
  if (!tasks || tasks.length === 0) {
    html += '<div class="finished">No tasks available</div>';
  } else {
    tasks.forEach(task => {
      // Check if the task is completed
      let completedClass = (task.current >= task.total) ? ' completed' : '';
      html += `<div id="task-${task.id}" class="task${completedClass}">`;
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
    taskElem.style.textDecoration = 'line-through';  // Strike through the completed task
  }
}

function finishTaskUI() {
  const finishedElem = document.querySelector('.finished');
  if (finishedElem) {
    finishedElem.style.display = 'block';
  }
}

function closeUI() {
  // Hide the UI by setting the body to display: none
  document.body.style.display = "none";
  
  // Reset the sheet content to its default state
  const sheet = document.querySelector('.sheet');
  sheet.innerHTML = '<h2>Checklist</h2><div class="finished">No tasks available</div>';
}

// Capture Esc key press to close the UI
document.addEventListener('keydown', function(e) {
  if (e.keyCode === 27) { // 27 is the Esc key code
    // Send the callback to the client and close the UI
    closeUI();
    fetch(`https://${GetParentResourceName()}/closeUI`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8'},
      body: JSON.stringify({})
    });
  }
});
