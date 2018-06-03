if exists('b:current_syntax')
endif

let s:padding_left = repeat(' ', get(g:, 'quickmenu_padding_left', 3))

syntax sync fromstart

if exists('b:quickmenu.option_lines')
	let s:col = len(s:padding_left) + 4
	for line in b:quickmenu.option_lines
		exec 'syntax region QuickmenuOption start=/\%'. line .
				\ 'l'.''. '/ end=/$/'
	endfor
endif

execute 'syntax match QuickmenuBracket /.*\%'. (len(s:padding_left) + 5) .'c/ contains=
      \ QuickmenuNumber,
      \ QuickmenuSelect'

syntax match QuickmenuNumber  /^\s*\[\zs[^BSVT]\{-}\ze\]/
syntax match QuickmenuSelect  /^\s*\[\zs[BSVT]\{-}\ze\]/
syntax match QuickmenuSpecial /\V<close>\|<quit>/


if exists('b:quickmenu.section_lines')
	for line in b:quickmenu.section_lines
		exec 'syntax region QuickmenuSection start=/\%'. line .'l/ end=/$/'
	endfor
endif

if exists('b:quickmenu.text_lines')
	for line in b:quickmenu.text_lines
		exec 'syntax region QuickmenuText start=/\%'. line .'l/ end=/$/'
	endfor
endif

if exists('b:quickmenu.header_lines')
	for line in b:quickmenu.header_lines
		exec 'syntax region QuickmenuHeader start=/\%'. line .'l/ end=/$/'
	endfor
endif




function! s:hllink(name, dest, alternative)
	let tohl = a:dest
	if hlexists(a:alternative)
		let tohl = a:alternative
	endif
	if v:version < 508
		exec "hi link ".a:name.' '.tohl
	else
		exec "hi def link ".a:name.' '.tohl
	endif
endfunc

command! -nargs=* HighLink call s:hllink(<f-args>)


HighLink	QuickmenuBracket		Delimiter	StartifyBracket
HighLink	QuickmenuSection		Statement	StartifySection
HighLink	QuickmenuSelect			Title		StartifySelect
HighLink	QuickmenuNumber			Number		StartifyNumber
HighLink	QuickmenuSpecial		Comment		StartifySpecial
HighLink	QuickmenuHeader			Title		StartifyHeader
HighLink	QuickmenuOption			Identifier  StartifyFile
HighLink	QuickmenuHelp			Comment 	StartifySpecial	

