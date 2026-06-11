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
"set smartindent

" comment settings
set formatoptions-=t
set formatoptions+=cro

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

" spell checking
fun! IgnoreCamelCaseSpell()
    syn match CamelCase /<[A-Z][a-z]+[A-Z].{-}>/ contains=@NoSpell transparent
    syn cluster Spell add=CamelCase
endfun
autocmd BufRead,BufNewFile * :call IgnoreCamelCaseSpell()

" highlight trailing whitespace in red
highlight ExtraWhitespace ctermbg=red guibg=red 
match ExtraWhitespace /\s\+$/

" add md as markdown filetype
autocmd BufNewFile,BufRead *.md set filetype=markdown

" JSON config
autocmd BufNewFile,BufRead *.json-schema set filetype=json
autocmd FileType json setlocal tabstop=2 shiftwidth=2 expandtab

" the :R command is like :! but it prints the command and its output into the
" current buffer rather than to the screen;
" the name comes from the fact that `:R ls` behaves similarly to `:r !ls`
command! -nargs=+ -complete=shellcmd R call s:R(<q-args>)
function! s:R(qargs) abort
  let ind = matchstr(getline('.'), '^\s*') . '    '
  let lines = map(['$ ' . a:qargs] + systemlist(a:qargs) + [''],
        \ {_, v -> v == '' ? '' : ind . v})
  let l = line('.')
  call append(l, lines)
  call cursor(l + len(lines), 1)
endfunction


