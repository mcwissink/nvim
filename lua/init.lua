local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.o.signcolumn = "yes"

require("lazy").setup({
	{
		"savq/melange-nvim",
		config = function()
			vim.opt.termguicolors = true
			vim.o.background = "light"
			vim.cmd.colorscheme "melange"
		end
	},
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.5",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
			"debugloop/telescope-undo.nvim",
		},
		config = function()
			require("telescope").setup({
				defaults = require("telescope.themes").get_dropdown(),
				extensions = {
					file_browser = {
						hidden = true
					}
				}
			})
			require("telescope").load_extension("ui-select")
			require("telescope").load_extension("undo")

			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>f", builtin.find_files, {})
			vim.keymap.set("n", "<leader>g", builtin.live_grep, {})
			vim.keymap.set("n", "<leader>b",
				function() builtin.buffers({ sort_mru = true, ignore_current_buffer = true }) end, {})
			vim.keymap.set("n", "<leader>s", builtin.current_buffer_fuzzy_find, {})
			vim.keymap.set("n", "<leader>t", builtin.treesitter, {})
			vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>", {})
		end
	},
	{
		'nvim-telescope/telescope-fzf-native.nvim',
		build = 'make',
		config = function()
			require('telescope').load_extension('fzf')
		end
	},
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").load_extension("file_browser")
			vim.keymap.set("n", "<leader>d", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>",
				{})
		end
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				auto_install = true,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
			})
		end
	},
	-- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/lazy-loading-with-lazy-nvim.md
	{
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v3.x',
		lazy = true,
		config = false,
		init = function()
			vim.g.lsp_zero_extend_cmp = 0
			vim.g.lsp_zero_extend_lspconfig = 0
		end,
	},
	{
		'williamboman/mason.nvim',
		lazy = false,
		config = true,
	},
	{
		'hrsh7th/nvim-cmp',
		event = 'InsertEnter',
		dependencies = {
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
		},
		config = function()
			local lsp_zero = require('lsp-zero')
			lsp_zero.extend_cmp()

			local cmp = require('cmp')
			local cmp_action = lsp_zero.cmp_action()

			cmp.setup({
				formatting = lsp_zero.cmp_format(),
				mapping = cmp.mapping.preset.insert({
					['<C-Space>'] = cmp.mapping.complete(),
					['<C-u>'] = cmp.mapping.scroll_docs(-4),
					['<C-d>'] = cmp.mapping.scroll_docs(4),
					['<C-f>'] = cmp_action.luasnip_jump_forward(),
					['<C-b>'] = cmp_action.luasnip_jump_backward(),
					['<CR>'] = cmp.mapping.confirm({ select = true }),
				})
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})
		end
	},
	{
		'neovim/nvim-lspconfig',
		cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
		event = { 'BufReadPre', 'BufNewFile' },
		dependencies = {
			{ 'hrsh7th/cmp-nvim-lsp' },
			{ 'williamboman/mason-lspconfig.nvim' },
		},
		config = function()
			local lsp_zero = require('lsp-zero')
			local builtin = require("telescope.builtin")
			lsp_zero.extend_lspconfig()

			lsp_zero.on_attach(function(client, bufnr)
				-- see :help lsp-zero-keybindings
				vim.keymap.set("n", "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>",
					{ buffer = bufnr })
				vim.keymap.set("n", "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", { buffer = bufnr })
				vim.keymap.set("n", "<leader>lf", "<cmd>lua vim.lsp.buf.format()<cr>", { buffer = bufnr })
				vim.keymap.set("n", "gd", builtin.lsp_definitions, { buffer = bufnr })
				vim.keymap.set("n", "gi", builtin.lsp_implementations, { buffer = bufnr })
				vim.keymap.set("n", "gr", builtin.lsp_references, { buffer = bufnr })
				lsp_zero.default_keymaps({ buffer = bufnr, preserve_mappings = true })
			end)

			require('mason-lspconfig').setup({
				ensure_installed = { "tsserver", "lua_ls", "eslint" },
				handlers = {
					lsp_zero.default_setup,
					lua_ls = function()
						require('lspconfig').lua_ls.setup({
							settings = {
								Lua = {
									diagnostics = {
										globals = { "vim" }
									}
								}
							}
						})
					end,
				}
			})
		end
	}
})
