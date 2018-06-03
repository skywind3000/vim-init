"=============================================================================
" argtextobj.vim - Text-Object like motion for arguments
"=============================================================================
"
" Author:  Takahiro SUZUKI <takahiro.suzuki.ja@gmDELETEMEail.com>
" Version: 1.1.1 (Vim 7.1, 2009), forked and patched by inkarkat (2010-2014)
" https://github.com/inkarkat/argtextobj.vim
"
" Licence: MIT Licence
"
"=============================================================================
" Document: {{{1
"
"-----------------------------------------------------------------------------
" Description:
"   This plugin installes a text-object like motion 'a' (argument). You can
"   d(elete), c(hange), v(select)... an argument or inner argument in familiar
"   ways, such as 'daa'(delete-an-argument), 'cia'(change-inner-argument)
"   or 'via'(select-inner-argument).
"
"   What this script do is more than just typing
"     F,dt,
"   because it recognizes inclusion relationship of parentheses.
"
"   There is an option to descide whether the motion should go out to toplevel
"   function or not in nested function application.

"
"-----------------------------------------------------------------------------
" Installation:
"   Place this file in /usr/share/vim/vim*/plugin or ~/.vim/plugin/
"   Now text-object like argument motion 'ia' and 'aa' is enabled by default.
"
"-----------------------------------------------------------------------------
" Options:
"   Write below in your .vimrc if you want to apply motions to the toplevel
"   function.
"     let g:argumentobject_force_toplevel = 1
"   By default, this options is set to 0, which means your operation affects
"   to the most inner level
"
"-----------------------------------------------------------------------------
" Examples:
" case 1: delete an argument
"     function(int arg1,    char* arg2="a,b,c(d,e)")
"                              [N]  daa
"     function(int arg1)
"                     [N] daa
"     function()
"             [N]
"
" case 2: delete inner argument
"     function(int arg1,    char* arg2="a,b,c(d,e)")
"                              [N]  cia
"     function(int arg1,    )
"                          [I]
"
" case 3: smart argument recognition (g:argumentobject_force_toplevel = 0)
"     function(1, (20*30)+40, somefunc2(3, 4))
"                   [N]  cia
"     function(1, , somefunc2(3, 4))
"                [I]
"     function(1, (20*30)+40, somefunc2(3, 4))
"                                      [N]  caa
"     function(1, (20*30)+40, somefunc2(4))
"                                      [I]
"
" case 4: smart argument recognition (g:argumentobject_force_toplevel = 1)
"     function(1, (20*30)+40, somefunc2(3, 4))
"                   [N]  cia
"     function(1, , somefunc2(3, 4))
"                [I]
"     function(1, (20*30)+40, somefunc2(3, 4))
"                                      [N]  caa
"     function(1, (20*30)+40)
"                          [I]
"
"-----------------------------------------------------------------------------
" ToDo:
"   - do nothing on null parentheses '()'
"
"-----------------------------------------------------------------------------
" ChangeLog:
"   1.1.1:
"     - debug (stop beeping on using text objects). Thanks to Nadav Samet.
"
"   1.1.unreleased:
"     - support for commas in <..> (for cpp templates)
"
"   1.1:
"     - support for commas in quoted string (".."), array ([..])
"       do nothing outside a function declaration/call
"
"   1.0:
"     - Initial release
" }}}1
"=============================================================================

" ChangeLog in https://github.com/inkarkat/argtextobj.vim
"
" 2014-06-02  o [master] ENH: Support repeat of operator-pending text objects.
" 2014-05-07  M─┐ Merge pull request #2 from UnrealQuester/master
" 2014-05-03  │ o Fixing empty function arguments bug
" 2014-05-03  │ o Fixed bug with trailing whitespace
" 2014-05-03  │ o Removed debug
" 2014-05-03  │ o Return to old position when no matching parenthesis is found
" 2014-05-02  │ o Trying to fix empty argument list bug
" 2014-05-02  │ o Removed now unused option argument_mapping
" 2014-04-30  o─┘ Fixed bug in multiline arguments
" 2014-04-30  o Removed debug
" 2014-04-30  M─┐ Merge pull request #1 from inkarkat/master
" 2014-04-29  │ o Use proper syntax for help tag definitions.
" 2014-04-29  │ o Use canonical <Plug>(argtextobj...) mappings to allow remapping.
" 2014-04-29  o─┘ Added docs
" 2014-03-26  o Put most of the stuff in autoload
" 2014-03-26  o Made mapping configurable
" 2014-03-25  o Added include guard again
" 2012-01-20  o FIX: Don't define text objects for select mode.
" 2011-11-15  o ENH: Support whitespace other than <Space> (i.e. <Tab>).
" 2011-11-15  o ENH: Support arguments spread over multiple lines.
" 2011-11-15  o FIX: Prevent yank message when args are distributed over multi-lines.
" 2011-11-15  o ENH: Beep when no or too few arguments found.
" 2011-11-15  o ENH: Support [count] to select multiple arguments.
" 2011-11-15  o ENH: Avoid clobbering the regtype, selection and clipboard registers.
" 2011-11-15  o ENH: Avoid modification of buffer in s:GetOutOfDoubleQuote().
" 2011-11-15  o ENH: Handle selection=exclusive.
" 2011-11-15  o FIX: Use :normal! everywhere to avoid interference with custom mappings.
" 2009-12-30  o <1.1.1> Version 1.1.1: debug (stop beeping)
" 2009-07-04  o <1.1> Version 1.1
" 2009-07-04  I <1.0> Version 1.0: Initial upload
" 
" if exists('loaded_argtextobj') || &cp || version < 700
"   finish
" endif

