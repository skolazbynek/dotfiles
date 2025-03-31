local M = {
	{
		"https://github.com/ggandor/leap.nvim",
		config = function()
			require('leap').create_default_mappings()
		end
	},
	{
		"https://github.com/ggandor/flit.nvim",
		dependencies = { "https://github.com/ggandor/leap.nvim" },
		opts = {}
	}
}

return M
