"======================================================================
"
" preview.vim - the missing preview function in vim
"
" Created by skywind on 2018/04/24
" Last Modified: 2018/04/24 18:29:55
"
"======================================================================

"----------------------------------------------------------------------
" window basic
"----------------------------------------------------------------------

" save all window's view
function! preview#window_saveview()
	function! s:window_view_save()
		let w:preview_window_view = winsaveview()
	endfunc
	let l:winnr = winnr()
	noautocmd windo call s:window_view_save()
	noautocmd silent! exec ''.l:winnr.'wincmd w'
endfunc

" restore all window's view
function! preview#window_loadview()
	function! s:window_view_rest()
		if exists('w:preview_window_view')
			call winrestview(w:preview_window_view)
			unlet w:preview_window_view
		endif
	endfunc
	let l:winnr = winnr()
	noautocmd windo call s:window_view_rest()
	noautocmd silent! exec ''.l:winnr.'wincmd w'
endfunc

" unique window id
function! preview#window_uid(tabnr, winnr)
	let name = 'preview_window_unique_id'
	let uid = gettabwinvar(a:tabnr, a:winnr, name)
	if type(uid) == 1 && uid == ''
		if !exists('s:preview_window_unique_index')
			let s:preview_window_unique_index = 1000
			let s:preview_window_unique_rewind = 0
			let uid = 1000
			let s:preview_window_unique_index += 1
		else
			let uid = 0
			if !exists('s:preview_window_unique_rewind')
				let s:preview_window_unique_rewind = 0
			endif
			if s:preview_window_unique_rewind == 0 
				let uid = s:preview_window_unique_index
				let s:preview_window_unique_index += 1
				if s:preview_window_unique_index >= 100000
					let s:preview_window_unique_rewind = 1
					let s:preview_window_unique_index = 1000
				endif
			else
				let name = 'preview_window_unique_id'
				let index = s:preview_window_unique_index
				let l:count = 0
				while l:count < 100000
					let found = 0
					for l:tabnr in range(1, tabpagenr('$'))
						for l:winnr in range(1, tabpagewinnr(l:tabnr, '$'))
							if gettabwinvar(l:tabnr, l:winnr, name) is index
								let found = 1
								break
							endif
						endfor
						if found != 0
							break
						endif
					endfor
					if found == 0
						let uid = index
					endif
					let index += 1
					if index >= 100000
						let index = 1000
					endif
					let l:count += 1
					if found == 0
						break
					endif
				endwhile
				let s:preview_window_unique_index = index
			endif
			if uid == 0
				echohl ErrorMsg
				echom "error allocate new window uid"
				echohl NONE
				return -1
			endif
		endif
		call settabwinvar(a:tabnr, a:winnr, name, uid)
	endif
	return uid
endfunc

" unique window id to [tabnr, winnr], [0, 0] for not find
function! preview#window_find(uid)
	let name = 'preview_window_unique_id'
	" search current tabpagefirst
	for l:winnr in range(1, winnr('$'))
		if gettabwinvar('%', l:winnr, name) is a:uid
			return [tabpagenr(), l:winnr]
		endif
	endfor
	" search all the tabpages
	for l:tabnr in range(1, tabpagenr('$'))
		for l:winnr in range(1, tabpagewinnr(l:tabnr, '$'))
			if gettabwinvar(l:tabnr, l:winnr, name) is a:uid
				return [l:tabnr, l:winnr]
			endif
		endfor
	endfor
	return [0, 0]
endfunc

" switch to tabwin
function! preview#window_goto_tabwin(tabnr, winnr)
	if a:tabnr != '' && a:tabnr != '%'
		if tabpagenr() != a:tabnr
			silent! exec "tabn ". a:tabnr
		endif
	endif
	if winnr() != a:winnr
		silent! exec ''.a:winnr.'wincmd w'
	endif
endfunc

" switch to window by uid
function! preview#window_goto_uid(uid)
	let [l:tabnr, l:winnr] = preview#window_find(a:uid)
	if l:tabnr == 0 || l:winnr == 0
		return 1
	endif
	call preview#window_goto_tabwin(l:tabnr, l:winnr)
	return 0
endfunc

