-- Bootstrapping packer
-- https://github.com/wbthomason/packer.nvim#bootstrapping
local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
		vim.cmd('packadd packer.nvim')
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()

vim.g.mapleader = ' '
vim.cmd('set tabstop')
vim.cmd('set tabstop=4')
vim.cmd('set shiftwidth=4')

function Keymap_set_all(keymap)
	for _, mode in ipairs({ 'n', 'i', 't' }) do
		for lhs, config in pairs(keymap) do
			vim.keymap.set(mode, lhs, config[1], config[2])
		end
	end
end

Keymap_set_all({
	['<c-x>t'] = { '<cmd>:terminal<cr>', {} },
	['<c-x>o'] = { '<cmd>:wincmd w<cr>', {} },
	['<c-x>0'] = { '<cmd>:wincmd q<cr>', {} },
	['<c-x>1'] = { '<cmd>:wincmd o<cr>', {} },
	['<c-x>2'] = { '<cmd>:wincmd s<cr>', {} },
	['<c-x>3'] = { '<cmd>:wincmd v<cr>', {} },
	['<c-x><c-s>'] = { '<cmd>:w<cr>', {} },
})

vim.keymap.set('t', '<esc>', '<c-\\><c-n>', {})

vim.api.nvim_create_augroup('terminal', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
	pattern = 'term://*',
	group = 'terminal',
	callback = function()
		vim.cmd('startinsert')
	end
})
vim.api.nvim_create_autocmd('TermOpen', {
	group = 'terminal',
	callback = function()
		vim.cmd('startinsert')
	end
})

return require('packer').startup(
	function(use)
		use 'wbthomason/packer.nvim'
		use 'nvim-lua/plenary.nvim'
		use 'hrsh7th/cmp-nvim-lsp'
		use 'hrsh7th/cmp-buffer'
		use 'hrsh7th/cmp-path'
		use 'hrsh7th/cmp-cmdline'
		use {
			'hrsh7th/nvim-cmp',
			config = function()
				local cmp = require('cmp')
				cmp.setup({
					mapping = cmp.mapping.preset.insert({
						['<c-b>'] = cmp.mapping.scroll_docs(-4),
						['<c-f>'] = cmp.mapping.scroll_docs(4),
						['<c-space>'] = cmp.mapping.complete(),
						['<c-e>'] = cmp.mapping.abort(),
						['<cr>'] = cmp.mapping.confirm({ select = true }),
					}),
					sources = cmp.config.sources({
						{ name = 'nvim_lsp' },
					}, {
						{ name = 'buffer' },
					})
				})
				cmp.setup.cmdline({ '/', '?' }, {
					mapping = cmp.mapping.preset.cmdline(),
					sources = {
						{ name = 'buffer' }
					}
				})
				cmp.setup.cmdline(':', {
					mapping = cmp.mapping.preset.cmdline(),
					sources = cmp.config.sources({
						{ name = 'path' }
					}, {
						{ name = 'cmdline' }
					})
				})
			end
		}
		use {
			'neovim/nvim-lspconfig',
			requires = {
				'hrsh7th/nvim-cmp',
				'nvim-telescope/telescope.nvim',
			},
			config = function()
				local lspconfig = require('lspconfig');
				local capabilities = require('cmp_nvim_lsp').default_capabilities()
				local builtin = require('telescope.builtin')
				local on_attach = function(_, bufnr)
					-- Enable completion triggered by <c-x><c-o>
					vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

					-- Mappings.
					-- See `:help vim.lsp.*` for documentation on any of the below functions
					local bufopts = { noremap = true, silent = true, buffer = bufnr }
					vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
					vim.keymap.set('n', 'gd', builtin.lsp_definitions, bufopts)
					vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
					vim.keymap.set('n', 'gi', builtin.lsp_implementations, bufopts)
					vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
					vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
					vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
					vim.keymap.set('n', '<space>wl', function()
						print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					end, bufopts)
					vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
					vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
					vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
					vim.keymap.set('n', 'gr', builtin.lsp_references, bufopts)
				end
				-- Default Lua config
				-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#sumneko_lua
				lspconfig.sumneko_lua.setup({
					on_attach = on_attach,
					settings = {
						Lua = {
							runtime = {
								version = 'LuaJIT',
							},
							diagnostics = {
								globals = { 'vim' },
							},
							workspace = {
								library = vim.api.nvim_get_runtime_file("", true),
							},
							telemetry = {
								enable = false,
							},
						},
					},
				})
				lspconfig.tailwindcss.setup({
					capabilities = capabilities,
				})
				lspconfig.tsserver.setup({
					capabilities = capabilities,
					on_attach = on_attach,
				})
				lspconfig.eslint.setup({
					on_attach = on_attach,
				})
			end
		}
		use({
			'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
			config = function()
				require("lsp_lines").setup()
				vim.diagnostic.config({ virtual_text = false })
			end
		})
		use 'MunifTanjim/prettier.nvim'
		use {
			'morhetz/gruvbox',
			config = function()
				vim.cmd('colorscheme gruvbox')
			end
		}
		use {
			'nvim-treesitter/nvim-treesitter',
			run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
			config = function()
				require('nvim-treesitter.configs').setup({
					auto_install = true,
					highlight = {
						enable = true,
						additional_vim_regex_highlighting = false,
					}
				})
			end
		}
		use {
			'mbbill/undotree',
			config = function()
				Keymap_set_all({
					['<c-x>u'] = { '<cmd>:UndotreeToggle<cr><cmd>:UndotreeFocus<cr>', {} },
				})
			end
		}
		use {
			'nvim-telescope/telescope-fzf-native.nvim',
			run = 'make'
		}
		use {
			'nvim-telescope/telescope.nvim',
			requires = {
				'nvim-telescope/telescope-fzf-native.nvim',
				'nvim-lua/plenary.nvim',
			},
			config = function()
				local actions = require('telescope.actions')
				local builtin = require('telescope.builtin')
				require('telescope').setup({
					defaults = {
						mappings = {
							i = {
								['<esc>'] = actions.close,
								['<c-k>'] = actions.delete_buffer,
							},
							n = {
								['<c-k>'] = actions.delete_buffer,
							}
						},
					},
				})

				require('telescope').load_extension('fzf')

				Keymap_set_all({
					['<c-x>p'] = { builtin.find_files, {} },
					['<c-x>g'] = { builtin.live_grep, {} },
					['<c-x>b'] = { builtin.buffers, {} },
					['<c-s>'] = { builtin.current_buffer_fuzzy_find, {} },
				})
			end
		}

		-- Automatically set up your configuration after cloning packer.nvim
		local packer = require('packer')
		if packer_bootstrap then
			packer.sync()
		end
		packer.install()
		packer.compile()
	end
)
