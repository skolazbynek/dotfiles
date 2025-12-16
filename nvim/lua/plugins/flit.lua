local M = {
	{
		"ggandor/leap.nvim",
		config = function()
			require('leap').create_default_mappings()
		end
	},
	{
		"ggandor/flit.nvim",
		dependencies = { "ggandor/leap.nvim" },
		opts = {}
	}
}

return M
