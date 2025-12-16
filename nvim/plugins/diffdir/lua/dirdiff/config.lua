-- lua/dirdiff/config.lua

local M = {}

M.options = {
  -- Diff logic
  auto_backup = true,
  ignore_empty_dir = true,
  ignore_patterns = { '.git', '.svn', 'node_modules', '__pycache__' },
  -- For now, ignore_space is not supported as it depends on the external diff tool
  -- ignore_space = false,

  -- UI settings
  reuse_tab = false,
  auto_open_single_child_dir = true,
  show_same_dir = true,
  show_same_file = true,
  tabstop = 2,

  -- Keymaps (inside diff window)
  keymaps = {
    update = {},
    update_parent = { 'DD' },
    open = { '<CR>', 'o' },
    fold_open_all = {},
    fold_open_all_diff = { 'O' },
    fold_close = { 'x' },
    fold_close_all = { 'X' },
    go_parent = { 'U' },
    diff_this_dir = { 'cd' },
    diff_parent_dir = { 'u' },
    mark_to_diff = { 'DM' },
    mark_to_sync = { 'DN' },
    quit = { 'q' },
    diff_next = { ']c', 'DJ' },
    diff_prev = { '[c', 'DK' },
    diff_next_file = { 'Dj' },
    diff_prev_file = { 'Dk' },
    sync_to_here = { 'do', 'DH' },
    sync_to_there = { 'dp', 'DL' },
    add = { 'a' },
    delete = { 'dd' },
    rename = { 'cc' },
    get_path = { 'p' },
    get_full_path = { 'P' },
  },

  -- Keymap for file diff window
  file_diff_keymaps = {
    quit = { 'q' },
  },

  -- UI Characters
  ui_chars = {
    dir_prefix_closed = '+ ',
    dir_prefix_opened = '~ ',
    dir_postfix = '/',
    file_prefix = '  ',
    file_postfix = '',
  },

  -- Highlights
  highlights = {
    Header = 'Title',
    Tail = 'Title',
    DirChecking = 'SpecialKey',
    DirSame = 'Folded',
    DirDiff = 'DiffAdd',
    FileChecking = 'SpecialKey',
    FileSame = 'Folded',
    FileDiff = 'DiffText',
    DirOnlyHere = 'DiffAdd',
    FileOnlyHere = 'DiffAdd',
    ConflictDirHere = 'ErrorMsg',
    ConflictDirThere = 'WarningMsg',
    MarkToDiff = 'Cursor',
    MarkToSync = 'Cursor',
  },
}

--- @param user_config table
function M.merge(user_config)
  if user_config and type(user_config) == 'table' then
    M.options = vim.tbl_deep_extend('force', M.options, user_config)
  end
end

return M
