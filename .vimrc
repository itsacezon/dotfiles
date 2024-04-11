if &compatible
  " Vim defaults to `compatible` when selecting a vimrc with the command-line
  " `-u` argument. Override this.
  set nocompatible
endif

filetype off

set pyxversion=3

call plug#begin('~/.vim/plugged')

" Colour scheme
Plug 'folke/tokyonight.nvim'
Plug 'gorodinskiy/vim-coloresque'

" Quality-of-life
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-obsession'

" Code formatting
Plug 'cohama/lexima.vim'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-endwise'

" Status line
Plug 'itchyny/lightline.vim'
Plug 'itchyny/vim-gitbranch'

" Git
Plug 'tpope/vim-fugitive'
Plug 'lewis6991/gitsigns.nvim'

" File browser
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-vinegar'

" Fuzzy file searching
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Syntax highlighting
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }

" Linting, tags, auto-completion
Plug 'dense-analysis/ale'
Plug 'ludovicchabant/vim-gutentags'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zegervdv/nrpattern.nvim'

call plug#end()

filetype plugin on
filetype indent on
syntax on

" Netrw
let g:netrw_liststyle = 3 " Tree style
let g:netrw_banner = 0
" Better copy command
let g:netrw_localcopydircmd = 'cp -r'
" Sync current directory and browsing directory
" let g:netrw_keepdir = 0
let g:netrw_fastbrowse = 0
let g:netrw_browse_split = 2
let g:netrw_bufsettings = 'noma nomod nu nobl nowrap ro'

" fzf
let $FZF_DEFAULT_COMMAND = 'rg --files'
let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.5, 'highlight': 'Comment' } }
" let g:fzf_layout = { 'down': '~40%' }
let g:fzf_colors = {
  \ 'fg+': ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+': ['bg', 'CursorLine', 'CursorColumn']
  \ }

" rg from project root
command! -bang -nargs=* PRg
    \ call fzf#vim#grep(
    \ 'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>),
    \ 1,
    \ fzf#vim#with_preview({'dir': system('git -C '.expand('%:p:h').' rev-parse --show-toplevel 2> /dev/null')[:-2]}), <bang>0)

" fzf hide statusline
autocmd! FileType fzf
autocmd  FileType fzf set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

autocmd BufRead,BufNewFile *.nadel set filetype=graphql

" vim-gutentags
let s:tags_cache = expand('~/.cache/nvim/ctags')
let g:gutentags_cache_dir = s:tags_cache
let g:gutentags_file_list_command = $FZF_DEFAULT_COMMAND
let g:gutentags_ctags_extra_args = ['--exclude=.git', '--tag-relative=yes', '--fields=+ailmnS']
set wildignore+=*node_modules*

" vim-gutentags -- only run for node projects
let g:gutentags_add_default_project_roots = 0
let g:gutentags_project_root = ['package.json', '.git']

" Eslint/Typescript
let g:ale_fixers = {
  \ 'javascript': ['prettier', 'eslint'],
  \ 'typescript': ['prettier', 'eslint'],
  \ 'typescriptreact': ['prettier', 'eslint'],
  \ }
let g:ale_linters = {
  \ 'javascript': ['eslint'],
  \ 'typescript': ['eslint', 'tsserver'],
  \ 'typescriptreact': ['eslint', 'tsserver'],
  \}
let g:ale_sign_error = '❌'
let g:ale_sign_warning = '⚠️'
let g:ale_sign_info = "ℹ️"
let g:ale_fix_on_save = 1
let g:ale_sign_column_always = 1
let g:ale_completion_autoimport = 1
let g:ale_linters_explicit = 1
let g:ale_set_balloons = 1
let g:ale_hover_cursor = 1
let g:ale_hover_to_preview = 0
let g:ale_hover_to_floating_preview = 1
let g:ale_detail_to_floating_preview = 0
let g:ale_use_global_executables = 0
let g:ale_javascript_ = 1
let g:ale_javascript_prettier_use_local_config = 1
let g:ale_cursor_detail = 0
let g:ale_close_preview_on_insert = 1
let g:ale_floating_window_border = ['│', '─', '╭', '╮', '╯', '╰']
let g:ale_virtualtext_cursor = 'current'
let g:ale_sign_highlight_linenrs = 1

