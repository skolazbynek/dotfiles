-- lua/dirdiff/ui.lua
-- Handles all UI aspects: windows, buffers, keymaps, and rendering.

local M = {}

local api = vim.api
local config = require('dirdiff.config')
local util = require('dirdiff.util')
local state = require('dirdiff.state')
local op = require('dirdiff.op')

local current_task = nil

--------------------------------------------------------------------------------
-- UI Rendering
--------------------------------------------------------------------------------

local function get_line_content(task_data, diff_node, depth, is_left)
  local conf = config.options.ui_chars
  local indent = string.rep(' ', depth * config.options.tabstop)
  local prefix, postfix, name
  local node_type = diff_node.type

  if node_type == state.types.DIR_RIGHT or node_type == state.types.FILE_RIGHT then
    if is_left then return '' end
  elseif node_type == state.types.DIR_LEFT or node_type == state.types.FILE_LEFT then
    if not is_left then return '' end
  end

  name = diff_node.name
  if state.node_can_open(diff_node) then
    prefix = diff_node.open and conf.dir_prefix_opened or conf.dir_prefix_closed
    postfix = conf.dir_postfix
  else
    prefix = conf.file_prefix
    postfix = conf.file_postfix
  end

  return indent .. prefix .. name .. postfix
end

local function render_node_recursively(task_data, diff_node, depth)
  if (diff_node.type == state.types.DIR or diff_node.type == state.types.FILE) then
    if diff_node.diff == 0 then
      if state.node_can_open(diff_node) and not config.options.show_same_dir then return end
      if not state.node_can_open(diff_node) and not config.options.show_same_file then return end
    end
  end

  table.insert(task_data.linesL, get_line_content(task_data, diff_node, depth, true))
  table.insert(task_data.linesR, get_line_content(task_data, diff_node, depth, false))
  table.insert(task_data.child_visible, diff_node)

  if diff_node.open then
    for _, child in ipairs(diff_node.child) do
      render_node_recursively(task_data, child, depth + 1)
    end
  end
end

local function redraw_buffers()
  if not current_task then return end

  -- Reset lines
  current_task.linesL = {}
  current_task.linesR = {}
  current_task.child_visible = {}

  -- Header
  -- TODO: Add header content

  -- Body
  for _, node in ipairs(current_task.child) do
    render_node_recursively(current_task, node, 0)
  end

  -- Tail
  -- TODO: Add tail content

  -- Apply to buffers
  local bufnrL = current_task.bufnrL
  local bufnrR = current_task.bufnrR

  api.nvim_buf_set_option(bufnrL, 'modifiable', true)
  api.nvim_buf_set_option(bufnrR, 'modifiable', true)

  api.nvim_buf_set_lines(bufnrL, 0, -1, false, current_task.linesL)
  api.nvim_buf_set_lines(bufnrR, 0, -1, false, current_task.linesR)

  api.nvim_buf_set_option(bufnrL, 'modifiable', false)
  api.nvim_buf_set_option(bufnrR, 'modifiable', false)

  -- TODO: Set highlights
end

--------------------------------------------------------------------------------
-- Keymaps and Actions
--------------------------------------------------------------------------------

local function get_node_at_cursor(winid)
  winid = winid or api.nvim_get_current_win()
  local bufnr = api.nvim_win_get_buf(winid)
  if not current_task or (bufnr ~= current_task.bufnrL and bufnr ~= current_task.bufnrR) then
    return nil
  end
  local lnum = api.nvim_win_get_cursor(winid)[1]
  return current_task.child_visible[lnum]
end

