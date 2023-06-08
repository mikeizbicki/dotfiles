" general options
set number
set guioptions=
set spell spelllang=en_us
filetype plugin indent on
syntax enable
let mapleader=","
set hlsearch
set incsearch
set showcmd

" tab completion
set wildmode=longest,list,full
set wildmenu

" indentation settings
set tabstop=4
set shiftwidth=4
set expandtab
set smartindent
nmap <S-Tab> <<
imap <S-Tab> <Esc><<i

" remove annoying ex-mode feature
nnoremap Q <nop>

" restore old state of file on reload
au BufWinLeave * mkview
"au BufWinEnter * silent loadview

" syntax highlighting
set term=xterm-256color

hi clear SpellBad
hi clear SpellLocal
hi clear SpellCap
hi clear SpellRare
hi SpellBad cterm=underline
hi SpellLocal cterm=none
hi SpellCap cterm=underline
hi SpellRare cterm=underline

"hi Comment cterm=none ctermfg=103
"hi Constant cterm=none ctermfg=36
"hi Statement cterm=none ctermfg=green
"
"hi VarId cterm=none ctermfg=7 "122
"hi Identifier cterm=none ctermfg=7
"hi Normal cterm=none ctermfg=7
"
"hi hsType cterm=none ctermfg=130
"hi hsDelimiter cterm=none ctermfg=green

" press F10 to debug syntax highlighting under cursor
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" spell checking
fun! IgnoreCamelCaseSpell()
    syn match CamelCase /<[A-Z][a-z]+[A-Z].{-}>/ contains=@NoSpell transparent
    syn cluster Spell add=CamelCase
endfun
autocmd BufRead,BufNewFile * :call IgnoreCamelCaseSpell()

" add md as markdown filetype
autocmd BufNewFile,BufReadPost *.md set filetype=markdown



" haskell settings

"au Bufenter *.hs compiler ghc

" configure browser for haskell_doc.vim
"let g:haddock_browser = "/usr/bin/firefox"
"  let g:ghc = "/usr/bin/ghc"
"  let g:haddock_docdir = "/usr/share/doc/ghc-doc/html"
"let g:haddock_browser = "C:/Program Files/Opera/Opera.exe"
"let g:haddock_browser = "C:/Program Files/Mozilla Firefox/firefox.exe"
"let g:haddock_browser = "C:/Program Files/Internet Explorer/IEXPLORE.exe"

" automatically add bird tracks for literate programming
:set formatoptions+=ro

:highlight ExtraWhitespace ctermbg=red guibg=red
" remove trailing whitespaces
"fun! <SID>StripTrailingWhitespaces()
    "let l = line(".")
    "let c = col(".")
    "%s/\s\+$//e
    "call cursor(l, c)
"endfun
"autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()
