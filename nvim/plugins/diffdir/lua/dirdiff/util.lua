-- lua/dirdiff/util.lua

local M = {}

--- Echo a message with info highlighting
--- @param msg string
function M.info_echo(msg)
  vim.cmd('echohl MoreMsg')
  vim.cmd('echom "[DirDiff] ' .. msg .. '"')
  vim.cmd('echohl None')
end

--- Echo a message with error highlighting
--- @param msg string
function M.error_echo(msg)
  vim.cmd('echohl ErrorMsg')
  vim.cmd('echom "[DirDiff] ' .. msg .. '"')
  vim.cmd('echohl None')
end

--- Normalize a path
--- @param path string
--- @return string
function M.normalize_path(path)
  path = path:gsub('[\\/]+', '/')
  path = path:gsub('/+$', '')
  if path == '' then
    return '.'
  end
  return path
end

--- Get the absolute path, fixing for cygwin if necessary
--- @param path string
--- @return string
function M.absolute_path(path)
  local abs_path = vim.fn.fnamemodify(path, ':p')
  if vim.fn.has('win32unix') == 1 and vim.fn.executable('cygpath') == 1 then
    abs_path = vim.fn.substitute(vim.fn.system('cygpath -m "' .. abs_path .. '"'), '[\\r\\n]', '', 'g')
  end
  return M.normalize_path(abs_path)
end

--- Check if a path is a directory
--- @param path string
--- @return boolean
function M.is_directory(path)
  return vim.fn.isdirectory(path) == 1
end

--- Get the parent path of a diff node
--- @param diff_node table
--- @return string
function M.get_parent_path(diff_node)
  local parent_path = '/'
  local current = diff_node.parent
  while current and current.parent do -- Stop when parent is the root taskData
    current.name = current.name or ""
    parent_path = '/' .. current.name .. parent_path
    current = current.parent
  end
  return parent_path
end

--- Get the full path for a node on the left or right side
--- @param task_data table The main task data
--- @param diff_node table The node to get the path for
--- @param is_left boolean True for left side, false for right
--- @return string
function M.get_full_node_path(task_data, diff_node, is_left)
    local base_path = is_left and task_data.pathL or task_data.pathR
    local parent_path = M.get_parent_path(diff_node)
    return base_path .. parent_path .. diff_node.name
end

return M
