-- lua/dirdiff/state.lua
-- Manages the core state of the diff task (taskData)

local M = {}
local util = require('dirdiff.util')
local backend = require('dirdiff.backend')

-- Node type constants, mirroring the original plugin
M.types = {
  DIR = 'DD', -- both dir
  FILE = 'FF', -- both file
  DIR_LEFT = 'D-', -- left is dir, right not exist
  DIR_RIGHT = '-D', -- right is dir, left not exist
  FILE_LEFT = 'F-', -- left is file, right not exist
  FILE_RIGHT = '-F', -- right is file, left not exist
  CONFLICT_DIR_LEFT = 'DF', -- left is dir, right is file
  CONFLICT_DIR_RIGHT = 'FD', -- left is file, right is dir
}

--- Creates and initializes a new diff task
--- @param pathL string Left directory path
--- @param pathR string Right directory path
--- @param on_update function Callback to run when data changes
--- @return table task_data
function M.create_task(pathL, pathR, on_update)
  local task_data = {
    -- Core paths
    fileL = util.normalize_path(pathL),
    fileR = util.normalize_path(pathR),
    pathL = util.absolute_path(pathL),
    pathR = util.absolute_path(pathR),

    -- Diff state
    diff = -1, -- -1: checking, 0: same, 1: different
    parent = {}, -- Root node has no parent
    child = {}, -- List of diff_node children

    -- UI state
    linesL = {},
    linesR = {},
    child_visible = {}, -- Maps buffer line to diff_node
    header_len = 0,
    tail_len = 0,
    cursor_line = 0, -- Recommended cursor line to restore

    -- Callbacks and options
    on_update = on_update,

    -- State for restoring view
    open_state = {}, -- Paths of nodes that should be open
    cursor_state = '', -- Path of node under cursor

    -- Backend process handle
    job_id = nil,
    job_buffer = '',

    -- Debug info
    debug = {
      update_start_time = 0,
      update_cost_time = -1,
    },
  }

  -- Link the backend for processing
  task_data.backend_update = function()
    backend.update(task_data)
  end

  return task_data
end

--- Cleans up a task, stopping any running jobs
--- @param task_data table
function M.cleanup_task(task_data)
  if task_data and task_data.job_id then
    backend.cleanup(task_data)
  end
end

--- Checks if a node can be opened (is a directory type)
--- @param diff_node table
--- @return boolean
function M.node_can_open(diff_node)
  if not diff_node or not diff_node.type then return false end
  local t = diff_node.type
  return t == M.types.DIR
    or t == M.types.DIR_LEFT
    or t == M.types.DIR_RIGHT
    or t == M.types.CONFLICT_DIR_LEFT
end

--- Checks if a node can be diffed (is a file type)
--- @param diff_node table
--- @return boolean
function M.node_can_diff(diff_node)
  if not diff_node or not diff_node.type then return false end
  local t = diff_node.type
  return t == M.types.FILE
    or t == M.types.FILE_LEFT
    or t == M.types.FILE_RIGHT
    or t == M.types.CONFLICT_DIR_RIGHT
end

return M
