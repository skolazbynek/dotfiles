local M = {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local configs = require("nvim-treesitter.configs")

			configs.setup({
				ensure_installed = { "lua", "python", "json", "graphql", "markdown", "markdown_inline", "html"},
				sync_install = false,
				auto_install = true,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = true,
				},
				indent = {
					enable = true,
				},
				incremental_selection = {
					enable = true,
					keymaps = {
				init_selection = "<leader>ss",
				node_incremental = "<C-s>",
				scope_incremental = "<C-S>",
				node_decremental = "<C-b>",
					}
				},
			})
		end
	}
}
return M