" Float preview
let g:float_preview#docked = 0

" Deoplete
let g:deoplete#enable_at_startup = 1
call deoplete#custom#option('sources', {'_': ['ale']})

" Themes
set termguicolors
set t_Co=256
set background=dark
let g:enable_bold_font = 1
colorscheme tokyonight-night

" Highlighting
set pumblend=20
set winblend=20

" Undercurls
let &t_Cs = "\e[4:3m"
let &t_Ce = "\e[4:0m"

let &t_ut = ''

" highlight Normal guibg=NONE ctermbg=NONE
" highlight Whitespace ctermfg=grey guifg=grey20
" highlight SpecialKey ctermfg=grey guifg=grey20
" highlight CursorLine guibg=#283457
" highlight CursorLineNR guifg=#c0caf5
highlight ALEWarning guisp=yellow gui=undercurl guifg=NONE guibg=NONE
    \ ctermfg=NONE ctermbg=NONE term=underline cterm=undercurl
highlight ALEError guisp=red gui=undercurl guifg=NONE guibg=NONE
    \ ctermfg=NONE ctermbg=NONE term=underline cterm=undercurl

" Lightline
let g:lightline = {
  \ 'colorscheme': 'tokyonight',
  \ 'component_function': {
  \   'filename': 'LightlineFilename',
  \ },
  \ 'tab_component_function': {
  \   'filename': 'CustomTabFilename',
  \ },
  \ }

" Settings
set ignorecase  " Use case insensitive search,
set smartcase   " except when using capital letters

" Use visual bell instead of beeping when doing something wrong
set visualbell
set t_vb=

set showcmd     " This shows what you are typing as a command.
set number      " Show line numbers
set ruler       " Show current cursor position
set list        " Show invisible characters
set showbreak=↪
set listchars=space:⋅,tab:→\ ,eol:↲,nbsp:␣,trail:•,extends:⟩,precedes:⟨
set nohlsearch
set clipboard=unnamed " Clipboard
set completeopt=menu
set splitright
set noshowmode

" Cursor settings
set cursorline

" Indentations
set tabstop=8     " Set number of tabs in spaces
set softtabstop=4 " Set number of tabs in spaces
set shiftwidth=4
set expandtab     " Use space instead of tabs
set nopaste
set autoindent
set breakindent

" Auto-resize splits
set equalalways
autocmd VimResized * wincmd =
autocmd BufWinEnter * wincmd =

" Remove trailing whitespace
autocmd BufWritePre * :%s/\s\+$//e
" Remove newlines at the end of file
autocmd BufWritePre * :%s/\($\n\s*\)\+\%$//e

" Commands
let mapleader = ','

" ==============================
" Key mappings
" ==============================

nnoremap <C-Left> <C-W><C-J>
nnoremap <C-Up> <C-W><C-K>
nnoremap <C-Right> <C-W><C-L>
nnoremap <C-Down> <C-W><C-H>

" Move through wrapped lines
inoremap <silent> <Down> <C-o>gj
inoremap <silent> <Up> <C-o>gk
nnoremap <silent> <Down> gj
nnoremap <silent> <Up> gk

" Better redo
nnoremap q <C-r>

" Move through wrapped lines with relative number lines
nnoremap <expr> <Down> v:count == 0 ? 'gj' : "\<Esc>".v:count.'j'
nnoremap <expr> <Up> v:count == 0 ? 'gk' : "\<Esc>".v:count.'k'

" Tab navigation like Firefox.
nnoremap <C-S-tab> :tabprevious<CR>
nnoremap <C-tab>   :tabnext<CR>
nnoremap <C-t>     :tabnew<CR>
inoremap <C-S-tab> <Esc>:tabprevious<CR>i
inoremap <C-tab>   <Esc>:tabnext<CR>i
inoremap <C-t>     <Esc>:tabnew<CR>

" Add semicolon
inoremap <leader>; <C-o>A;

