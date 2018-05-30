"======================================================================
"
" init.vim - initialize config
"
" Created by skywind on 2018/05/30
" Last Modified: 2018/05/30 18:26:34
"
"======================================================================

" 取得本文件所在的目录
let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h')

" 定义一个命令用来加载文件
command! -nargs=1 InitScript exec 'so '.s:home.'/'.'<args>'

" 将本目录加入 runtimepath
exec 'set rtp+='.s:home

" 加载配置文件
InitScript init/init-basic.vim
InitScript init/init-keymaps.vim


