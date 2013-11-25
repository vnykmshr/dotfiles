filetype on
filetype plugin on
filetype plugin indent on
syntax on
set tabstop=2 shiftwidth=2 expandtab modelines=3
set diffopt+=iwhite

function! s:insert_gates()
  let gatename = substitute(toupper(expand("%:t")), "\\.", "_", "g")
  execute "normal! i#ifndef " . "_" . gatename
  execute "normal! o#define " . "_" . gatename . " "
  execute "normal! Go#endif /* " . "_" . gatename . " */"
  normal! kk
endfunction

autocmd BufNewFile *.{h} call <SID>insert_gates()
au BufNewFile,BufRead *.ejs set filetype=html
nmap <C-x> :w<CR>:make<CR>:cw<CR>

cmap w!! %!sudo tee > /dev/null %

highlight DiffChange cterm=none ctermbg=Yellow