" let loaded_argtextobj = 1

function! s:GetOutOfDoubleQuote()
  " get out of double quoteed string (one letter before the beginning)
  let line = getline('.')
  let pos_save = getpos('.')
  let mark_b = getpos("'<")
  let mark_e = getpos("'>")
  let repl='_'
  let did_modify = 0
  if getline('.')[getpos('.')[2]-1]=='_'
    let repl='?'
  endif

  while 1
    exe 'silent! normal! ^va"'
    normal! :\<ESC>\<CR>
    if getpos("'<")==getpos("'>")
      break
    endif
    exe 'normal! gvr' . repl
    let did_modify = 1
  endwhile

  call setpos('.', pos_save)
  if getline('.')[getpos('.')[2]-1]==repl
    " in double quote
    if did_modify
      silent undo
      call setpos('.', pos_save)
    endif
    if getpos('.')==getpos("'<")
      normal! h
    else
      normal! F"
    endif
  elseif did_modify
    silent undo
    call setpos('.', pos_save)
  endif
endfunction

function! s:GetOuterFunctionParenthesis()
  let pos_save = getpos('.')
  let rightup_before = pos_save
  silent! normal! [(
  let rightup_p = getpos('.')
  if rightup_p == rightup_before
    return []
  endif
  while rightup_p != rightup_before
    if ! g:argumentobject_force_toplevel && getline('.')[getpos('.')[2]-1-1] =~ '[a-zA-Z0-9_]'
      " found a function
      break
    endif
    let rightup_before = rightup_p
    silent! normal! [(
    let rightup_p = getpos('.')
  endwhile
  call setpos('.', pos_save)
  return rightup_p
endfunction

function! s:GetPair(pos)
  let pos_save = getpos('.')
  call setpos('.', a:pos)
  normal! %
  if a:pos == getpos('.')
    call setpos('.', pos_save)
    return []
  endif
  normal! h
  let pair_pos = getpos('.')
  call setpos('.', pos_save)
  return pair_pos
endfunction

function! s:GetInnerText(r1, r2)
  let pos_save = getpos('.')
  let cb_save = &clipboard
  set clipboard= " Avoid clobbering the selection and clipboard registers.
  let reg_save = @@
  let regtype_save = getregtype('"')
  call setpos('.', a:r1)
  normal! lv
  call setpos('.', a:r2)
  if &selection ==# 'exclusive'
    normal! l
  endif
  silent normal! y
  let val = @@
  call setpos('.', pos_save)
  call setreg('"', reg_save, regtype_save)
  let &clipboard = cb_save
  return val
endfunction

function! s:GetPrevCommaOrBeginArgs(arglist, offset)
  let commapos = strridx(a:arglist, ',', a:offset)
  return max([commapos+1, 0])
endfunction

function! s:GetNextCommaOrEndArgs(arglist, offset, count)
  let commapos = a:offset - 1
  let c = a:count
  while c > 0
    let commapos = stridx(a:arglist, ',', commapos + 1)
    if commapos == -1
      if c > 1
        execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
      endif
      return strlen(a:arglist)-1
    endif
    let c -= 1
  endwhile
  return commapos-1
endfunction

function! s:MoveToNextNonSpace()
  let oldp = getpos('.')
  let moved = 0
  while getline('.')[getpos('.')[2]-1]=~'\s'
    normal! l
    if oldp == getpos('.')
      break
    endif
    let oldp = getpos('.')
    let moved += 1
  endwhile
  return moved
endfunction

function! s:MoveLeft(num)
  if a:num>0
    exe 'normal! ' . a:num . 'h'
  endif
endfunction

function! s:MoveRight(num)
  if a:num>0
    exe 'normal! ' . a:num . 'l'
  endif
endfunction

function! s:MotionArgument(inner, visual)
  let cnt = v:count1
  let operator = v:operator
  let current_c = getline('.')[getpos('.')[2]-1]
  if current_c==',' || current_c=='('
    normal! l
  endif

  " get out of "double quoted string" because [( does not take effect in it
  call <SID>GetOutOfDoubleQuote()

  let rightup      = <SID>GetOuterFunctionParenthesis()       " on (
  if empty(rightup)
    " no left parenthesis found, not inside function arguments
    execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
    return
  endif
  let rightup_pair = <SID>GetPair(rightup)                    " before )
  if empty(rightup_pair)
    " no matching right parenthesis found, search for incomplete function
    " definition until end of current line.
    let rightup_pair = [0, line('.'), col('$'), 0]
  " empty function argument
  elseif rightup_pair == rightup
    " select both parenthesis
    if !a:inner
      normal! vh
    elseif !a:visual
      if current_c == '('
        " insert single space and visually select it
        silent! execute "normal! i \<Esc>v"
      endif
    endif
    return s:Repeat(cnt, a:inner, a:visual, operator)
  endif
  let arglist_str  = <SID>GetInnerText(rightup, rightup_pair) " inside ()
  if line('.')==rightup[1]
    " left parenthesis in the current line
    " cursor offset from rightup
    let offset  = getpos('.')[2] - rightup[2] - 1 " -1 for the removed parenthesis
  else
    " left parenthesis in a previous line; retrieve the (partial when there's a
    " matching right parenthesis) current line from the arglist_str.
    for line in split(arglist_str, "\n")
      if stridx(getline('.'), line) == 0
        let arglist_str = line
        break
      endif
    endfor
    let offset  = getpos('.')[2] - 1
  endif
  " replace all parentheses and commas inside them to '_'
  let arglist_sub  = arglist_str
  let arglist_sub = substitute(arglist_sub, "'".'\([^'."'".']\{-}\)'."'", '\="(".substitute(submatch(1), ".", "_", "g").")"', 'g') " replace '..' => (__)
  let arglist_sub = substitute(arglist_sub, '\[\([^'."'".']\{-}\)\]', '\="(".substitute(submatch(1), ".", "_", "g").")"', 'g')     " replace [..] => (__)
  let arglist_sub = substitute(arglist_sub, '<\([^'."'".']\{-}\)>', '\="(".substitute(submatch(1), ".", "_", "g").")"', 'g')       " replace <..> => (__)
  let arglist_sub = substitute(arglist_sub, '"\([^'."'".']\{-}\)"', '(\1)', 'g') " replace ''..'' => (..)
  while stridx(arglist_sub, '(')>=0 && stridx(arglist_sub, ')')>=0
    let arglist_sub = substitute(arglist_sub , '(\([^()]\{-}\))', '\="<".substitute(submatch(1), ",", "_", "g").">"', 'g')
  endwhile
  " the beginning/end of this argument
  let thisargbegin = <SID>GetPrevCommaOrBeginArgs(arglist_sub, offset)
  let thisargend   = <SID>GetNextCommaOrEndArgs(arglist_sub, offset, cnt)

  " function(..., the_nth_arg, ...)
  "             [^left]    [^right]
  let left  = offset - thisargbegin
  let right = thisargend - thisargbegin

  let delete_trailing_space = 0
  " only do inner matching when argument list is not empty
  if a:inner && arglist_sub !~# "^\s\+$"
    " ia
    call <SID>MoveLeft(left)
    let right -= <SID>MoveToNextNonSpace()
  else
    " aa
    if thisargbegin==0 && thisargend==strlen(arglist_sub)-1
      " only single argument
      call <SID>MoveLeft(left)
    elseif thisargbegin==0
      " head of the list (do not delete '(')
      call <SID>MoveLeft(left)
      let right += 1
      let delete_trailing_space = 1
    else
      " normal or tail of the list
      call <SID>MoveLeft(left+1)
      let right += 1
    endif
  endif

  exe 'normal! v'

  call <SID>MoveRight(right)
  if delete_trailing_space
    exe 'normal! l'
    call <SID>MoveToNextNonSpace()
    exe 'normal! h'
  endif

  if &selection ==# 'exclusive'
    normal! l
  endif

  call s:Repeat(cnt, a:inner, a:visual, operator)
endfunction

function! s:Repeat(cnt, inner, visual, operator)
  let l:mapping = (a:inner ? "\<Plug>(argtextobjI)" : "\<Plug>(argtextobjA)")
  if !a:visual
    silent! call ingo#motion#omap#repeat(l:mapping, a:operator, a:cnt)
  endif
endfunction




" option. turn 1 to search the most toplevel function
let g:argumentobject_force_toplevel =
  \ get(g:, 'argumentobject_force_toplevel', 0)

vnoremap <silent> <Plug>(argtextobjI) :<C-U>call <SID>MotionArgument(1, 1)<CR>
vnoremap <silent> <Plug>(argtextobjA) :<C-U>call <SID>MotionArgument(0, 1)<CR>
onoremap <silent> <Plug>(argtextobjI) :<C-U>call <SID>MotionArgument(1, 0)<CR>
onoremap <silent> <Plug>(argtextobjA) :<C-U>call <SID>MotionArgument(0, 0)<CR>
if ! hasmapto('<Plug>(argtextobjI)', 'v')
  xmap ia <Plug>(argtextobjI)
endif
if ! hasmapto('<Plug>(argtextobjA)', 'v')
  xmap aa <Plug>(argtextobjA)
endif
if ! hasmapto('<Plug>(argtextobjI)', 'o')
  omap ia <Plug>(argtextobjI)
endif
if ! hasmapto('<Plug>(argtextobjA)', 'o')
  omap aa <Plug>(argtextobjA)
endif

" vim: set foldmethod=marker et ts=2 sts=2 sw=2:

