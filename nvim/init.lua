--[[
    _____________   ____________  ___    __ 
   / ____/ ____/ | / / ____/ __ \/   |  / / 
  / / __/ __/ /  |/ / __/ / /_/ / /| | / /  
 / /_/ / /___/ /|  / /___/ _, _/ ___ |/ /___
 \____/_____/_/ |_/_____/_/ |_/_/  |_/_____/
]]
vim.cmd([[
    syntax on
    filetype plugin indent on
]])

vim.opt.shell = "/bin/zsh"
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.backspace = { "indent", "eol", "start" }

vim.opt.swapfile = false
vim.opt.autoread = true

vim.opt.undofile = true
local undodir = vim.fn.expand("$HOME/.local/state/nvim/undo")
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end
vim.opt.undodir = undodir

vim.opt.updatetime = 300
vim.opt.number = true
vim.opt.wildmenu = true
vim.opt.hlsearch = true
vim.opt.linebreak = true
vim.opt.display:append("lastline")
vim.opt.laststatus = 2
vim.opt.cursorline = true
vim.opt.clipboard = "unnamed"
vim.opt.hidden = true
vim.opt.belloff = "all"
vim.opt.errorbells = false

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    pattern = "*grep*",
    command = "cwindow"
})


--[[
     ____  __    __  _____________   __
    / __ \/ /   / / / / ____/  _/ | / /
   / /_/ / /   / / / / / __ / //  |/ / 
  / ____/ /___/ /_/ / /_/ // // /|  /  
 /_/   /_____/\____/\____/___/_/ |_/ 
]]
vim.api.nvim_create_autocmd("StdinReadPre", {
  pattern = "*",
  callback = function() vim.g.std_in = true end
})

vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    if vim.fn.argc() == 0 and not vim.g.std_in then
      vim.cmd("NERDTree")
    end
  end
})

vim.o.laststatus = 2

vim.g.rustfmt_autosave = 1
vim.g.go_fmt_command = "goimports"
vim.g.go_def_mapping_enabled = 0
vim.g.go_fmt_autosave = 1
vim.g.go_highlight_types = 1
vim.g.go_highlight_fields = 1
vim.g.go_highlight_functions = 1
vim.g.go_highlight_methods = 1
vim.g.terraform_fmt_on_save = 1

require("config.lazy")

local lspconfig = require('lspconfig')
lspconfig.ruby_lsp.setup({
  cmd = { "ruby-lsp" },
  filetypes = { "ruby" },
  root_dir = lspconfig.util.root_pattern("Gemfile", ".git"),
  init_options = {
    formatting = "auto",
  },
  single_file_support = true,
})
