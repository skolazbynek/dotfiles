local M = {
	{
		'williamboman/mason.nvim',
		opts = {
			pip = {
				upgrade_pip = false
			}
		}
	},
	{
		'williamboman/mason-lspconfig.nvim',
		dependencies = {
			'williamboman/mason.nvim',
		},
		opts = {
			automatic_enable = false,
			ensure_installed = {
				'lua_ls', 'gopls', 'basedpyright', 'pylsp', 'marksman'
			}
		}
	},

	{
		'neovim/nvim-lspconfig',
		dependencies = {
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',
			'hrsh7th/cmp-nvim-lsp'
		},
		config = function()
			local capabilities = require('cmp_nvim_lsp').default_capabilities()
			local lspconfig = require('lspconfig')
			lspconfig.marksman.setup{}
			lspconfig.gopls.setup{}
			vim.lsp.config('basedpyright', {
				capabilities = capabilities,
				settings = {
					basedpyright = {
						analysis = {
							typeCheckingMode = "off"
						}
					}
				},
			})
			vim.lsp.enable('basedpyright')
			vim.lsp.config('pylsp', {
				settings = {
					pylsp = {
						configurationSources = {
							'flake8'
						},
						plugins = {
							pycodestyle = {
								enabled = false
							},
							pyflakes = {
								enabled = false
							},
							mccabe = {
								enabled = false
							},
							flake8 = {
								enabled = true
							},
							pylsp_mypy = {
								follow_imports = "normal",
							},
							jedi_completion = {
								enabled = false
							},
							jedi_definition = {
								enabled = false
							},
							jedi_hover = {
								enabled = false,
							},
							jedi_references = {
								enabled = false
							},
						}
					}
				}
			})
			vim.lsp.enable('pylsp')

		end,
	},
}

return M
