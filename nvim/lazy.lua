local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("lazy").setup({
  "scrooloose/nerdtree",
  "tpope/vim-fugitive",
  "vim-scripts/ScrollColors",
  "flazz/vim-colorschemes",
  "vim-airline/vim-airline",
  "vim-airline/vim-airline-themes",
  "ryanoasis/vim-devicons",
  "instant-markdown/vim-instant-markdown",
  "preservim/vim-markdown",
  "lervag/vimtex",
  "thinca/vim-quickrun",
  "mattn/vim-goimports",
  "neoclide/coc.nvim",
  "fatih/vim-go",
  "hashivim/vim-terraform",
  "neovim/nvim-lspconfig",
})
