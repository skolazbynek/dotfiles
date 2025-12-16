-- lua/dirdiff/backend.lua
-- Handles async diffing via external scripts

local M = {}

local util = require('dirdiff.util')

local function get_script_path(script_name)
  -- Find the plugin's runtime path to locate the 'misc' directory.
  -- This is a robust way to ensure scripts are found regardless of the plugin manager.
  local rtp_files = vim.api.nvim_get_runtime_file('lua/dirdiff/init.lua', false)
  if #rtp_files == 0 then
    util.error_echo("Could not determine plugin runtime path.")
    return nil
  end
  -- The path to init.lua -> get the plugin root -> append misc/script_name
  local plugin_root = vim.fn.fnamemodify(rtp_files[1], ':h:h:h')
  return util.normalize_path(plugin_root .. '/misc/' .. script_name)
end

local function parse_diff_output(task_data, output)
  -- This function will parse the output from the python/shell script
  -- and update the task_data.child table.
  -- The logic here will be complex and needs to replicate the parsing
  -- logic from the original Vimscript.

  -- For now, we'll just log the output.
  -- print("Received from job: " .. output)

  -- Placeholder for parsing logic
  local lines = vim.split(output, '\n')
  local new_children = {}
  local node_map = {} -- for quick parent lookup

  for _, line in ipairs(lines) do
    -- Expected format: "diff_status type /path/to/node"
    -- e.g., "0 DD /" for the root
    -- e.g., "1 FF /file.txt"
    local parts = vim.split(line, ' ', { plain = true, trim = true })
    if #parts >= 3 then
      local diff_status, node_type, node_path = parts[1], parts[2], table.concat(parts, ' ', 3)
      local name = vim.fn.fnamemodify(node_path, ':t')
      local parent_path = vim.fn.fnamemodify(node_path, ':h')

      local diff_node = {
        name = name,
        type = node_type,
        diff = tonumber(diff_status) or -1,
        open = false,
        child = {},
        parent = nil, -- To be linked
      }

      node_map[node_path] = diff_node

      if parent_path == '.' or parent_path == '/' then
        diff_node.parent = task_data
        table.insert(new_children, diff_node)
      else
        local parent_node = node_map[parent_path]
        if parent_node then
          diff_node.parent = parent_node
          table.insert(parent_node.child, diff_node)
        else
          -- Should not happen with sorted input
          diff_node.parent = task_data
          table.insert(new_children, diff_node)
        end
      end
    end
  end

  -- Sort children alphabetically
  table.sort(new_children, function(a, b) return a.name < b.name end)
  task_data.child = new_children
  task_data.diff = task_data.child and #task_data.child > 0 and 1 or 0 -- Simplified diff status

  -- Call the update callback to refresh the UI
  task_data.on_update()
end

--- @param task_data table
function M.update(task_data)
  if task_data.job_id then
    util.info_echo('Diff is already in progress.')
    return
  end

  task_data.debug.update_start_time = vim.fn.localtime()
  task_data.debug.update_cost_time = -1
  task_data.diff = -1 -- Mark as checking

  local cmd
  local api_impl_path = get_script_path('apiImpl.py')
  local config = require('dirdiff.config').options

  if vim.fn.executable('python') == 1 and vim.fn.filereadable(api_impl_path) == 1 then
    local ignore_list = table.concat(config.ignore_patterns, ',')
    cmd = { 'python', api_impl_path, task_data.pathL, task_data.pathR, ignore_list }
  else
    util.error_echo('Python is required for diffing. Please install Python or check your path.')
    task_data.diff = 1 -- Mark as different on error
    task_data.on_update()
    return
  end

  task_data.job_buffer = ''
  task_data.job_id = vim.fn.jobstart(cmd, {
    on_stdout = function(_, data)
      if data then
        task_data.job_buffer = task_data.job_buffer .. table.concat(data, '\n')
      end
    end,
    on_stderr = function(_, data)
      if data then
        util.error_echo('Diff job error: ' .. table.concat(data, '\n'))
      end
    end,
    on_exit = function(_, code)
      task_data.job_id = nil
      if code == 0 then
        parse_diff_output(task_data, task_data.job_buffer)
      else
        util.error_echo('Diff job failed with code: ' .. code)
        task_data.diff = 1 -- Mark as different on error
      end
      task_data.debug.update_cost_time = vim.fn.localtime() - task_data.debug.update_start_time
      task_data.on_update()
    end,
    stdout_buffered = true,
  })

  if not task_data.job_id or task_data.job_id == 0 or task_data.job_id == -1 then
    util.error_echo('Failed to start diff job.')
    task_data.job_id = nil
  end
end

--- @param task_data table
function M.cleanup(task_data)
  if task_data.job_id then
    vim.fn.jobstop(task_data.job_id)
    task_data.job_id = nil
  end
end

return M
