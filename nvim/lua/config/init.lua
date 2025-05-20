vim.opt.hidden = true
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.scrolloff = 8
vim.opt.number = true
vim.opt.relativenumber = true
-- folding with treesitter
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldminlines = 5
vim.opt.foldenable = false

-- start_with_open_folds_group = vim.api.nvim_create_augroup("DefaultOpenFolds", {})
-- vim.api.nvim_create_autocmd({'BufReadPost','FileReadPost'}, {group=start_with_open_folds_group, command='normal zR'})

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

-- Command to switch the background on / off
local background_switch = function()
	hl_group = vim.api.nvim_get_hl(0, {name="Normal", create=false})
	if hl_group.bg then
		vim.cmd.highlight('Normal guibg=None')
		vim.cmd.highlight('LineNr guibg=None')

	else
		vim.cmd.colorscheme('kanagawa')
	end
end;
vim.api.nvim_create_user_command('BGChange', background_switch, {})

-- Export locals to be used in main __init__
return { background_switch = background_switch }
