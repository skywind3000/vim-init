" Startup {{{
filetype indent plugin on
" set vim on marker
augroup ft_vim
    au!
    au FileType vim setlocal foldmethod=marker
augroup END
" }}}

" Vundle {{{
filetype off
set shellslash
set rtp+=~/vimfiles/bundle/Vundle.vim
call vundle#begin('~/vimfiles/bundle')
" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'jiangmiao/auto-pairs'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'easymotion/vim-easymotion'
Plugin 'itchyny/lightline.vim'
Plugin 'preservim/nerdtree'
Plugin 'luochen1990/rainbow'
Plugin 'mg979/vim-visual-multi'
Plugin 'tpope/vim-unimpaired'
Plugin 'crusoexia/vim-dracula'
Plugin 'altercation/vim-colors-solarized'
Plugin 'wesQ3/vim-windowswap'
" Plugin 'airblade/vim-gitgutter'
Plugin 'morhetz/gruvbox'
Plugin '907th/vim-auto-save'
Plugin 'tpope/vim-dispatch'
Plugin 'preservim/nerdcommenter'
Plugin 'dense-analysis/ale'
" Plugin 'maximbaz/lightline-ale'
Plugin 'skywind3000/asyncrun.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" }}}

" General {{{

" Vim with all enhancements
source $VIMRUNTIME/vimrc_example.vim
filetype plugin indent on
" syntax on

" change working directory to file directory (if a file is opened)
cd %:p:h

set nu

" menu autocomplete below
" Enable enhanced tab autocomplete.
" set wildmenu 
" Complete till longest string, then open the wildmenu.
set wildmode=list:longest,full 

" put fragment file together
set undodir=$HOME\_vim\undodir
set directory=$HOME\_vim\swpdir
set backupdir=$HOME\_vim\backupdir

" enable alt key
set winaltkeys=no

" code folding
" set foldmethod=indent
" autocmd BufRead * normal zR
" }}}

" Lang & Encoding {{{

" Chinese encoding
" set encoding=utf-8 fileencodings=ucs-bom,utf-8,cp936
let $LANG = 'en'
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8

" }}}

" GUI {{{
if has('gui_running')
    set guifont=Consolas:h13:cANSI:qDRAFT
    colorscheme gruvbox

    " disable menu
    set guioptions-=T
   set guioptions-=m
    set guioptions-=L
    set guioptions-=r
    set guioptions-=b

    set guioptions-=e
    set nolist
endif

" }}}

" Format {{{
set autoindent
set smartindent
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set backspace=2
" }}}

" Keymap {{{
" i can try 'map' space to \ for showcmd
" and map <space><space> <leader><leader>
let mapleader=","

" run file with python
autocmd FileType python map <F5> :bo term python %<CR>
autocmd FileType python imap <F5> <esc>:bo term python %<CR>

" run file with gcc
autocmd FileType c map <F5> :!cls<CR>:!gcc %<CR>:!a.exe<CR>

