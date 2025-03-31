vim.opt.hidden = true
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.scrolloff = 8
vim.opt.number = true
vim.opt.relativenumber = true

-- highlight on yank
vim.cmd([[
	augroup highlight_yank
		autocmd!
		au TextYankPost * silent! lua vim.highlight.on_yank {higroup=(vim.fn['hlexists']('HighlightedyankRegion') > 0 and 'HighlightedyankRegion' or 'IncSearch'), timeout=300}
	augroup END
]])

-- Highlight cursor line only in active window
cursor_line_highlight_group = vim.api.nvim_create_augroup("LineHighlight", {})
vim.api.nvim_create_autocmd({'VimEnter','WinEnter','BufWinEnter'}, {
	group = cursor_line_highlight_group,
	command = "setlocal cursorline"
})
vim.api.nvim_create_autocmd({"WinLeave", "BufLeave"}, {
	group = cursor_line_highlight_group,
	command = "setlocal nocursorline"
})


