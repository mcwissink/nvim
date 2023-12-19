-- Bootstrapping packer
-- https://github.com/wbthomason/packer.nvim#bootstrapping
local ensure_packer = function()
   local fn = vim.fn
   local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
   if fn.empty(fn.glob(install_path)) > 0 then
      fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
      vim.cmd('packadd packer.nvim')
      return true
   end
   return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(
   function(use)
      use { 'wbthomason/packer.nvim' }
      use { "ellisonleao/gruvbox.nvim" }
      use { 'mbbill/undotree' }
      use {
	 'nvim-telescope/telescope.nvim',
	 tag = 0.1.5,
	 requires = {
	    'nvim-lua/plenary.nvim',
	 },
      }

      -- Automatically set up your configuration after cloning packer.nvim
      local packer = require('packer')
      if packer_bootstrap then
	 packer.sync()
      end
      packer.install()
      packer.compile()
   end)