" relative path  (src/foo.txt)
nnoremap <Leader>cf :let @*=expand("%")<CR>

" absolute path  (/something/src/foo.txt)
nnoremap <Leader>cF :let @*=expand("%:p")<CR>

" filename       (foo.txt)
nnoremap <Leader>ct :let @*=expand("%:t")<CR>

" relative directory name (/something/src)
nnoremap <leader>ch :let @*=expand("%:h")<CR>

" absolute directory name (/something/src)
nnoremap <leader>cH :let @*=expand("%:p:h")<CR>

" Equal splits
map <Leader>, <c-w>=

" Modify screen
" Switch active splits
map <Tab> <c-w>w

" File explorer
map <Leader>v :Lexplore %:p:h<CR>

" Find and replace
map <Leader>h :%s/

" fzf shortcuts
map <C-p> :Files<CR>

" rg shortcuts
map <Leader><Space> :PRg<CR>
nnoremap <silent> <Leader>rg :PRg <C-R><C-W><CR>
xnoremap <silent> <Leader>rg y:PRg <C-R>"<CR>

" Create a vertical new split
map \ :vnew<CR>
map <Leader>\ :vsplit<CR>

" Create a horizontal new split
" map - :new<CR>
map <Leader>- :split<CR>

" Reload vimrc
map <Leader>z :source $MYVIMRC<CR>

" Prettify json
nnoremap <silent> json :%!python -m json.tool<CR>

" <TAB>: completion.
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

" vim-fugitive
nnoremap :gw :Gwrite

" ALE mappings
nnoremap K :ALEHover<CR>
nnoremap L :ALEDetail<CR>
nnoremap <silent> gr :ALEFindReferences<CR>
autocmd FileType typescriptreact map <buffer> ] :ALEGoToDefinition<CR>
autocmd FileType typescriptreact map <buffer> <c-]> :ALEGoToDefinition -vsplit<CR>

" Auto line numbering
set number relativenumber
augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
    autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

" Clear cursor when leaving buffers
augroup CursorLine
    autocmd!
    autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    autocmd WinLeave * setlocal nocursorline
augroup END

function! CustomTabFilename(n)
    let buflist = tabpagebuflist(a:n)
    let winnr = tabpagewinnr(a:n)
    let bufnum = buflist[winnr - 1]
    let bufname = expand('#'.bufnum.':t')
    let buffullname = expand('#'.bufnum.':p')
    let buffullnames = []
    let bufnames = []
    for i in range(1, tabpagenr('$'))
        if i != a:n
            let num = tabpagebuflist(i)[tabpagewinnr(i) - 1]
            call add(buffullnames, expand('#' . num . ':p'))
            call add(bufnames, expand('#' . num . ':t'))
        endif
    endfor
    let i = index(bufnames, bufname)
    if strlen(bufname) && i >= 0 && buffullnames[i] != buffullname
        return substitute(buffullname, '.*/\([^/]\+/\)', '\1', '')
    else
        return strlen(bufname) ? bufname : '[No Name]'
    endif
endfunction

function! LightlineFilename()
    let root = fnamemodify(get(b:, 'gitbranch_path'), ':h:h')
    let path = expand('%:p')
    if path[:len(root)-1] ==# root
        return path[len(root)+1:]
    endif
    return expand('%')
endfunction

function! s:MkNonExDir(file, buf)
    if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
        let dir=fnamemodify(a:file, ':h')
        if !isdirectory(dir)
            call mkdir(dir, 'p')
        endif
    endif
endfunction

" Automatically create missing directories
augroup BWCCreateDir
    autocmd!
    autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
augroup END

" Better keymaps for Netrw
function! NetrwMapping()
    " Close the preview window
    nmap <buffer> <Leader>v :Lexplore<CR>

    " Open file then close Netrw
    nmap <buffer> v <CR>:Lexplore<CR>

    " Close the preview window
    nmap <buffer> P <C-w>z
endfunction

augroup netrw_mapping
    autocmd!
    autocmd FileType netrw call NetrwMapping()
    autocmd FileType netrw setlocal bufhidden=wipe
augroup END