inoremap jk <Esc>`^

" Fast split navigation with <Ctrl> + hjkl
noremap <c-h> <c-w><c-h>
noremap <c-j> <c-w><c-j>
noremap <c-k> <c-w><c-k>
noremap <c-l> <c-w><c-l>

" Close buffer without closing window.(using :Bd)
command! Bd :bp | :sp | :bn | :bd 

" use alt-u and alt-d to scroll winsow beside
noremap <m-u> <C-w>p<C-u><C-w>p
noremap <m-d> <C-w>p<C-d><C-w>p
noremap <m-e> <C-w>p<C-e><C-w>p
noremap <m-y> <C-w>p<C-y><C-w>p

" use alt key to move cursor in insert mode
inoremap <M-j> <Down>
inoremap <M-k> <Up>
inoremap <M-l> <Right>
inoremap <M-h> <Left>

" use alt key to resize window in normal mode
nnoremap <M-J> :resize +5<cr>
nnoremap <M-K> :resize -5<cr>
nnoremap <M-H> :vertical resize -5<cr>
nnoremap <M-L> :vertical resize +5<cr>

" use built-in Ctrl-w instead
" IDE like delete
" inoremap <M-BS> <Esc>bdea
" imap <C-BS> <C-w>
" inoremap <C-B> <Esc>ciw

map <leader>cmd :!start<cr>
" map <leader>ex :!start "explorer" %:p:h<cr>
map <leader>s :source $MYVIMRC<cr>
map <leader>e :e $VIM/_vimrc<cr>
map <leader>f :set fdm=indent<cr>

imap <C-v> <c-r><c-p>*
vmap <C-c> "+y

" easy way to add wrappings
nnoremap <M-(> ciw(<C-r>")<Esc>
nnoremap <M-'> ciw'<C-r>"'<Esc>
nnoremap <M-"> ciw"<C-r>""<Esc>
vnoremap <M-(> c(<C-r>")<Esc>
vnoremap <M-'> c'<C-r>"'<Esc>
vnoremap <M-"> c(<C-r>""<Esc>

nnoremap <silent> <leader>c} V}:call NERDComment('x', 'toggle')<CR>
nnoremap <silent> <leader>c{ V{:call NERDComment('x', 'toggle')<CR>

" duplicate line
nnoremap <M-j> yyP
nnoremap <M-k> yyp

" tab related
nnoremap <M-t> :tabe <cr>
nnoremap <Tab> gt

" easy way to do :noh
" map <silent> <leader>n :noh<cr>
nnoremap <silent> <ESC> :noh<cr>

map <silent> <leader>n :NERDTreeToggle<cr>
" }}}

" Plugin {{{

" vim auto save
let g:auto_save = 1 " enable autosave on vim startup
" let g:auto_save_events = ["InsertLeave"]

" NERDTree
" Enable NERDTree on vim startup
function! StartUp()
    if 0 == argc()
        NERDTree
    end
endfunction
auto VimEnter * call StartUp()

let NERDTreeShowBookmarks = 1

" bundle
set runtimepath^=~/vimfiles/bundle/ctrlp.vim

" nerdcommenter
let g:NERDCreateDefaultMappings = 1
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'
let g:NERDAltDelims_java = 1
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
let g:NERDToggleCheckAllLines = 1

" lightline
set laststatus=2
set noshowmode
set noruler
set cmdheight=1
set noshowcmd

let g:lightline = {
    \ 'colorscheme' : 'PaperColor',
    \}

" ale
" exec 'ALEDisable'
map <leader>a :ALEToggle<cr>
" let g:ale_sign_column_always=1
let g:ale_lint_on_text_changed = 0
let g:ale_lint_on_enter=0
let g:ale_lint_on_insert_leave=0
let b:ale_lint_on_insert_leave=0
" let g:ale_lint_on_save=0

" }}}

" Function {{{
" invoke shell{{{
" command! -complete=shellcmd -nargs=+ Shell call s:RunShellCommand(<q-args>)
" function! s:RunShellCommand(cmdline)
"   echo a:cmdline
"   let expanded_cmdline = a:cmdline
"   for part in split(a:cmdline, ' ')
"      if part[0] =~ '\v[%#<]'
"         let expanded_part = fnameescape(expand(part))
"         let expanded_cmdline = substitute(expanded_cmdline, part, expanded_part, '')
"      endif
"   endfor
"   botright new
"   setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
"   call setline(1, 'You entered:    ' . a:cmdline)
"   call setline(2, 'Expanded Form:  ' .expanded_cmdline)
"   call setline(3,substitute(getline(2),'.','=','g'))
"   execute '$read !'. expanded_cmdline
"   setlocal nomodifiable
"   1
" endfunction

" command! -complete=file -nargs=* Git call s:RunShellCommand('git '.<q-args>)

" :Git add %
" }}}

" use diff {{{
" Use the internal diff if available.
" Otherwise use the special 'diffexpr' for Windows.
if &diffopt !~# 'internal'
  set diffexpr=MyDiff()
endif
function MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg1 = substitute(arg1, '!', '\!', 'g')
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg2 = substitute(arg2, '!', '\!', 'g')
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let arg3 = substitute(arg3, '!', '\!', 'g')
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      if empty(&shellxquote)
        let l:shxq_sav = ''
        set shellxquote&
      endif
      let cmd = '"' . $VIMRUNTIME . '\diff"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  let cmd = substitute(cmd, '!', '\!', 'g')
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3
  if exists('l:shxq_sav')
    let &shellxquote=l:shxq_sav
  endif
endfunction
" }}}

" " mouse scroll{{{
" let s:term_pos = {} " { bufnr: [winheight, n visible lines] }
"
" function! EnterTerminalNormalMode()
"     if &buftype != 'terminal' || mode('') != 't'
"         return 0
"     endif
"     call feedkeys("\<LeftMouse>\<c-w>N", "x")
"     let s:term_pos[bufnr()] = [winheight(winnr()), line('$') - line('w0')]
"     call feedkeys("\<ScrollWheelUp>")
" endfunction
"
" function! ExitTerminalNormalModeIfBottom()
"     if &buftype != 'terminal' || !(mode('') == 'n' || mode('') == 'v')
"         return 0
"     endif
"     let term_pos = s:term_pos[bufnr()]
"     let vis_lines = line('$') - line('w0')
"     let vis_empty = winheight(winnr()) - vis_lines
"     " if size has only expanded, match visible lines on entry
"     if term_pos[1] <= winheight(winnr())
"         let req_vis = min([winheight(winnr()), term_pos[1]])
"         if vis_lines <= req_vis | call feedkeys("i", "x") | endif
"     " if size has shrunk, match visible empty lines on entry
"     else
"         let req_vis_empty = term_pos[0] - term_pos[1]
"         let req_vis_empty = min([winheight(winnr()), req_vis_empty])
"         if vis_empty >= req_vis_empty | call feedkeys("i", "x") | endif
"     endif
" endfunction
"
" " scrolling up enters normal mode in terminal window, scrolling back to
" " the cursor's location upon entry resumes terminal mode. only limitation
" " is that terminal window must have focus before you can scroll to
" " enter normal mode
" tnoremap <silent> <ScrollWheelUp> <c-w>:call EnterTerminalNormalMode()<CR>
" nnoremap <silent> <ScrollWheelDown> <ScrollWheelDown>:call ExitTerminalNormalModeIfBottom()
" " }}}

" }}}
