"======================================================================
"
" preview.vim - the missing preview function in vim
"
" Created by skywind on 2018/04/24
" Last Modified: 2018/04/24 20:12:40
"
"======================================================================


"----------------------------------------------------------------------
" preview file
"----------------------------------------------------------------------
function! s:PreviewFile(...)
	if a:0 == 0
		return
	endif
	let filename = expand(a:{a:0})
	let nohl = 0
	let cmd = ''
	for i in range(a:0 - 1)
		let item = a:{i + 1}
		let head = strpart(item, 0, 2)
		if head == '+:'
			let cmd = strpart(item, 2)
		elseif head == '++'
			if item == '++nohl'
				let nohl = 1
			endif
		endif
	endfor
	if !filereadable(filename)
		call preview#errmsg('ERROR: preview: file not find "'. filename.'"')
		return
	endif
	call preview#preview_edit(-1, filename, -1, cmd, nohl)
endfunc


command! -nargs=+ -complete=file PreviewFile call s:PreviewFile(<f-args>)
command! -nargs=0 PreviewClose call preview#preview_close()


"----------------------------------------------------------------------
" preview tag
"----------------------------------------------------------------------
function! s:PreviewTag(...)
	let tagname = (a:0 > 0)? a:1 : expand('<cword>')
	call preview#preview_tag(tagname)
endfunc

command! -nargs=? PreviewTag call s:PreviewTag(<f-args>)


"----------------------------------------------------------------------
" preview signature
"----------------------------------------------------------------------
function! s:PreviewSignature(bang, ...)
	let funcname = (a:0 > 0)? a:1 : expand('<cword>')
	if a:bang 
		let funcname = '<?>'
	endif
	call preview#function_echo(funcname, 0)
endfunc

command! -nargs=? -bang PreviewSignature call s:PreviewSignature(<bang>0, <f-args>)


"----------------------------------------------------------------------
" preview scroll
"----------------------------------------------------------------------
function! s:PreviewScroll(bang, offset)
	if a:bang == 0
		call preview#preview_scroll(str2nr(a:offset))
	else
		call preview#previous_scroll(str2nr(a:offset))
	endif
endfunc

command! -nargs=1 -bang PreviewScroll call s:PreviewScroll(<bang>0, <f-args>)



"----------------------------------------------------------------------
" goto the preview window
"----------------------------------------------------------------------
command! -nargs=1 PreviewGoto call preview#preview_goto(<f-args>)


"----------------------------------------------------------------------
" preview files for quickfix
"----------------------------------------------------------------------
function! s:PreviewQuickfix(...)
	let linenr = (a:0 > 0)? a:1 : 0
	call preview#preview_quickfix(linenr)
endfunc


command! -nargs=? PreviewQuickfix call s:PreviewQuickfix(<f-args>)




