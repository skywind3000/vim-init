" set leader key
let mapleader=" "


" use EMACS keymap in insert mode
inoremap <c-a> <home>
inoremap <c-e> <end>
inoremap <c-d> <del>
inoremap <c-_> <c-k>


" in insert mode, move cursor using alt
inoremap <m-l> <right>
inoremap <m-k> <up>
inoremap <m-j> <down>
inoremap <m-h> <left>


" enhenced alt key moving
noremap <m-j> gj
noremap <m-k> gk
cnoremap <m-h> <c-left>
cnoremap <m-l> <c-right>


" switch windows using alt + shift + hjkl
noremap <m-H> <c-w>h
noremap <m-L> <c-w>l
noremap <m-J> <c-w>j
noremap <m-K> <c-w>k
inoremap <m-H> <c-w>h
inoremap <m-L> <c-w>l
inoremap <m-J> <c-w>j
inoremap <m-K> <c-w>k


" scroll side window using alt key
inoremap <m-j> <Down>
inoremap <m-k> <Up>
inoremap <m-l> <Right>
inoremap <m-h> <Left>

" copy and paste
imap <c-v> <c-r><c-p>*
vmap <c-c> "+y

" fast open with leader key



" fast move in command mode
" cnoremap <c-h> <left>
" cnoremap <c-j> <down>
" cnoremap <c-k> <up>
" cnoremap <c-l> <right>
" cnoremap <c-a> <home>
" cnoremap <c-e> <end>
" cnoremap <c-f> <c-d>
" cnoremap <c-b> <left>
" cnoremap <c-d> <del>
" cnoremap <c-_> <c-k>


" <leader> + number key to switch tab
noremap <silent><leader>1 1gt<cr>
noremap <silent><leader>2 2gt<cr>
noremap <silent><leader>3 3gt<cr>
noremap <silent><leader>4 4gt<cr>
noremap <silent><leader>5 5gt<cr>
noremap <silent><leader>6 6gt<cr>
noremap <silent><leader>7 7gt<cr>
noremap <silent><leader>8 8gt<cr>
noremap <silent><leader>9 9gt<cr>
noremap <silent><leader>0 10gt<cr>


" defined in unimpaired, switch buffer using <leader>
noremap <silent> <leader>bn :bn<cr>
noremap <silent> <leader>bp :bp<cr>


" use <leader> to manage tab
noremap <silent> <leader>tc :tabnew<cr>
noremap <silent> <leader>tq :tabclose<cr>
noremap <silent> <leader>tn :tabnext<cr>
noremap <silent> <leader>tp :tabprev<cr>
noremap <silent> <leader>to :tabonly<cr>


" 左移 tab
function! Tab_MoveLeft()
	let l:tabnr = tabpagenr() - 2
	if l:tabnr >= 0
		exec 'tabmove '.l:tabnr
	endif
endfunc

" 右移 tab
function! Tab_MoveRight()
	let l:tabnr = tabpagenr() + 1
	if l:tabnr <= tabpagenr('$')
		exec 'tabmove '.l:tabnr
	endif
endfunc


" switch tab
nnoremap <tab> gt

noremap <silent><leader>tl :call Tab_MoveLeft()<cr>
noremap <silent><leader>tr :call Tab_MoveRight()<cr>
noremap <silent><m-left> :call Tab_MoveLeft()<cr>
noremap <silent><m-right> :call Tab_MoveRight()<cr>


" map Esc key `^
inoremap jk <Esc>


" close buffer without closing window
command! Bd :bp | :sp | :bn | :bd


" quick nohighlight
nnoremap <silent> <c-L> :noh<cr>

" compile and run C/C++ project

" 自动打开 quickfix window ，高度为 6
let g:asyncrun_open = 6

" 任务结束时候响铃提醒
let g:asyncrun_bell = 0

" 设置 F10 打开/关闭 Quickfix 窗口
nnoremap <F10> :call asyncrun#quickfix_toggle(6)<cr>

" F9 编译 C/C++ 文件
nnoremap <silent> <F9> :AsyncRun g++ -Wall -O2 "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>

" F5 运行文件
nnoremap <silent> <F5> :call ExecuteFile()<cr>

" F7 编译项目
nnoremap <silent> <F7> :AsyncRun -cwd=<root> make <cr>

