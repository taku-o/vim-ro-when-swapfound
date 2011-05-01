" checkswapfile.vim: Open file in read-only mode when swapfile is found.
" Load Once:
if &cp || exists("g:loaded_checkswapfile")
    finish
endif
let g:loaded_checkswapfile = 1
let s:keepcpo              = &cpo
set cpo&vim
" ---------------------------------------------------------------------

" g:checkswapfile_swapCheckEnabled open
let s:swapCheckEnabled = 0
if exists('g:checkswapfile_swapCheckEnabled')
    let s:swapCheckEnabled = g:checkswapfile_swapCheckEnabled
endif

let s:_shortmess = &shortmess
function! ToggleSwapCheck()
    let s:swapCheckEnabled = !s:swapCheckEnabled
    if !s:swapCheckEnabled
        let &shortmess = s:_shortmess
    endif
    aug CheckSwap
        au!
        if s:swapCheckEnabled
            set shortmess+=A
            au BufReadPre * call CheckSwapFile()
            au BufRead * call WarnSwapFile()
        endif
    aug END
endfunction
call ToggleSwapCheck()

function! CheckSwapFile()
    if !&swapfile || !s:swapCheckEnabled
        return
    endif

    let swapname = s:GetVimCmdOutput('swapname')
    if swapname =~ '\.sw[^p]$'
        set readonly
        let b:_warnSwap = 1
    endif
endfunction

function! WarnSwapFile()
    if exists('b:_warnSwap') && b:_warnSwap && &swapfile
        echohl ErrorMsg | echomsg "File: \"" . bufname('%') .
                    \ "\" is opened readonly, as a swapfile already existed."
                    \ | echohl NONE
        unlet b:_warnSwap
    endif
endfunction

function! s:GetVimCmdOutput(cmd)
    let v:errmsg = ''
    redir @z
    silent! exec a:cmd
    redir END
    if v:errmsg == ''
        return @z
    endif
    return ''
endfunction

" command
command! ToggleSwapCheck call ToggleSwapCheck()

" ---------------------------------------------------------------------
let &cpo= s:keepcpo
unlet s:keepcpo

