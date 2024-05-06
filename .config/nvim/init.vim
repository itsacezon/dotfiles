set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

" Load vim config
source ~/.vimrc

" Load Lua config
:lua require('init')

" Reload vim config
source ~/.vimrc