local actions = {
  open = function()
    local node = get_node_at_cursor()
    if not node then return end

    if state.node_can_open(node) then
      node.open = not node.open
      redraw_buffers()
    elseif state.node_can_diff(node) then
      op.diff_files(current_task, node)
    end
  end,
  quit = function()
    if not current_task then return end
    local owner_tab = current_task.owner_tab
    state.cleanup_task(current_task)
    api.nvim_win_close(current_task.winL, true)
    api.nvim_win_close(current_task.winR, true)
    current_task = nil
    if api.nvim_tabpage_is_valid(owner_tab) then
      api.nvim_set_current_tabpage(owner_tab)
    end
  end,
  -- Add other actions here...
  sync_to_here = function()
    op.sync(current_task, get_node_at_cursor(), true)
  end,
  sync_to_there = function()
    op.sync(current_task, get_node_at_cursor(), false)
  end,
  delete_node = function()
    op.delete(current_task, get_node_at_cursor())
  end,
}

local function setup_keymaps(bufnr)
  local keymaps = config.options.keymaps
  local map = function(keys, rhs)
    for _, key in ipairs(keys) do
      api.nvim_buf_set_keymap(bufnr, 'n', key, rhs, { noremap = true, silent = true })
    end
  end

  map(keymaps.open, '<Cmd>lua require("dirdiff.ui")._actions.open()<CR>')
  map(keymaps.quit, '<Cmd>lua require("dirdiff.ui")._actions.quit()<CR>')
  map(keymaps.sync_to_here, '<Cmd>lua require("dirdiff.ui")._actions.sync_to_here()<CR>')
  map(keymaps.sync_to_there, '<Cmd>lua require("dirdiff.ui")._actions.sync_to_there()<CR>')
  map(keymaps.delete, '<Cmd>lua require("dirdiff.ui")._actions.delete_node()<CR>')
  -- Add other keymaps...
end

--------------------------------------------------------------------------------
-- UI Initialization
--------------------------------------------------------------------------------

local function setup_buffer(bufnr, label)
  api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
  api.nvim_buf_set_option(bufnr, 'bufhidden', 'hide')
  api.nvim_buf_set_option(bufnr, 'swapfile', false)
  api.nvim_buf_set_option(bufnr, 'buflisted', true)
  api.nvim_buf_set_option(bufnr, 'modifiable', false)
  -- api.nvim_buf_set_option(bufnr, 'nowrap', true)
  -- api.nvim_set_var('DirDiff_bufnr', bufnr, { scope = 'b' })
  vim.fn.setbufvar(bufnr, '&filetype', 'DirDiff')
  api.nvim_buf_set_name(bufnr, '[DirDiff] ' .. label)
  setup_keymaps(bufnr)
end

--- @public
-- Starts the directory diff process
function M.start_diff(pathL, pathR)
  if not util.is_directory(pathL) or not util.is_directory(pathR) then
    op.diff_files(nil, nil, pathL, pathR)
    return
  end

  if current_task then
    actions.quit()
  end

  local owner_tab = api.nvim_get_current_tabpage()
  api.nvim_command('tabnew')

  -- Create windows and buffers
  api.nvim_command('vsplit')
  local winL = api.nvim_get_current_win()
  local bufnrL = api.nvim_create_buf(true, false)
  api.nvim_win_set_buf(winL, bufnrL)

  api.nvim_command('wincmd l')
  local winR = api.nvim_get_current_win()
  local bufnrR = api.nvim_create_buf(true, false)
  api.nvim_win_set_buf(winR, bufnrR)

  -- Setup buffers
  setup_buffer(bufnrL, pathL)
  setup_buffer(bufnrR, pathR)

  -- Link windows
  api.nvim_win_set_option(winL, 'scrollbind', true)
  api.nvim_win_set_option(winR, 'scrollbind', true)
  api.nvim_win_set_option(winL, 'cursorbind', true)
  api.nvim_win_set_option(winR, 'cursorbind', true)

  -- Create and start the task
  current_task = state.create_task(pathL, pathR, redraw_buffers)
  current_task.winL = winL
  current_task.winR = winR
  current_task.bufnrL = bufnrL
  current_task.bufnrR = bufnrR
  current_task.owner_tab = owner_tab

  -- Initial update
  current_task.backend_update()
end

M._actions = actions -- Expose for keymaps

return M
