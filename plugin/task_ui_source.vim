"======================================================================
"
" task_ui_source.vim - 
"
" Created by skywind on 2021/12/30
" Last Modified: 2021/12/30 09:18:05
"
"======================================================================


"----------------------------------------------------------------------
" utils
"----------------------------------------------------------------------
function! s:errmsg(msg)
	redraw
	echohl ErrorMsg
	echom 'ERROR: ' . a:msg
	echohl NONE
	return 0
endfunction

function! s:strip(text)
	return substitute(a:text, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction


"----------------------------------------------------------------------
" For LeaderF
"----------------------------------------------------------------------
function! s:lf_task_source(...)
	let rows = asynctasks#source(&columns * 48 / 100)
	let source = []
	for row in rows
		let name = row[0]
		let source += [name . '  ' . row[1] . '  : ' . row[2]]
	endfor
	return source
endfunc

function! s:lf_task_accept(line, arg)
	let pos = stridx(a:line, '<')
	if pos < 0
		return
	endif
	let name = strpart(a:line, 0, pos)
	let name = substitute(name, '^\s*\(.\{-}\)\s*$', '\1', '')
	redraw
	if name != ''
		exec "AsyncTask " . name
	endif
endfunc

function! s:lf_task_digest(line, mode)
	let pos = stridx(a:line, '<')
	if pos < 0
		return [a:line, 0]
	endif
	let name = strpart(a:line, 0, pos)
	return [name, 0]
endfunc

function! s:lf_win_init(...)
	setlocal nonumber
	setlocal nowrap
endfunc


let g:Lf_Extensions = get(g:, 'Lf_Extensions', {})
let g:Lf_Extensions.tasks = {
			\ 'source': string(function('s:lf_task_source'))[10:-3],
			\ 'accept': string(function('s:lf_task_accept'))[10:-3],
			\ 'get_digest': string(function('s:lf_task_digest'))[10:-3],
			\ 'highlights_def': {
			\     'Lf_hl_funcScope': '^\S\+',
			\     'Lf_hl_funcDirname': '^\S\+\s*\zs<\(.\{-}\)>\ze\s*:',
			\     'Lf_hl_buftagCode': '^\S\+\s*<\(.\{-}\)>\s*\zs:.*$',
			\ },
			\ 'after_enter': string(function('s:lf_win_init'))[10:-3],
			\ 'help' : 'navigate available tasks from asynctasks.vim',
		\ }


"----------------------------------------------------------------------
" FZF
"----------------------------------------------------------------------
function! s:fzf_sink(what)
	let p1 = stridx(a:what, '<')
	if p1 >= 0
		let name = strpart(a:what, 0, p1)
		let name = substitute(name, '^\s*\(.\{-}\)\s*$', '\1', '')
		if name != ''
			exec "AsyncTask ". fnameescape(name)
		endif
	endif
endfunction

function! s:fzf_task()
	let rows = asynctasks#source(&columns * 48 / 100)
	let source = []
	for row in rows
		let name = row[0]
		let source += [name . '  ' . row[1] . '  : ' . row[2]]
	endfor
	let opts = { 'source': source, 'sink': function('s:fzf_sink'),
				\ 'options': '+m --nth 1 --inline-info --tac' }
	if exists('g:fzf_layout')
		for key in keys(g:fzf_layout)
			let opts[key] = deepcopy(g:fzf_layout[key])
		endfor
	endif
	call fzf#run(opts)
endfunction


"----------------------------------------------------------------------
" vim-clap
"----------------------------------------------------------------------
let g:clap_provider_tasks = {}
let g:clap_provider_tasks.description = 'Navigate available tasks from asynctasks.vim'
let g:clap_provider_tasks.preview = 0
let g:clap_provider_tasks.syntax = 'clap_tasks'

function! g:clap_provider_tasks.source() abort
	let rows = asynctasks#source(&columns * 48 / 100)
	let source = []
	for row in rows
		let name = row[0]
		let source += [name . '  ' . row[1] . '  : ' . row[2]]
	endfor
	return source
endfunc

function! g:clap_provider_tasks.sink(what)
	let p1 = stridx(a:what, '<')
	if p1 >= 0
		let name = strpart(a:what, 0, p1)
		let name = substitute(name, '^\s*\(.\{-}\)\s*$', '\1', '')
		if name != ''
			exec "AsyncTask ". fnameescape(name)
		endif
	endif
endfunc

function! g:clap_provider_tasks.on_move()
	let curline = g:clap.display.getcurline()
	let p1 = stridx(curline, '<')
	if p1 >= 0
		let name = strpart(curline, 0, p1)
		let name = substitute(name, '^\s*\(.\{-}\)\s*$', '\1', '')
		let text = asynctasks#content('', name)
		if text != ''
			call g:clap.preview.show(split(text, '\n'))
		endif
	endif
endfunc


"----------------------------------------------------------------------
" finder: list
"----------------------------------------------------------------------
function! s:finder_list()
	let rows = asynctasks#source(&columns * 45 / 100)
	let source = []
	let index = 1
	let fmt = '%' . len(len(rows)) . 'd: '
	for row in rows
		let name = printf(fmt, index) . row[0]
		let source += [name . ' ' . row[1] . '  : ' . row[2]]
		let index += 1
	endfor
	call inputsave()
	try
		let i = inputlist(source)
	catch /^Vim:Interrupt$/
		let i = 0
	endtry
	call inputrestore()
	if i > 0 && i <= len(source)
		let text = source[i - 1]
		let p1 = stridx(text, ':')
		let p2 = stridx(text, '<')
		if p1 >= 0 && p2 >= 0
			let name = strpart(text, p1 + 1, p2 - p1 - 1)
			let name = substitute(name, '^\s*\(.\{-}\)\s*$', '\1', '')
			if name != ''
				redraw
				exec 'AsyncTask ' . fnameescape(name)
				" echo name
			endif
		endif
	endif
endfunc


function! s:finder_quickui()
	let keymaps = '123456789abcdefimopqrstuvwxyz'
	let items = asynctasks#list('')
	let rows = []
	let size = strlen(keymaps)
	let index = 0
	for item in items
		if item.name =~ '^\.'
			continue
		endif
		let cmd = strpart(item.command, 0, (&columns * 60) / 100)
		let key = (index >= size)? ' ' : strpart(keymaps, index, 1)
		let text = "[" . ((key != ' ')? ('&' . key) : ' ') . "]\t"
		let text .= item.name . "\t[" . item.scope . "]\t" . cmd
		let rows += [[text, 'AsyncTask ' . fnameescape(item.name)]]
		let index += 1
	endfor
	let opts = {}
	let opts.title = 'Task List'
	" let opts.bordercolor = 'QuickTitle'
	call quickui#tools#clever_listbox('tasks', rows, opts)
endfunc


"----------------------------------------------------------------------
" choose a fuzzy finder
"----------------------------------------------------------------------
function! s:fuzzy_detect()
	let finder = []
	if exists(':Leaderf')
		let finder += ['Leaderf']
	endif
	if exists(':Clap')
		let finder += ['clap']
	endif
	if exists(':FZF')
		let finder += ['fzf']
	endif
	if exists('g:quickui_version')
		let finder += ['quickui']
	endif
	return finder
endfunc

function! s:fuzzy_finder(what)
	let name = tolower(s:strip(a:what))
	let support = []
	for avail in s:fuzzy_detect()
		let support += [tolower(avail)]
	endfor
	if len(support) == 0
		let pick = ''
	elseif name == ''
		let pick = support[0]
	elseif index(support, name) >= 0
		let pick = name
	else
		let pick = ''
	endif
	if pick == 'leaderf'
		exec 'Leaderf tasks'
	elseif pick == 'clap'
		exec 'Clap tasks'
	elseif pick == 'fzf'
		call s:fzf_task()
	elseif pick == 'quickui'
		call s:finder_quickui()
	else
		call s:finder_list()
	endif
endfunc

function! s:fuzzy_complete(ArgLead, CmdLine, CursorPos)
	let candidate = []
	let available = s:fuzzy_detect()
	for avail in available
		if stridx(tolower(avail), tolower(a:ArgLead)) == 0
			let candidate += [avail]
		endif
	endfor
	return candidate
endfunc

command! -nargs=? -range=0 -complete=customlist,s:fuzzy_complete
			\ TaskFinder call s:fuzzy_finder(<q-args>)