" new window and return window uid, zero for error
function! preview#window_new(position, size, avoid)
	function! s:window_new_action(mode)
		if a:mode == 0
			let w:preview_window_saveview = winsaveview()
		else
			if exists('w:preview_window_saveview')
				call winrestview(w:preview_window_saveview)
				unlet w:preview_window_saveview
			endif
		endif
	endfunc
	let uid = preview#window_uid('%', '%')
	let retval = 0
	noautocmd windo call s:window_new_action(0)
	noautocmd call preview#window_goto_uid(uid)
	if type(a:avoid) == 3
		for i in range(winnr('$'))
			let ok = 1
			let bt = &buftype
			for skip in a:avoid
				if skip == bt
					let ok = 0
					break
				endif
			endfor
			if ok != 0
				break
			endif
			noautocmd wincmd w
		endfor
	endif
	if a:position == 'top' || a:position == '0'
		if a:size <= 0
			leftabove new 
		else
			exec 'leftabove '.a:size.'new'
		endif
	elseif a:position == 'bottom' || a:position == '1'
		if a:size <= 0
			rightbelow new
		else
			exec 'rightbelow '.a:size.'new'
		endif
	elseif a:position == 'left' || a:position == '2'
		if a:size <= 0
			leftabove vnew
		else
			exec 'leftabove '.a:size.'vnew'
		endif
	elseif a:position == 'right' || a:position == '3'
		if a:size <= 0
			rightbelow vnew
		else
			exec 'rightbelow '.a:size.'vnew'
		endif
	else
		rightbelow vnew
	endif
	let retval = preview#window_uid('%', '%')
	noautocmd windo call s:window_new_action(1)
	if retval > 0
		noautocmd call preview#window_goto_uid(retval)
	endif
	call preview#window_goto_uid(uid)
	return retval
endfunc


"----------------------------------------------------------------------
" search buftype and filetype
"----------------------------------------------------------------------
function! preview#window_search(buftype, filetype, modifiable)
	for i in range(winnr('$'))
		if getwinvar(i + 1, '&buftype') == a:buftype 
			if getwinvar(i + 1, '&filetype') == a:filetype
				if getwinvar(i + 1, '&modifiable') == a:modifiable
					return i + 1
				endif
			endif
		endif
	endfor
	return 0
endfunc


"----------------------------------------------------------------------
" reposition window
"----------------------------------------------------------------------
function! preview#window_up(color)
	if has('folding')
		silent! .foldopen!
	endif
	noautocmd exec "normal! zz"
	if &previewwindow && a:color != 0 && g:preview#highlight != ''
		let xline = line('.')
		match none
		exec 'match '.g:preview#highlight.' "\%'. xline.'l"'
	endif
	let height = winheight('%') / 4
	let winfo = winsaveview()
	let avail = line('.') - winfo.topline - &scrolloff
	let height = (height < avail)? height : avail
	if height > 0
		noautocmd exec "normal! ".height."\<c-e>"
	endif
endfunc


"----------------------------------------------------------------------
" preview window
"----------------------------------------------------------------------
if !exists('g:preview#preview_position')
	let g:preview#preview_position = "right"
endif

if !exists('g:preview#preview_vsize')
	let g:preview#preview_vsize = 0
endif

if !exists('g:preview#preview_size')
	let g:preview#preview_size = 0
endif


" check preview window is open ?
function! preview#preview_check()
	for i in range(winnr('$'))
		if getwinvar(i + 1, '&previewwindow', 0)
			return preview#window_uid('%', i + 1)
		endif
	endfor
	return 0
endfunc


" open preview vertical or horizon
function! preview#preview_open()
	let pid = preview#preview_check()
	if pid == 0
		let uid = preview#window_uid('%', '%')
		let pos = g:preview#preview_position
		let size = g:preview#preview_vsize
		if pos == 'top' || pos == 'bottom' || pos == '0' || pos == '1'
			let size = g:preview#preview_size
		endif
		let avoid = ['quickfix', 'help', 'nofile']
		let pid = preview#window_new(pos, size, avoid)
		if pid > 0
			noautocmd call preview#window_goto_uid(pid)
			set previewwindow
		endif
		noautocmd call preview#window_goto_uid(uid)
	endif
	return pid
