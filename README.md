# Yoda Clipboard 🚀  
A simple and customizable task management system for FiveM with a sleek NUI interface.

![yoda-clipboard](https://github.com/user-attachments/assets/clipboard-placeholder.png)

## 🔧 Exports: `createTasks`, `addTaskCompleted` & `clearClipboard`  
This resource provides export functions, allowing other resources to create tasks, update task progress, and clear tasks while managing the **clipboard** item via ox_inventory seamlessly.

### 📌 Example Usage:
```lua
local exampleTasks = {
  { id = 1, label = "Go to the pickup location" },
  { id = 2, label = "Collect 5 boxes", current = 0, total = 5 },
  { id = 3, label = "Deliver the 5 items", current = 0, total = 5 },
  { id = 4, label = "Return the van" }
}

-- Create tasks and add the clipboard item
exports['yoda-clipboard']:createTasks(exampleTasks, #exampleTasks)

-- Update task progress as needed:
exports['yoda-clipboard']:addTaskCompleted(1, 1)
exports['yoda-clipboard']:addTaskCompleted(2, 1)

-- Clear tasks and remove the clipboard item:
exports['yoda-clipboard']:clearClipboard()
