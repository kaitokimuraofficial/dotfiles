let mapleader = "\<space>"
noremap <leader>w :w<cr>
noremap <leader>n :NERDTree<cr>
syntax on
filetype plugin indent on
set autoindent
set expandtab
set tabstop=4
set shiftwidth=4
set backspace=2
colorscheme murphy

set noswapfile
set undofile

if !isdirectory(expand("$HOME/.vim/undodir"))
    call mkdir(expand("$HOME/.vim/undodir"), "p")
endif
set undodir=$HOME/.vim.undodir

packloadall
silent! helptags ALL

set number
set wildmenu
set hlsearch
set linebreak
set display+=lastline
set laststatus=2
set cursorline
set clipboard=unnamed

call plug#begin()
Plug 'scrooloose/nerdtree'     " ファイルをtree表示してくれる
Plug 'easymotion/vim-easymotion'
Plug 'sjl/gundo.vim'
Plug 'tpope/vim-fugitive'     " Gitを便利に使う
Plug 'christoomey/vim-tmux-navigator'
Plug 'vim-scripts/ScrollColors'
Plug 'flazz/vim-colorschemes'
Plug 'vim-airline/vim-airline'
call plug#end()
