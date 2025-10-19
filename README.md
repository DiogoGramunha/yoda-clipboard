# Yoda Clipboard 🚀  
A simple and customizable task management system for FiveM with a sleek NUI interface.

![yoda-clipboard](https://github.com/user-attachments/assets/clipboard-placeholder.png)

### Config
Set your inventory at config.lua as qb, esx, or ox

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
```

## ✅ Parameters
### For createTasks:
```lua
exports['yoda-clipboard']:createTasks(taskList, total)
```
### For addTaskCompleted:
```lua
exports['yoda-clipboard']:addTaskCompleted(taskId, count)
```
### For clearClipboard:
```lua
exports['yoda-clipboard']:clearClipboard()
```

## ⚙️ ox_inventory Integration
This script automatically adds a clipboard item to the player's inventory when tasks are created and removes it when tasks are cleared.

## 📝 Defining the Clipboard Item in ox_inventory
Add the following to your ox_inventory item list (usually in shared/items.lua):

```lua
['clipboard'] = {
    label = "Clipboard",
    weight = 100,
    stack = true,        -- Allows the item to be stacked
    close = true,        -- Closes the inventory UI when the item is used
    description = "A clipboard used to manage tasks.",
    client = {
        event = "yoda-clipboard:useClipboard", -- Trigger when used
    }
},

```

## 🔌 How It Works
#### Creating Tasks:

 * Displays the UI with a list of tasks.

 * Triggers an animation (showing the clipboard in the player's hand).

 * Adds the clipboard item to the player's inventory via ox_inventory.

### Updating Tasks:

 * Increments the task progress.

 * Marks tasks as completed in the UI once the progress meets or exceeds the total requirement.

### Clearing Tasks:

 * Closes the UI and stops animations.

 * Clears the task list.

 * Removes the clipboard item from the player's inventory via ox_inventory.

## 💡 Final Notes
Easily integrate Yoda Clipboard into your FiveM scripts for a sleek and modern task management experience! 🚀
