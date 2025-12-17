M = {
	{
		"nvim-telescope/telescope.nvim",
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
			{ "<leader>fl", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
		},
	},
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
