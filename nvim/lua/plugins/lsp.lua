local M = {
	{
		'williamboman/mason.nvim',
		cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog" },
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
		-- Load after file is displayed, but defer the actual setup
		event = { "BufReadPost", "BufNewFile" },
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
		-- Load after file is displayed (BufReadPost = after file content is loaded)
		-- This allows the file to show immediately while LSP loads in background
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			-- Defer LSP setup to next event loop tick
			vim.defer_fn(function()
				local capabilities = require('cmp_nvim_lsp').default_capabilities()
				local lspconfig = vim.lsp.config
				
				-- Configure LSP servers
				lspconfig.marksman = {}
				lspconfig.gopls = {}
				
				lspconfig.basedpyright = {
					capabilities = capabilities,
					settings = {
						basedpyright = {
							analysis = {
								typeCheckingMode = "off"
							}
						}
					},
				}
				
				lspconfig.pylsp = {
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
				}
			end, 0) -- 0ms delay = next event loop tick
		end,
	},
}

return M
