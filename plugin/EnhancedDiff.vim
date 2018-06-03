" EnhancedDiff.vim - Enhanced Diff functions for Vim
" -------------------------------------------------------------
" Version: 0.3
" Maintainer:  Christian Brabandt <cb@256bit.org>
" Last Change: Thu, 05 Mar 2015 08:11:46 +0100
" Script: http://www.vim.org/scripts/script.php?script_id=5121
" Copyright:   (c) 2009-2015 by Christian Brabandt
"          The VIM LICENSE applies to EnhancedDifff.vim
"          (see |copyright|) except use "EnhancedDiff.vim"
"          instead of "Vim".
"          No warranty, express or implied.
"    *** ***   Use At-Your-Own-Risk!   *** ***
" GetLatestVimScripts: 5121 3 :AutoInstall: EnhancedDiff.vim
"
" Init: {{{1
let s:cpo= &cpo
if exists("g:loaded_enhanced_diff") || &cp
    finish
endif
set cpo&vim
let g:loaded_enhanced_diff = 1

" Functions {{{1
function! s:CustomDiffAlgComplete(A,L,P) "{{{2
    return "myers\nminimal\ndefault\npatience\nhistogram"
endfu
function! s:CustomIgnorePat(bang, ...) "{{{2
    if a:bang || !exists("g:enhanced_diff_ignore_pat")
        let g:enhanced_diff_ignore_pat=[]
    endif
    if a:0
        let pat = a:1
        let replace = a:0 == 2 ? a:2 : 'XXX'
        call add(g:enhanced_diff_ignore_pat, [pat, replace])
    endif
endfu
" public interface {{{1
com! -nargs=1 -complete=custom,s:CustomDiffAlgComplete EnhancedDiff :let &diffexpr='EnhancedDiff#Diff("git diff", "--diff-algorithm=<args>")'|:diffupdate
com! PatienceDiff :EnhancedDiff patience
com! EnhancedDiffDisable  :set diffexpr=
"com! -nargs=1 -bang EnhancedDiffIgnorePat if <q-bang> | :let g:enhanced_diff_ignore_pat = [<q-args>] | else | :let g:enhanced_diff_ignore_pat=get(g:, 'enhanced_diff_ignore_pat', []) + [<q-args>] |endif
com! -nargs=* -bang EnhancedDiffIgnorePat call s:CustomIgnorePat(<q-bang>, <f-args>)

" Restore: "{{{1
let &cpo=s:cpo
unlet s:cpo
" vim: ts=4 sts=4 sw=4 et fdm=marker com+=l\:\"
