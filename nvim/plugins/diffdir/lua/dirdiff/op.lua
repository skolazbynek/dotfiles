-- lua/dirdiff/op.lua
-- Handles file system operations like sync, delete, and diff.

local M = {}

local api = vim.api
local util = require('dirdiff.util')
local config = require('dirdiff.config')

--- Diff two files in a new tab
--- @param task_data table | nil The main task data, or nil if called directly
--- @param diff_node table | nil The node being diffed
--- @param pathL string | nil Explicit left path
--- @param pathR string | nil Explicit right path
function M.diff_files(task_data, diff_node, pathL, pathR)
  pathL = pathL or util.get_full_node_path(task_data, diff_node, true)
  pathR = pathR or util.get_full_node_path(task_data, diff_node, false)

  api.nvim_command('tabnew')
  api.nvim_command('edit ' .. vim.fn.fnameescape(pathL))
  api.nvim_command('diffthis')
  api.nvim_command('vsplit ' .. vim.fn.fnameescape(pathR))
  api.nvim_command('diffthis')

  -- Simple quit mapping
  local quit_keys = config.options.file_diff_keymaps.quit
  for _, key in ipairs(quit_keys) do
    api.nvim_buf_set_keymap(0, 'n', key, ':q!<CR>', { noremap = true, silent = true })
  end
end

local function confirm_operation(prompt)
    local choice = vim.fn.confirm(prompt, '&Yes\n&No', 2)
    return choice == 1
end

--- Sync a node from one side to the other
--- @param task_data table
--- @param diff_node table
--- @param to_here boolean If true, sync from other side to current side
function M.sync(task_data, diff_node, to_here)
    if not diff_node then
        util.error_echo("No node under cursor.")
        return
    end

    local current_win = api.nvim_get_current_win()
    local is_left_win = (current_win == task_data.winL)

    local from_path, to_path
    if (is_left_win and to_here) or (not is_left_win and not to_here) then
        -- Sync from Right to Left
        from_path = util.get_full_node_path(task_data, diff_node, false)
        to_path = util.get_full_node_path(task_data, diff_node, true)
    else
        -- Sync from Left to Right
        from_path = util.get_full_node_path(task_data, diff_node, true)
        to_path = util.get_full_node_path(task_data, diff_node, false)
    end

    if not confirm_operation(('Sync %s to %s?'):format(from_path, to_path)) then
        util.info_echo("Sync canceled.")
        return
    end

    -- Simple copy for now. The original had more complex logic for different node types.
    local cmd = vim.fn.has('win32') == 1 and 'xcopy /E /I /Y' or 'cp -r'
    local status = vim.fn.system(('%s "%s" "%s"'):format(cmd, from_path, to_path))

    if vim.v.shell_error == 0 then
        util.info_echo("Synced successfully.")
        task_data.backend_update() -- Refresh state
    else
        util.error_echo("Sync failed: " .. status)
    end
end

--- Delete a node
--- @param task_data table
--- @param diff_node table
function M.delete(task_data, diff_node)
    if not diff_node then
        util.error_echo("No node under cursor.")
        return
    end

    local current_win = api.nvim_get_current_win()
    local is_left_win = (current_win == task_data.winL)
    local path_to_delete = util.get_full_node_path(task_data, diff_node, is_left_win)

    if not confirm_operation(('Delete %s?'):format(path_to_delete)) then
        util.info_echo("Delete canceled.")
        return
    end

    local cmd = vim.fn.has('win32') == 1 and 'rmdir /s /q' or 'rm -rf'
    local status = vim.fn.system(('%s "%s"'):format(cmd, path_to_delete))

    if vim.v.shell_error == 0 then
        util.info_echo("Deleted successfully.")
        task_data.backend_update() -- Refresh state
    else
        util.error_echo("Delete failed: " .. status)
    end
end


return M
