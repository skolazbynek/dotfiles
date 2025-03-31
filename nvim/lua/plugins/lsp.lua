local M = {
	{
		'williamboman/mason.nvim',
		opts = {
			log_level = vim.log.levels.DEBUG,
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
			ensure_installed = {
				'pylsp', 'lua_ls', 'gopls', 'basedpyright'
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
			-- require('lspconfig').pylsp.setup{
				-- capabilities = capabilities,
				-- settings = {
					-- pylsp = {
						-- rope = {
							-- ropeFolder = '.ropefolder'
						-- },
						-- configurationSources = { "flake8" },
						-- plugins = {
							-- pycodestyle = {
								-- enabled = false
							-- },
							-- mccabe = {
								-- enabled = false
							-- },
							-- pyflakes = {
								-- enabled = false
							-- },
							-- flake8 = {
								-- enabled = true
							-- },
							-- rope_autoimport = {
								-- enabled = true
							-- },
							-- rope_completion = {
								-- enabled = false
							-- },
							-- jedi_completion = {
								-- enabled = true
							-- },
						-- },
					-- }
				-- }
			-- }
			lspconfig.marksman.setup{}
			lspconfig.gopls.setup{}
			lspconfig.basedpyright.setup{
				capabilities = capabilities,
				settings = {
					basedpyright = {
						analysis = {
							typeCheckingMode = "off"
						}
					}
				}
			}
		end,
	},
}

return M