" F8 运行项目
nnoremap <silent> <F8> :AsyncRun -cwd=<root> -raw make run <cr>

" F6 测试项目
nnoremap <silent> <F6> :AsyncRun -cwd=<root> -raw make test <cr>

" 更新 cmake
nnoremap <silent> <F4> :AsyncRun -cwd=<root> cmake . <cr>

" Windows 下支持直接打开新 cmd 窗口运行
if has('win32') || has('win64')
	nnoremap <silent> <F8> :AsyncRun -cwd=<root> -mode=4 make run <cr>
endif


"----------------------------------------------------------------------
" F5 运行当前文件：根据文件类型判断方法，并且输出到 quickfix 窗口
"----------------------------------------------------------------------
function! ExecuteFile()
	let cmd = ''
	if index(['c', 'cpp', 'rs', 'go'], &ft) >= 0
		" native 语言，把当前文件名去掉扩展名后作为可执行运行
		" 写全路径名是因为后面 -cwd=? 会改变运行时的当前路径，所以写全路径
		" 加双引号是为了避免路径中包含空格
		let cmd = '"$(VIM_FILEDIR)/$(VIM_FILENOEXT)"'
	elseif &ft == 'python'
		let $PYTHONUNBUFFERED=1 " 关闭 python 缓存，实时看到输出
		let cmd = 'python "$(VIM_FILEPATH)"'
	elseif &ft == 'javascript'
		let cmd = 'node "$(VIM_FILEPATH)"'
	elseif &ft == 'perl'
		let cmd = 'perl "$(VIM_FILEPATH)"'
	elseif &ft == 'ruby'
		let cmd = 'ruby "$(VIM_FILEPATH)"'
	elseif &ft == 'php'
		let cmd = 'php "$(VIM_FILEPATH)"'
	elseif &ft == 'lua'
		let cmd = 'lua "$(VIM_FILEPATH)"'
	elseif &ft == 'zsh'
		let cmd = 'zsh "$(VIM_FILEPATH)"'
	elseif &ft == 'ps1'
		let cmd = 'powershell -file "$(VIM_FILEPATH)"'
	elseif &ft == 'vbs'
		let cmd = 'cscript -nologo "$(VIM_FILEPATH)"'
	elseif &ft == 'sh'
		let cmd = 'bash "$(VIM_FILEPATH)"'
	else
		return
	endif
	" Windows 下打开新的窗口 (-mode=4) 运行程序，其他系统在 quickfix 运行
	" -raw: 输出内容直接显示到 quickfix window 不匹配 errorformat
	" -save=2: 保存所有改动过的文件
	" -cwd=$(VIM_FILEDIR): 运行初始化目录为文件所在目录
	if has('win32') || has('win64')
		exec 'AsyncRun -cwd=$(VIM_FILEDIR) -raw -save=2 -mode=0 '. cmd
	else
		exec 'AsyncRun -cwd=$(VIM_FILEDIR) -raw -save=2 -mode=0 '. cmd
	endif
endfunc



"----------------------------------------------------------------------
" F2 在项目目录下 Grep 光标下单词，默认 C/C++/Py/Js ，扩展名自己扩充
" 支持 rg/grep/findstr ，其他类型可以自己扩充
" 不是在当前目录 grep，而是会去到当前文件所属的项目目录 project root
" 下面进行 grep，这样能方便的对相关项目进行搜索
"----------------------------------------------------------------------
if executable('rg')
	noremap <silent><F2> :AsyncRun! -cwd=<root> rg -n --no-heading 
				\ --color never -g *.h -g *.c* -g *.py -g *.js -g *.vim 
				\ <C-R><C-W> "<root>" <cr>
elseif has('win32') || has('win64')
	noremap <silent><F2> :AsyncRun! -cwd=<root> findstr /n /s /C:"<C-R><C-W>" 
				\ "\%CD\%\*.h" "\%CD\%\*.c*" "\%CD\%\*.py" "\%CD\%\*.js"
				\ "\%CD\%\*.vim"
				\ <cr>
else
	noremap <silent><F2> :AsyncRun! -cwd=<root> grep -n -s -R <C-R><C-W> 
				\ --include='*.h' --include='*.c*' --include='*.py' 
				\ --include='*.js' --include='*.vim'
				\ '<root>' <cr>
endif
