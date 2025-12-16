local M = {
	{"onsails/lspkind.nvim"},
	{'hrsh7th/cmp-nvim-lsp'},
	{'hrsh7th/cmp-buffer'},
	{"hrsh7th/cmp-cmdline"},
	{ 'tzachar/fuzzy.nvim' },
	{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release' },
	{
		"tzachar/fuzzy.nvim",
		dependencies = {"nvim-telescope/telescope-fzf-native.nvim"},
	},
	{
		"tzachar/cmp-fuzzy-buffer",
		dependencies = {
			'hrsh7th/nvim-cmp',
			'tzachar/fuzzy.nvim'
		}
	},
	{
		"ray-x/cmp-treesitter",
	},
	{
		'hrsh7th/nvim-cmp',
		dependencies = {
			'hrsh7th/cmp-nvim-lsp',
		},
		config = function()
			local cmp = require('cmp')
			cmp.setup({
				formatting = {
					format = function(entry, vim_item)
						if vim.tbl_contains({ 'path' }, entry.source.name) then
							local icon, hl_group = require('nvim-web-devicons').get_icon(entry:get_completion_item().label)
							if icon then
								vim_item.kind = icon
								vim_item.kind_hl_group = hl_group
								return vim_item
							end
						end
						return require('lspkind').cmp_format({
							mode = "symbol_text",		
							menu = {
								buffer = "[Buffer]",
								nvim_lsp = "[LSP]",
								treesitter = "[Tree]",
								fuzzy_buffer = "[Fuzzy]",
							},

						})(entry, vim_item)
					end
				},
				performance = {
					max_view_entries = 25
				},
				completion = {
					keyword_length = 3
				},
				sorting = {
					priority_weight = 4
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-k>"] = cmp.mapping.select_prev_item(cmp_select),
					["<C-j>"] = cmp.mapping.select_next_item(cmp_select),
					["<CR>"] = cmp.mapping.confirm(),
					["<C-Space>"] = cmp.mapping.complete(),
				}),
				sources = cmp.config.sources({
					{ name = 'nvim_lsp',
						 max_item_count = 20,
					},
					{ name = "treesitter" },
				}, {
					{ name = 'fuzzy_buffer' },
					{ name = 'buffer' },
					-- { name = 'luasnip' },
				}),
			})
			cmp.setup.cmdline(
				{ '/', '?' },
				{
					mapping = cmp.mapping.preset.cmdline(),
					sources = cmp.config.sources({
						-- { name = "buffer" },
						{ name = "fuzzy_buffer" },
					})
				})
			cmp.setup.cmdline({ ':' },
				{
					mapping = cmp.mapping.preset.cmdline(),
					sources = cmp.config.sources({
						{ name = 'path' },
						{ name = 'cmdline' }
					}),
					matching = { disallow_symbol_nonprefix_matching = false }
				})
		end,
	},
}

return M
