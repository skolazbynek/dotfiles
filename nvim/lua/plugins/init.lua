M = {
	{"nvim-telescope/telescope.nvim",},
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			theme = dragon,
		},
		config = function()
			vim.cmd.colorscheme("kanagawa")
		end,
	},
}

return M