endfunc

" close preview window
function! preview#preview_close()
	silent pclose
endfunc

" echo error message
function! preview#errmsg(msg)
	redraw | echo '' | redraw
	echohl ErrorMsg
	echom a:msg
	echohl NONE
endfunc

" echo cmdline message
function! preview#cmdmsg(content, highlight)
	let saveshow = &showmode
	set noshowmode
    let wincols = &columns
    let statusline = (&laststatus==1 && winnr('$')>1) || (&laststatus==2)
    let reqspaces_lastline = (statusline || !&ruler) ? 12 : 29
    let width = len(a:content)
    let limit = wincols - reqspaces_lastline
	let l:content = a:content
	if width + 1 > limit
		let l:content = strpart(l:content, 0, limit - 1)
		let width = len(l:content)
	endif
	" prevent scrolling caused by multiple echo
	redraw 
	if a:highlight != 0
		echohl Type
		echo l:content
		echohl NONE
	else
		echo l:content
	endif
	if saveshow != 0
		set showmode
	endif
endfunc


"----------------------------------------------------------------------
" taglist
"----------------------------------------------------------------------
function! preview#taglist(pattern)
    let ftags = []
    try
        let ftags = taglist(a:pattern)
    catch /^Vim\%((\a\+)\)\=:E/
        " if error occured, reset tagbsearch option and try again.
        let bak = &tagbsearch
        set notagbsearch
        let ftags = taglist(a:pattern)
        let &tagbsearch = bak
    endtry
	" take care ctags windows filename bug
	for item in ftags
		let name = get(item, 'filename', '')
		let item.baditem = 0
		if has('win32') || has('win64') || has('win16') || has('win95') 
			if stridx(name, '\\') >= 0
				let part = split(name, '\\', 1)
				let elem = []
				for n in part
					if n != ''
						let elem += [n]
					endif
				endfor
				let name = join(elem, '\')
				let item.filename = name
				if has_key(item, 'line') == 0
					if has_key(item, 'signature') == 0
						let kind = get(item, 'kind', '')
						if kind != 'p' && kind != 'f'
							let item.baditem = 1
						endif
					endif
				endif
			end
		endif
	endfor
    return ftags
endfunc


"----------------------------------------------------------------------
" easy tagname
"----------------------------------------------------------------------
function! preview#tagfind(tagname)
	let pattern = escape(a:tagname, '[\*~^')
	let result = preview#taglist("^". pattern . "$")
	if type(result) == 0 || (type(result) == 3 && result == [])
		if pattern !~ '^\(catch\|if\|for\|while\|switch\)$'
			let result = preview#taglist('::'. pattern .'$')
		endif
	endif
	if type(result) == 0 || (type(result) == 3 && result == [])
		return []
	endif
	let final = []
	let check = {}
	for item in result
		if item.baditem != 0
			continue
		endif
		" remove duplicated tags
		let signature = get(item, 'name', '') . ':'
		let signature .= get(item, 'cmd', '') . ':'
		let signature .= get(item, 'kind', '') . ':'
		let signature .= get(item, 'line', '') . ':'
		let signature .= get(item, 'filename', '')
		if !has_key(check, signature)
			let final += [item]
			let check[signature] = 1
		endif
	endfor
	return final
endfunc


"----------------------------------------------------------------------
" highlight name
"----------------------------------------------------------------------
if !exists('g:preview#highlight')
	let g:preview#highlight = 'Search'
endif


"----------------------------------------------------------------------
" display matched tag in the preview window
"----------------------------------------------------------------------
function! preview#preview_tag(tagname)
	if &previewwindow
		return 0
	endif
	let uid = preview#window_uid('%', '%')
	let pid = preview#preview_check()
	let opt = {"tagname":""}
	let varname = 'preview_preview_tag_cache'
	let reuse = 0
	let index = 0
	if pid > 0
		let [l:tabnr, l:winnr] = preview#window_find(pid)
		let saveopt = gettabwinvar(l:tabnr, l:winnr, varname)
		if type(saveopt) == type({})
			let l:tagname = get(saveopt, 'tagname', '')
			if l:tagname == a:tagname
				let opt = saveopt
				let reuse = 1
			endif
		endif
	endif
	if reuse == 0
		let opt.tagname = a:tagname
		let opt.taglist = preview#tagfind(a:tagname)
		let opt.index = 0
		if len(opt.taglist) > 0 && pid > 0
			call settabwinvar(l:tabnr, l:winnr, varname, opt)
		endif
	else
		let opt.index += 1
		if opt.index >= len(opt.taglist)
			let opt.index = 0
		endif
	endif
	if len(opt.taglist) == 0 
		call preview#errmsg('E257: preview: tag not find "'. a:tagname.'"')
		return 1
	endif
	if opt.index >= len(opt.taglist)
		call preview#errmsg('E257: preview: index error')
		return 2
	endif
	let taginfo = opt.taglist[opt.index]
	let filename = taginfo.filename
	if !filereadable(filename)
		call preview#errmsg('E484: Can not open file '.filename)
		return 3
	endif
	if pid == 0
		let pid = preview#preview_open()
		let [l:tabnr, l:winnr] = preview#window_find(pid)
	endif
	call settabwinvar(l:tabnr, l:winnr, varname, opt)
	call preview#window_goto_uid(uid)
	call preview#window_saveview()
	call preview#window_goto_tabwin(l:tabnr, l:winnr)
	silent exec 'e! '.fnameescape(filename)
	call preview#window_loadview()
	if &previewwindow
		match none
	endif
	normal! gg
	if has_key(taginfo, 'line')
		silent! exec "".taginfo.line
	elseif has_key(taginfo, 'cmd')
		silent! exec "1"
		silent! exec escape(taginfo.cmd, '*')
		silent! exec "nohl"
		" unsilent echom taginfo.cmd
	endif
	if g:preview#highlight != ''
		call search("$", "b")
		call search(escape(a:tagname, '[\*~^'))
		let cmd = 'match ' . g:preview#highlight
		exe cmd. ' "\%' . line(".") . 'l\%' . col(".") . 'c\k*"'
	endif
	call preview#window_up(0)
	call preview#window_goto_uid(uid)
	let text = taginfo.name
	let text.= ' ('.(opt.index + 1).'/'.len(opt.taglist).') '
	let text.= filename
	if has_key(taginfo, 'line')
		let text .= ':'.taginfo.line
	endif
	call preview#cmdmsg(text, 1)
endfunc


"----------------------------------------------------------------------
" display preview file
"----------------------------------------------------------------------
function! preview#preview_edit(bufnr, filename, line, cmd, nohl)
	let uid = preview#window_uid('%', '%')
	let pid = preview#preview_open()
	let [l:tabnr, l:winnr] = preview#window_find(pid)
	call preview#window_goto_tabwin(l:tabnr, l:winnr)
	call preview#window_saveview()
	if a:bufnr <= 0
		silent exec "e! ".fnameescape(a:filename)
	else
		if winbufnr('%') != a:bufnr
			silent exec "b! ".a:bufnr
		endif
	endif
	call preview#window_loadview()
	if a:line > 0
		noautocmd exec "".a:line
	endif
	if a:cmd != ''
		noautocmd exec a:cmd
	endif
	call preview#window_up((a:line > 0 || a:cmd != '') && a:nohl == 0)
	call preview#window_goto_uid(uid)
endfunc


"----------------------------------------------------------------------
" goto preview file
"----------------------------------------------------------------------
function! preview#preview_goto(cmd)
	let uid = preview#window_uid('%', '%')
	let pid = preview#preview_check()
	if pid == 0 || &previewwindow != 0 || uid == pid
		exec "norm! \<esc>"
		return
	endif
	if index(['quickfix', 'help', 'nofile'], &buftype) >= 0
		if a:mode == '' || a:mode == '0' || a:mode == '!'
			exec "norm! \<esc>"
			return
		endif
	endif
	let [l:tabnr, l:winnr] = preview#window_find(pid)
	silent! wincmd P
	let l:bufnr = winbufnr(l:winnr)
	let l:bufname = bufname(l:bufnr)
	let l:line = line('.')
	call preview#window_goto_uid(uid)
	silent exec a:cmd.' '.fnameescape(l:bufname)
	if winbufnr('%') == l:bufnr
		silent exec ''.l:line
		call preview#window_up(0)
	endif
endfunc


"----------------------------------------------------------------------
" display quickfix item in preview
"----------------------------------------------------------------------
function! preview#preview_quickfix(linenr)
	let linenr = (a:linenr > 0)? a:linenr : line('.')
	let qflist = getqflist()
	if linenr < 1 || linenr > len(qflist)
		exec "norm! \<esc>"
		return ""
	endif
	let entry = qflist[linenr - 1]
	unlet qflist
	if entry.valid
		if entry.bufnr > 0
			call preview#preview_edit(entry.bufnr, '', entry.lnum, '', 0)
			let text = 'Preview: '.bufname(entry.bufnr)
			let text.= ' ('.entry.lnum.')'
			call preview#cmdmsg(text, 1)
		else
			exec "norm! \<esc>"
		endif
	else
		exec "norm! \<esc>"
	endif
	return ""
endfunc


"----------------------------------------------------------------------
" function signature
"----------------------------------------------------------------------
function! preview#function_signature(funname, fn_only, filetype)
	let tags = preview#tagfind(a:funname)
    let funpat = escape(a:funname, '[\*~^')
	let fill_tag = []
	let ft = (a:filetype == '')? &filetype : a:filetype
	for i in tags
		if !has_key(i, 'name')
			continue
		endif
		if has_key(i, 'language')
		endif
		if has_key(i, 'filename') && ft != '*'
			let ename = tolower(fnamemodify(i.filename, ':e'))
			let c = ['c', 'cpp', 'cc', 'cxx', 'h', 'hpp', 'hh', 'm', 'mm']
			if index(['c', 'cpp', 'objc', 'objcpp'], ft) >= 0
				if index(c, ename) < 0
					continue
				endif
			elseif ft == 'python'
				if index(['py', 'pyw'], ename) < 0
					continue
				endif
			elseif ft == 'java' && ename != 'java'
				continue
			elseif ft == 'ruby' && ename != 'rb'
				continue
			elseif ft == 'vim' && ename != 'vim'
				continue
			elseif ft == 'cs' && ename != 'cs'
				continue
			elseif ft == 'php' 
				if index(['php', 'php4', 'php5', 'php6'], ename) < 0
					continue
				endif
			elseif ft == 'javascript'
				if index(['html', 'js', 'html5', 'xhtml', 'php'], ename) < 0
					continue
				endif
			endif
		endif
		if has_key(i, 'kind')
			" p: prototype/procedure; f: function; m: member
			if (a:fn_only == 0 || (i.kind == 'p' || i.kind == 'f') ||
						\ (i.kind == 'm' && has_key(i, 'cmd') &&
						\		match(i.cmd, '(') != -1)) &&
						\ i.name =~ funpat
				if ft != 'cpp' || !has_key(i, 'class') ||
							\ i.name !~ '::' || i.name =~ i.class
					let fill_tag += [i]
				endif
			endif
		else
			if a:fn_only == 0 && i.name == a:funname
				let fill_tag += [i]
			endif
		endif
	endfor
	let res = []
	let check = {}
	for i in fill_tag
		if has_key(i, 'kind') && has_key(i, 'signature')
			if i.cmd[:1] == '/^' && i.cmd[-2:] == '$/'
				let tmppat = substitute(escape(i.name,'[\*~^'),
							\ '^.*::','','')
				if ft == 'cpp'
					let tmppat = substitute(tmppat,'\<operator ',
								\ 'operator\\s*','')
					let tmppat=tmppat . '\s*(.*'
					let tmppat='\([A-Za-z_][A-Za-z_0-9]*::\)*'.tmppat
				else
					let tmppat=tmppat . '\>.*'
				endif
				let name = substitute(i.cmd[2:-3],tmppat,'','').
							\ i.name . i.signature
				if i.kind == 'm'
					if has_key(i, 'class')
						let name = name . ' <-- class ' . i.class
					elseif has_key(i, 'struct')
						let name = name . ' <-- struct ' . i.struct
					elseif has_key(i, 'union')
						let name = name . ' <-- union ' . i.union
					endif
				endif
			else
				let name = i.name . i.signature
				if has_key(i, 'kind') && match('fm', i.kind) >= 0
					let sep = (ft == 'cpp' || ft == 'c')? '::' : '.'
					if has_key(i, 'class')
						let name = i.class . sep . name
					elseif has_key(i, 'struct')
						let name = i.struct . sep. name
					elseif has_key(i, 'union')
						let name = i.struct . sep. name
					endif
				endif
			endif
		elseif has_key(i, 'kind')
			if i.kind == 'd'
				let name = 'macro '. i.name
			elseif i.kind == 'c'
				let name = ((ft == 'vim')? 'command ' : 'class '). i.name
			elseif i.kind == 's'
				let name = 'struct '. i.name
			elseif i.kind == 'u'
				let name = 'union '. i.name
			elseif (match('fpmvt', i.kind) != -1) &&
						\(has_key(i, 'cmd') && i.cmd[0] == '/')
				let tmppat = '\(\<'.i.name.'\>.\{-}\)'
				if index(['c', 'cpp', 'cs', 'java', 'javascript'], ft) >= 0
					" let tmppat = tmppat . ';.*'
				elseif ft == 'python' && (i.kind == 'm' || i.kind == 'f')
					let tmppat = tmppat . ':.*'
				elseif ft == 'tcl' && (i.kind == 'm' || i.kind == 'p')
					let tmppat = tmppat . '\({\)\?$'
				endif
				if i.kind == 'm' && &filetype == 'cpp'
					let tmppat=substitute(tmppat,'^\(.*::\)','\\(\1\\)\\?','')
				endif
				if match(i.cmd[2:-3], tmppat) != -1
					let name=substitute(i.cmd[2:-3], tmppat, '\1', '')
					if i.kind == 't' && name !~ '^\s*typedef\>'
						let name = 'typedef ' . i.name
					endif
				elseif i.kind == 't'
					let name = 'typedef ' . i.name
				elseif i.kind == 'v'
					let name = 'var ' . i.name
				else
					let name = i.name
				endif
				if i.kind == 'm'
					if has_key(i, 'class')
						let name = name . ' <-- class ' . i.class
					elseif has_key(i, 'struct')
						let name = name . ' <-- struct ' . i.struct
					elseif has_key(i, 'union')
						let name = name . ' <-- union ' . i.union
					endif
				endif
				let name = substitute(name, '^\s*\(.\{-}\)\s*$', '\1', '')
				if name[-1:] == ';'
					let name = name[0:-2]
				endif
			else
				let name = i.name
			endif
		else
			let name = i.name
		endif
		let name = substitute(name, '^\s\+', '', '')
		let name = substitute(name, '\s\+$', '', '')
		let name = substitute(name, '\s\+', ' ', 'g')
		let i.func_prototype = name
		let file_line = ''
		if has_key(i, 'filename')
			let file_line = fnamemodify(i.filename, ':t')
			if has_key(i, 'line')
				let file_line .= ':'. i.line
			elseif i.cmd > 0
				let file_line .= ':'. i.cmd
			endif
		endif
		let i.file_line = file_line
		let key = name . ':' . file_line
		if !has_key(check, key)
			let check[key] = 1
			let res += [i]
		endif
	endfor
	let result = []
	let index = 1
	for i in res
		let name = i.func_prototype
		let file_line = i.file_line
		let desc = name. ' ('.index.'/'.len(res).') '.file_line
		let result += [desc]
		let index += 1
	endfor
	return result
endfunc


"----------------------------------------------------------------------
" function name normalize
"----------------------------------------------------------------------

" get function name
function! preview#function_name(text)
    let name = substitute(a:text,'.\{-}\(\(\k\+::\)*\(\~\?\k*\|'.
                \'operator\s\+new\(\[]\)\?\|'.
                \'operator\s\+delete\(\[]\)\?\|'.
                \'operator\s*[[\]()+\-*/%<>=!~\^&|]\+'.
                \'\)\)\s*$','\1','')
    if name =~ '\<operator\>'  " tags have exactly one space after 'operator'
        let name = substitute(name,'\<operator\s*','operator ','')
    endif
    return name
endfunc

" guess function names
function! preview#function_guess(text)
	let size = len(a:text)
	while size > 0
		if index(['(', ')', ',', ' ', "\t"], a:text[size - 1]) >= 0
			let size -= 1
		else
			break
		endif
	endwhile
	let limit = (size == 0)? 0 : size - 1
	return preview#function_name(a:text[0:limit])
endfunc


"----------------------------------------------------------------------
" function next 
"----------------------------------------------------------------------
function! preview#function_prototype(funcname, filetype)
	let ft = (a:filetype == '')? &filetype : a:filetype
	if !exists('w:preview_prototype_cache')
		let w:preview_prototype_cache = { 'name': '', 'index': 0, 'data': [] }
		let w:preview_prototype_cache.ft = ''
	endif
	let proto = w:preview_prototype_cache
	if proto.name != a:funcname || proto.ft != ft
		let res = preview#function_signature(a:funcname, 0, ft)
		let proto.data = res
		let proto.index = 0
		let proto.name = a:funcname
		let proto.ft = ft
		let w:preview_prototype_cache = proto
	endif
	if len(proto.data) == 0
		unlet w:preview_prototype_cache
		return ''
	endif
	let text = proto.data[proto.index]
	let text = substitute(text, '^\s*', '', '')
	let proto.index += 1
	if proto.index >= len(proto.data)
		let proto.index = 0
		unlet w:preview_prototype_cache
	endif
	return text
endfunc


"----------------------------------------------------------------------
" prototype 
"----------------------------------------------------------------------
function! preview#function_define(name)
	let line = getline('.')
	let pos = col('.') - 1
	let endpos = match(line, '\W', pos)
	if endpos != -1 && &filetype == 'cpp'
		let word = expand('<cword>')
		if word == 'operator'
			if line[endpos:] =~ '^\s*\(new\(\[]\)\?\|delete\(\[]\)\?\|[[\]'
						\.'+\-*/%<>=!~\^&|]\+\|()\)'
				let endpos = matchend(line, '^\s*\(new\(\[]\)\?\|delete\(\['
							\.']\)\?\|[[\]+\-*/%<>=!~\^&|]\+\|()\)', endpos)
			endif
		elseif word == 'new' || word == 'delete'
            if line[:endpos + 1] =~ 'operator\s\+\(new\|delete\)\[]$'
				let endpos = endpos + 2
			endif
		endif
	endif
	if endpos != -1
		let endpos = endpos - 1
	endif
	if a:name == ''
		let name = preview#function_guess(line[0:endpos])
	elseif a:name == '<?>'
		let name = expand('<cword>')
	else
		let name = a:name
	endif
	if name == ''
		return ''
	endif
	return preview#function_prototype(name, &filetype)
endfunc

" function preview
function! preview#function_echo(name, nosc)
	let text = preview#function_define(a:name)
	if text == ''
		return ''
	endif
	if a:nosc != 0
		set noshowmode
	endif
	call preview#cmdmsg(text, 1)
	return ''
endfunc

" scroll previous window
function! preview#previous_scroll(offset)
	if winnr('$') <= 1
		return
	endif
	noautocmd silent! wincmd p
	if a:offset == 1
		exec "normal! \<c-d>"
	elseif a:offset == -1
		exec "normal! \<c-u>"
	elseif a:offset >= 2
		exec "normal! \<c-f>"
	elseif a:offset <= -2
		exec "normal! \<c-b>"
	endif
	noautocmd silent! wincmd p
endfunc

" scroll preview window
function! preview#preview_scroll(offset)
	let uid = preview#window_uid('%', '%')
	let pid = preview#preview_check()
	if pid <= 0
		exec "norm! \<esc>"
		return
	endif
	if uid != pid
		noautocmd wincmd P
	endif
	if &previewwindow != 0
		if a:offset == 1
			exec "normal! \<c-d>"
		elseif a:offset == -1
			exec "normal! \<c-u>"
		elseif a:offset >= 2
			exec "normal! \<c-f>"
		elseif a:offset <= -2
			exec "normal! \<c-b>"
		endif
	endif
	if uid != pid
		noautocmd wincmd p
	endif
endfunc


