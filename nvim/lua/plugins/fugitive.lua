M = {
	{
	'tpope/vim-fugitive',
	},
	{
		'shumphrey/fugitive-gitlab.vim',
		dependencies = {	'tpope/vim-fugitive'},
		init = function() 
			vim.g.fugitive_gitlab_domains = {'gitlab.seznam.net'}
		end,
	},
}

return M
