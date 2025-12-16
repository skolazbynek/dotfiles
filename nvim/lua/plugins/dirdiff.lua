local M = {
	{
		dir = '/home/zet/projects/dotfiles/nvim/plugins/diffdir',
		name = 'diffdir',
		dev = true,
		config = function()
			require('dirdiff').setup({
				-- your custom config here
			})
		end,
	}
}

return M
