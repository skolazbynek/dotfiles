-- lua/dirdiff/init.lua

local M = {}

local config = require('dirdiff.config')
local ui = require('dirdiff.ui')
local util = require('dirdiff.util')

local mark_path = nil

--- @public
-- Entry point for the plugin
function M.setup(user_config)
  config.merge(user_config)

  vim.api.nvim_create_user_command('Diffdir', function(opts)
    if #opts.fargs < 2 then
      util.error_echo('diffdir requires two directory paths')
      return
    end
    ui.start_diff(opts.fargs[1], opts.fargs[2])
  end, {
    nargs = '+',
    complete = 'dir',
    desc = 'Diff two directories: diffdir <path1> <path2>',
  })

  vim.api.nvim_create_user_command('Diffdirmark', function(opts)
    local path = opts.fargs[0]
    if not path or path == '' then
      path = vim.fn.expand('%:p')
    end
    if not util.is_directory(path) then
      path = vim.fn.fnamemodify(path, ':h')
    end
    if not util.is_directory(path) then
      util.error_echo('Invalid path: ' .. path)
      return
    end

    if not mark_path then
      mark_path = path
      util.info_echo('Marked for diff: ' .. mark_path)
    else
      local path2 = path
      local path1 = mark_path
      mark_path = nil

      if path1 == path2 then
        util.info_echo('Mark cleared.')
        return
      end

      local choice = vim.fn.confirm(('Diff with %s?'):format(path1), '&Yes\n&No', 2)
      if choice == 1 then
        ui.start_diff(path1, path2)
      else
        util.info_echo('Diff canceled.')
      end
    end
  end, {
    nargs = '?',
    complete = 'dir',
    desc = 'Mark a directory to diff with the next marked one',
  })
end

return M
