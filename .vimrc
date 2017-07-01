set nocompatible
filetype off

call plug#begin('~/.vim/plugged')

Plug 'mileszs/ack.vim'
Plug 'Yggdroot/indentLine'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-endwise'
Plug 'jiangmiao/auto-pairs'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'mxw/vim-jsx'
Plug 'elzr/vim-json', { 'for': 'json' }
Plug 'kchmck/vim-coffee-script'
Plug 'juvenn/mustache.vim'
Plug 'hail2u/vim-css3-syntax', { 'for': ['scss', 'sass'] }
Plug 'isRuslan/vim-es6'
Plug 'slim-template/vim-slim', { 'for': 'slim' }
Plug 'elixir-lang/vim-elixir'

Plug 'dracula/vim', { 'as': 'dracula-vim'  }

call plug#end()

filetype indent on
syntax on

" Ag
let g:ackprg = 'ag --vimgrep'
let $FZF_DEFAULT_COMMAND = 'ag -g ""'

" Themes
set background=dark
let g:enable_bold_font = 1
colorscheme dracula

" Lightline
let g:lightline = { 'colorscheme': 'Dracula', }

autocmd BufWritePre * :%s/\s\+$//e                 " Remove trailing whitespace
autocmd BufWritePre * :%s/\($\n\s*\)\+\%$//e       " Remove newlines at the end of file

" Settings
set expandtab                                      " Use space instead of tabs
set tabstop=2                                      " Set number of tabs in spaces
set shiftwidth=2
set ignorecase                                     " Use case insensitive search,
set smartcase                                      " except when using capital letters
set visualbell                                     " Use visual bell instead of beeping when doing something wrong
set showcmd                                        " This shows what you are typing as a command.
set number                                         " Show line numbers
set ruler                                          " Show current cursor position
set list                                           " Show invisible characters
set hlsearch                                       " Highlight search results
set clipboard=unnamed                              " Clipboard

" Commands
let mapleader = ','

" ==============================
" Key mappings
" ==============================

nnoremap <C-Left> <C-W><C-J>
nnoremap <C-Up> <C-W><C-K>
nnoremap <C-Right> <C-W><C-L>
nnoremap <C-Down> <C-W><C-H>

" Tab navigation like Firefox.
nnoremap <C-S-tab> :tabprevious<CR>
nnoremap <C-tab>   :tabnext<CR>
nnoremap <C-t>     :tabnew<CR>
inoremap <C-S-tab> <Esc>:tabprevious<CR>i
inoremap <C-tab>   <Esc>:tabnext<CR>i
inoremap <C-t>     <Esc>:tabnew<CR>

" Resize screens
" Widen (vertical) split
map <Leader>. <c-w>10>

" Narrow (vertical) split
map <Leader>m <c-w>10<

" Taller (horizontal) split
map <Leader>k <c-w>3+

" Shorten (horizontal) split
map <Leader>j <c-w>3-

" Equal splits
map <Leader>, <c-w>=

" Modify screen
" Switch active splits
map <Tab> <c-w>w

" Rotate/jumble splits
map <Leader>r <c-w>r

" Switch to horizontal split
map <Leader>h <c-w>H

" Switch to vertical split
map <Leader>v <c-w>K

" New tab
map nt <c-w>T

" Get current file's path
map fn :echo<Space>@%<CR>

" fzf shortcuts
map <Leader>fl :Files<Space>
map <Leader>co :Colors<Space>
map <Leader>hi :History/<Space>
map <Leader>bl :BLines<Space>

" Create a vertical new split
map \ :vsplit<CR>

" Create a horizontal new split
map <Leader>- :split<CR>

" Install bundles
map <Leader>pi :PlugInstall<CR>

" Reload vimrc
map <Leader>z :so $MYVIMRC<CR>

" Prettify json
map json :%!python -m json.tool<CR>

" ==============================
" Syntax highlighting
" ==============================
autocmd BufNewFile,BufReadPost *.inky-haml set filetype=haml
autocmd BufNewFile,BufReadPost *.hamlbars set filetype=haml
autocmd BufNewFile,BufReadPost *.hbs set filetype=html
autocmd BufNewFile,BufReadPost *.md set filetype=markdown
autocmd BufNewFile,BufReadPost Guardfile,Gemfile,Gemfile.lock set filetype=ruby
