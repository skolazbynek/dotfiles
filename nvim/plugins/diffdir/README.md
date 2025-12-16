# diffdir.nvim

A directory diff plugin for Neovim, written in pure Lua.

This plugin allows you to compare two directories side-by-side, view the differences, and perform actions like syncing files, deleting, and diffing individual files.

## ✨ Features

- **Side-by-side directory comparison**: Shows two directory trees in a dual-pane view.
- **Difference Highlighting**: Clearly marks files/directories that are added, removed, or modified.
- **Asynchronous Operations**: Uses background jobs for directory scanning to keep Neovim responsive.
- **File Operations**:
    - Diff individual files.
    - Sync files and directories from one side to the other.
    - Delete files and directories.
- **Customizable**: Configure keymaps, UI elements, and behavior through a `setup` function.

## ડી Dependencies

- **Neovim >= 0.7.0**
- **An external `diff` tool**:
    - On Linux/macOS, this is usually pre-installed.
    - On Windows, you may need to install diff tools (e.g., via Git for Windows).
- **Python**: The plugin now uses a Python script for directory comparison to provide better performance and features like ignoring files. Shell script fallbacks have been removed.

## 📦 Installation

Install with your favorite plugin manager.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    'gogongxt/diffdir',
    name = 'diffdir',
    config = function()
        require('dirdiff').setup({
            -- your custom config here
        })
    end,
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    'gogongxt/diffdir',
    as = 'diffdir',
    config = function()
        require('dirdiff').setup({
            -- your custom config here
        })
    end,
}
```

## 🚀 Usage

### Commands

- `:diffdir <path/to/dir1> <path/to/dir2>`
  Compare two directories directly.

  Example:
  ```vim
  :diffdir /tmp/a /tmp/b
  ```

- `:diffdirmark`
  Mark a directory for comparison. Navigate to another directory (or file) and run it again to start the diff.
  1.  Navigate to the first directory (e.g., using `:e .`).
  2.  Run `:diffdirmark`. A message will confirm the marked path.
  3.  Navigate to the second directory.
  4.  Run `:diffdirmark` again to open the diff view between the marked path and the current path.

### Default Keymaps

These keymaps are active in the DirDiff window.

| Key(s)          | Action                                       |
| --------------- | -------------------------------------------- |
| `<CR>`, `o`     | Open directory or diff a file.               |
| `x`             | Close the current directory node.            |
| `X`             | Close all directory nodes.                   |
| `O`             | Open all directories that contain diffs.     |
| `U`             | Go to the parent directory.                  |
| `q`             | Quit the diff view.                          |
| `DH`, `do`      | Sync the selected item from there to here.   |
| `DL`, `dp`      | Sync the selected item from here to there.   |
| `dd`            | Delete the selected file/directory.          |
| `p`             | Copy the relative path of the node to clipboard. |
| `P`             | Copy the full path of the node to clipboard. |

## ⚙️ Configuration

You can override the default settings by passing a table to the `setup()` function.

Here is an example with the default values:

```lua
require('dirdiff').setup({
  -- Diff logic
  auto_backup = true,
  ignore_empty_dir = true,
  ignore_patterns = { '.git', '.svn', 'node_modules', '__pycache__' },

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

  -- Highlights (links to standard highlight groups)
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
})
