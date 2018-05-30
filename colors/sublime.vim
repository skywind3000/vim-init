" File:       monokai.vim
" Maintainer: Erich Gubler (erichdongubler)
" URL:        https://github.com/erichdongubler/vim-sublime-monokai
" License:    MIT

" Initialisation

if !has('gui_running') && &t_Co < 256
  finish
endif

if !exists('g:monokai_gui_italic')
    let g:monokai_gui_italic = 1
endif

if !exists('g:monokai_term_italic')
    let g:monokai_term_italic = 0
endif

let g:monokai_termcolors = 256 " does not support 16 color term right now.

set background=dark
hi clear

if exists('syntax_on')
  syntax reset
endif

let colors_name = 'monokai'

fun! s:h(group, style)
  let s:ctermformat = 'NONE'
  let s:guiformat = 'NONE'
  if has_key(a:style, 'format')
    let s:ctermformat = a:style.format
    let s:guiformat = a:style.format
  endif
  if g:monokai_term_italic == 0
    let s:ctermformat = substitute(s:ctermformat, ',italic', '', '')
    let s:ctermformat = substitute(s:ctermformat, 'italic,', '', '')
    let s:ctermformat = substitute(s:ctermformat, 'italic', '', '')
  endif
  if g:monokai_gui_italic == 0
    let s:guiformat = substitute(s:guiformat, ',italic', '', '')
    let s:guiformat = substitute(s:guiformat, 'italic,', '', '')
    let s:guiformat = substitute(s:guiformat, 'italic', '', '')
  endif
  if g:monokai_termcolors == 16
    let l:ctermfg = (has_key(a:style, 'fg') ? a:style.fg.cterm16 : 'NONE')
    let l:ctermbg = (has_key(a:style, 'bg') ? a:style.bg.cterm16 : 'NONE')
  else
    let l:ctermfg = (has_key(a:style, 'fg') ? a:style.fg.cterm : 'NONE')
    let l:ctermbg = (has_key(a:style, 'bg') ? a:style.bg.cterm : 'NONE')
  end
  execute 'highlight' a:group
    \ 'guifg='   (has_key(a:style, 'fg')      ? a:style.fg.gui   : 'NONE')
    \ 'guibg='   (has_key(a:style, 'bg')      ? a:style.bg.gui   : 'NONE')
    \ 'guisp='   (has_key(a:style, 'sp')      ? a:style.sp.gui   : 'NONE')
    \ 'gui='     (!empty(s:guiformat) ? s:guiformat   : 'NONE')
    \ 'ctermfg=' . l:ctermfg
    \ 'ctermbg=' . l:ctermbg
    \ 'cterm='   (!empty(s:ctermformat) ? s:ctermformat   : 'NONE')
endfunction

" Expose the more complicated style setting via a global function
fun! g:SublimeMonokaiHighlight(group, style)
	return s:h(a:group, a:style)
endfun

" Palette

" Convenience function to have a convenient script variable name and an
" namespaced global variable
fun! s:create_palette_color(color_name, color_data)
	exec 'let s:' . a:color_name . ' = a:color_data'
	exec 'let g:sublime_monokai_' . a:color_name . ' = a:color_data'
endf

call s:create_palette_color('brightwhite',  { 'gui': '#FFFFFF', 'cterm': '231' })
call s:create_palette_color('white',        { 'gui': '#E8E8E3', 'cterm': '252' })
call s:create_palette_color('black',        { 'gui': '#272822', 'cterm': '234' })
call s:create_palette_color('lightblack',   { 'gui': '#2D2E27', 'cterm': '235' })
call s:create_palette_color('lightblack2',  { 'gui': '#383a3e', 'cterm': '236' })
call s:create_palette_color('darkblack',    { 'gui': '#211F1C', 'cterm': '233' })
call s:create_palette_color('grey',         { 'gui': '#8F908A', 'cterm': '243' })
call s:create_palette_color('lightgrey',    { 'gui': '#575b61', 'cterm': '237' })
call s:create_palette_color('darkgrey',     { 'gui': '#64645e', 'cterm': '239' })
call s:create_palette_color('warmgrey',     { 'gui': '#75715E', 'cterm': '59'  })

call s:create_palette_color('pink',         { 'gui': '#f92772', 'cterm': '197' })
call s:create_palette_color('green',        { 'gui': '#a6e22d', 'cterm': '148' })
call s:create_palette_color('aqua',         { 'gui': '#66d9ef', 'cterm': '81'  })
call s:create_palette_color('yellow',       { 'gui': '#e6db74', 'cterm': '186' })
call s:create_palette_color('orange',       { 'gui': '#fd9720', 'cterm': '208' })
call s:create_palette_color('purple',       { 'gui': '#ae81ff', 'cterm': '141' })
call s:create_palette_color('red',          { 'gui': '#e73c50', 'cterm': '196' })
call s:create_palette_color('darkred',      { 'gui': '#5f0000', 'cterm': '52'  })

call s:create_palette_color('addfg',        { 'gui': '#d7ffaf', 'cterm': '193' })
call s:create_palette_color('addbg',        { 'gui': '#5f875f', 'cterm': '65'  })
call s:create_palette_color('delbg',        { 'gui': '#f75f5f', 'cterm': '167' })
call s:create_palette_color('changefg',     { 'gui': '#d7d7ff', 'cterm': '189' })
call s:create_palette_color('changebg',     { 'gui': '#5f5f87', 'cterm': '60'  })

" Expose the foreground colors of the Sublime palette as a bunch of
" highlighting groups. This lets us (and users!) get tab completion for the `hi
" link` command, and use more semantic names for the colors we want to assign
" to groups

call s:h('SublimeBrightWhite', { 'fg': s:brightwhite })
call s:h('SublimeWhite',       { 'fg': s:white        })
call s:h('SublimeBlack',       { 'fg': s:black        })
call s:h('SublimeLightBlack',  { 'fg': s:lightblack   })
call s:h('SublimeLightBlack2', { 'fg': s:lightblack2  })
call s:h('SublimeDarkBlack',   { 'fg': s:darkblack    })
call s:h('SublimeGrey',        { 'fg': s:grey         })
call s:h('SublimeLightGrey',   { 'fg': s:lightgrey    })
call s:h('SublimeDarkGrey',    { 'fg': s:darkgrey     })
call s:h('SublimeWarmGrey',    { 'fg': s:warmgrey     })

call s:h('SublimePink',        { 'fg': s:pink         })
call s:h('SublimeGreen',       { 'fg': s:green        })
call s:h('SublimeAqua',        { 'fg': s:aqua         })
call s:h('SublimeYellow',      { 'fg': s:yellow       })
call s:h('SublimeOrange',      { 'fg': s:orange       })
call s:h('SublimePurple',      { 'fg': s:purple       })
call s:h('SublimeRed',         { 'fg': s:red          })
call s:h('SublimeDarkRed',     { 'fg': s:darkred      })

" Default highlight groups (see ':help highlight-default' or http://vimdoc.sourceforge.net/htmldoc/syntax.html#highlight-groups)

hi! link ColorColumn SublimeLightBlack
hi! link Conceal SublimeLightGrey
call s:h('CursorLine',   { 'bg': s:lightblack2                                                })
call s:h('CursorLineNr', { 'fg': s:orange,     'bg': s:lightblack                             })
call s:h('DiffAdd',      { 'fg': s:addfg,      'bg': s:addbg                                  })
call s:h('DiffChange',   { 'fg': s:changefg,   'bg': s:changebg                               })
call s:h('DiffDelete',   { 'fg': s:black,      'bg': s:delbg                                  })
call s:h('DiffText',     { 'fg': s:black,      'bg': s:aqua                                   })
hi! link Directory SublimeAqua
call s:h('ErrorMsg',     { 'fg': s:black,      'bg': s:red,          'format': 'standout'     })
hi! link FoldColumn SublimeDarkBlack
call s:h('Folded',       { 'fg': s:warmgrey,   'bg': s:darkblack                              })
call s:h('Incsearch',    {                                                                    })
call s:h('LineNr',       { 'fg': s:grey,       'bg': s:lightblack                             })
call s:h('MatchParen',   { 'format': 'reverse'                                                })
hi! link ModeMsg SublimeYellow
hi! link MoreMsg SublimeYellow
hi! link NonText SublimeLightGrey
call s:h('Normal',       { 'fg': s:white,      'bg': s:black                                  })
call s:h('Pmenu',        { 'fg': s:lightblack, 'bg': s:white                                  })
call s:h('PmenuSbar',    {                                                                    })
call s:h('PmenuSel',     { 'fg': s:aqua,       'bg': s:black,        'format': 'reverse,bold' })
call s:h('PmenuThumb',   { 'fg': s:lightblack, 'bg': s:grey                                   })
hi! link Question SublimeYellow
call s:h('Search',       { 'format': 'reverse,underline'                                      })
hi! link SignColumn SublimeLightBlack
hi! link SpecialKey SublimeLightBlack2
call s:h('StatusLine',   { 'fg': s:warmgrey,   'bg': s:black,        'format': 'reverse'      })
call s:h('StatusLineNC', { 'fg': s:darkgrey,   'bg': s:warmgrey,     'format': 'reverse'      })
call s:h('TabLine',      { 'fg': s:white,      'bg': s:darkgrey                               })
call s:h('TabLineFill',  { 'fg': s:grey,       'bg': s:darkgrey                               })
call s:h('TabLineSel',   { 'fg': s:brightwhite,      'bg': s:grey                             })
hi! link Title SublimeYellow
call s:h('VertSplit',    { 'fg': s:darkgrey,   'bg': s:darkblack                              })
call s:h('Visual',       { 'bg': s:lightgrey                                                  })
hi! link WarningMsg SublimeRed

" Generic Syntax Highlighting (see reference: 'NAMING CONVENTIONS' at http://vimdoc.sourceforge.net/htmldoc/syntax.html#group-name)

hi! link Comment SublimeWarmGrey
hi! link Constant SublimePurple
hi! link String SublimeYellow
hi! link Character SublimeYellow
hi! link Number SublimePurple
hi! link Boolean SublimePurple
hi! link Float SublimePurple
hi! link Identifier SublimeWhite
hi! link Function SublimeWhite
hi! link Type SublimeAqua
hi! link StorageClass SublimePink
hi! link Structure SublimePink
hi! link Typedef SublimeAqua
hi! link Statement SublimeWhite
hi! link Conditional SublimePink
hi! link Repeat SublimePink
hi! link Label SublimePink
hi! link Operator SublimePink
hi! link Keyword SublimePink
hi! link Exception SublimePink
call s:h('CommentURL',    { 'fg': s:grey, 'format': 'italic' })

hi! link PreProc SublimeGreen
hi! link Include SublimeWhite
hi! link Define SublimePink
hi! link Macro SublimeGreen
hi! link PreCondit SublimeWhite
hi! link Special SublimePurple
hi! link SpecialChar SublimePink
hi! link Tag SublimeGreen
hi! link Delimiter SublimePink
hi! link SpecialComment SublimeAqua
" call s:h('Debug'          {})
call s:h('Underlined',    { 'format': 'underline' })
" call s:h('Ignore',        {})
call s:h('Error',         { 'fg': s:red, 'bg': s:darkred })
hi! link Todo Comment

" Some highlighting groups custom to the Sublime Monokai theme

call s:h('SublimeType',   { 'fg': s:aqua, 'format': 'italic' })
call s:h('SublimeContextParam',  { 'fg': s:orange, 'format': 'italic' })
hi! link SublimeDocumentation SublimeGrey
hi! link SublimeFunctionCall SublimeAqua
hi! link SublimeUserAttribute SublimeGrey

" Bash

hi! link shConditional Conditional
hi! link shDerefOff    SublimeWhite
hi! link shDerefSimple SublimeAqua
hi! link shDerefVar    SublimeAqua
hi! link shFunctionKey SublimePink
hi! link shLoop        Keyword
hi! link shQuote       String
hi! link shSet         Keyword

" Batch

hi! link dosbatchImplicit    Keyword
hi! link dosbatchLabel       Normal
" FIXME: This should have its own group, like SublimeEscapedSequence
hi! link dosbatchSpecialChar SublimePurple
hi! link dosbatchSwitch      Normal
" FIXME: Variables don't have their own highlighting in Sublime
" hi! link dosbatchVariable    SublimeAqua
" XXX: string highlight is used for echo commands, but Sublime doesn't
" highlight at all
" XXX: Sublime sets everything to the right of an assignment to be a string
" color, but Vim doesn't

" XXX: Create an extra flag for "nice" stuff
" hi! link dosbatchLabel       Tag
" hi! link dosbatchStatement   Keyword
" hi! link dosbatchSwitch      SublimePurple
" hi! link dosbatchVariable    SublimeAqua

" C

hi! link cAnsiFunction     SublimeFunctionCall
hi! link cDefine           SublimeGreen
hi! link cFormat           Special
hi! link cInclude          SublimePink
hi! link cLabel            SublimePink
hi! link cSpecialCharacter SublimePurple
hi! link cStatement        Keyword
hi! link cStorageClass     SublimePink
hi! link cStructure        SublimeType
hi! link cType             SublimeType
" FIXME: Function definitions

" CSS

hi! link cssAttr              SublimeAqua
hi! link cssAttributeSelector Tag
" XXX: Not sure about this one; it has issues with the following:
"   - calc
"   - colors
hi! link cssAttrRegion      Normal
hi! link cssBraces          Normal
hi! link cssClassName       Tag
hi! link cssColor           Constant
hi! link cssFunctionName    SublimeFunctionCall
hi! link cssIdentifier      Tag
hi! link cssPositioningAttr SublimeAqua
hi! link cssProp            SublimeAqua
" XXX: Variation: might be better as pink, actually
hi! link cssPseudoClassId   Normal
hi! link cssSelectorOp      Normal
hi! link cssStyle           cssAttr
hi! link cssTagName         Keyword
" TODO: Find a way to distinguish unit decorators from color hash
hi! link cssUnitDecorators  SpecialChar
hi! link cssURL             String
hi! link cssValueLength     Constant

" C++

" XXX: This is imperfect, as this highlights the expression for the `#if`s
" too.
hi! link cCppOutWrapper  Keyword
hi! link cppStatement    Keyword
hi! link cppSTLException SublimeType
hi! link cppSTLfunction  SublimeFunctionCall
" XXX: There may be no special highlighting here in Sublime itself
hi! link cppSTLios       SublimeAqua
" XXX: There may be no special highlighting here in Sublime itself
hi! link cppSTLnamespace SublimePurple
hi! link cppType         SublimeType

" C#

hi! link csClass                SublimeType
hi! link csMethodTag            SublimeType
" XXX: This seems to correspond to directives in general -- region names
" SHOULDN'T be included, though.
hi! link csPreCondit            Keyword
hi! link csTypeDecleration      SublimeType
hi! link csType                 SublimeType
hi! link csUnspecifiedStatement Keyword
hi! link csXmlTag               xmlTagName
hi! link csXmlComment           SublimeDocumentation
"FIXME: Need some local links for XML getting set to the right color
"FIXME: Operators aren't red...
"FIXME: Args aren't right either -- they don't have a unique group yet
"FIXME: `namespace` is a type highlight in Sublime
"FIXME: No function call groups

" D

hi! link dExternal Keyword

" `diff` patch files

hi! link diffAdded     SublimeGreen
hi! link diffFile      SublimeWarmGrey
hi! link diffIndexLine SublimeWarmGrey
hi! link diffLine      SublimeWarmGrey
hi! link diffRemoved   SublimePink
hi! link diffSubname   SublimeWarmGrey

" eRuby

" call s:h('erubyDelimiter',              {})
hi! link erubyRailsMethod SublimeAqua

" Git

hi! link gitrebaseCommit  Comment
hi! link gitrebaseDrop    Error
hi! link gitrebaseEdit    Keyword
hi! link gitrebaseExec    Keyword
hi! link gitrebaseFixup   Keyword
" FIXME: Make this cooler in extensions!
hi! link gitrebaseHash    Comment
hi! link gitrebasePick    Keyword
hi! link gitrebaseReword  Keyword
hi! link gitrebaseSquash  Keyword
hi! link gitrebaseSummary String
" XXX: Note that highlighting inside the always-present help from Git in
" comments is not available in vim's current highlighting version.
" FIXME: Erich prefers different colors for the different operations. More
" variations!

" HTML
" This partially depends on XML -- make sure that groups in XML don't
" adversely affect this!

" XXX: This doesn't exclude things like colons like Sublime does
" FIXME: For some reason this is excluding a "key" attribute
hi! link htmlArg            Tag
" Variation: This is an interesting idea for
hi! link htmlLink           Normal
hi! link htmlSpecialTagName htmlTagName
hi! link htmlSpecialChar    Special
hi! link htmlTagName        Keyword

" Java

hi! link javaConditional      Keyword
" FIXME: Javadoc @... doesn't work?
hi! link javaExceptions       Keyword
hi! link javaFunction         SublimeAqua
" FIXME: This isn't a builtin...don't other languages use italics for types?
hi! link javaNonPrimitiveType SublimeType
hi! link javaRepeat           Keyword
hi! link javaSpecialChar      Special
hi! link javaStatement        Keyword
hi! link javaType             SublimeType
call s:h('jpropertiesIdentifier', { 'fg': s:pink })

" JavaScript

hi! link jsArgsObj        SublimeAqua
hi! link jsArrowFunction  SublimePink
hi! link jsBuiltins       SublimeFunctionCall
hi! link jsCatch          Keyword
hi! link jsConditional    Keyword
call s:h('jsDocTags',       { 'fg': s:aqua, 'format': 'italic' })
hi! link jsException      Keyword
" Variation: It's actually nice to get this italicized, to me
hi! link jsExceptions     Type
hi! link jsExport         Keyword
hi! link jsFinally        Keyword
hi! link jsFrom           Keyword
call s:h('jsFuncArgRest',   { 'fg': s:purple, 'format': 'italic' })
hi! link jsFuncArgs       SublimeContextParam
hi! link jsFuncCall       SublimeFunctionCall
hi! link jsFuncName       Tag
hi! link jsFunctionKey    Tag
" FIXME: FutureKeys includes a bit too much. It had some type names, which should be aqua, but most of the keywords that might actually get used would be pink (keywords like public, abstract).
hi! link jsFutureKeys     Keyword
call s:h('jsGlobalObjects', { 'fg': s:aqua, 'format': 'italic' })
hi! link jsImport         Keyword
hi! link jsModuleAs       Keyword
hi! link jsModuleAsterisk Keyword
hi! link jsNan            Constant
hi! link jsNull           Constant
hi! link jsObjectFuncName Tag
hi! link jsPrototype      SublimeAqua
" Variation: Technically this is extra from Sublime, but it looks nice.
hi! link jsRepeat         Keyword
hi! link jsReturn         Keyword
hi! link jsStatement      Keyword
hi! link jsStatic         jsStorageClass
hi! link jsStorageClass   SublimeAqua
hi! link jsSuper          SublimeContextParam
hi! link jsThis           SublimeContextParam
hi! link jsTry            Keyword
hi! link jsUndefined      Constant

" JSON

hi! link jsonKeyword Normal

" LESS

hi! link lessVariable Tag

" Makefile

hi! link makeCommands    Normal
hi! link makeCmdNextLine Normal

" NERDTree

hi! link NERDTreeBookmarkName    SublimeYellow
hi! link NERDTreeBookmarksHeader SublimePink
hi! link NERDTreeBookmarksLeader SublimeBlack
hi! link NERDTreeCWD             SublimePink
hi! link NERDTreeClosable        SublimeYellow
hi! link NERDTreeDir             SublimeYellow
hi! link NERDTreeDirSlash        SublimeGrey
hi! link NERDTreeFlags           SublimeDarkGrey
hi! link NERDTreeHelp            SublimeYellow
hi! link NERDTreeOpenable        SublimeYellow
hi! link NERDTreeUp              SublimeWhite

" NERDTree Git

hi! link NERDTreeGitStatusModified SublimeOrange
hi! link NERDTreeGitStatusRenamed SublimeOrange
hi! link NERDTreeGitStatusUntracked SublimeGreen

" Python

" This configuration assumed python-mode
hi! link pythonConditional Conditional
hi! link pythonException   Keyword
hi! link pythonFunction    Tag
hi! link pythonInclude     Keyword
" XXX: def parens are, for some reason, included in this group.
hi! link pythonParam       SublimeContextParam
" XXX: pythonStatement covers a bit too much...unfortunately, this means that
" some keywords, like `def`, can't be highlighted like in Sublime yet.
hi! link pythonStatement   Keyword
" FIXME: Python special regexp sequences aren't highlighted. :\

" Ruby

" call s:h('rubyInterpolationDelimiter',  {})
" call s:h('rubyInstanceVariable',        {})
" call s:h('rubyGlobalVariable',          {})
" call s:h('rubyClassVariable',           {})
" call s:h('rubyPseudoVariable',          {})
hi! link rubyFunction                 SublimeGreen
hi! link rubyStringDelimiter          SublimeYellow
hi! link rubyRegexp                   SublimeYellow
hi! link rubyRegexpDelimiter          SublimeYellow
hi! link rubySymbol                   SublimePurple
hi! link rubyEscape                   SublimePurple
hi! link rubyInclude                  SublimePink
hi! link rubyOperator                 Operator
hi! link rubyControl                  SublimePink
hi! link rubyClass                    SublimePink
hi! link rubyDefine                   SublimePink
hi! link rubyException                SublimePink
hi! link rubyRailsARAssociationMethod SublimeOrange
hi! link rubyRailsARMethod            SublimeOrange
hi! link rubyRailsRenderMethod        SublimeOrange
hi! link rubyRailsMethod              SublimeOrange
hi! link rubyConstant                 SublimeAqua
hi! link rubyBlockArgument            SublimeOrange
hi! link rubyBlockParameter           SublimeOrange

" Rust

hi! link rustCommentLineDoc SublimeDocumentation
hi! link rustConditional    Conditional
hi! link rustAttribute      SublimeGrey
hi! link rustDerive         SublimeGrey
hi! link rustDeriveTrait    SublimeGrey
hi! link rustFuncCall       SublimeFunctionCall
hi! link rustIdentifier     Normal
hi! link rustModPathSep     Normal
hi! link rustMacro          SublimeFunctionCall
hi! link rustQuestionMark   Keyword
hi! link rustRepeat         Keyword

" SASS

hi! link sassAmpersand    Operator
hi! link sassClass        Tag
hi! link sassCssAttribute SublimeAqua
hi! link sassInclude      Keyword
" FIXME: No distinction between mixin definition and call
hi! link sassMixinName    SublimeAqua
hi! link sassMixing       Keyword
hi! link sassProperty     SublimeAqua
hi! link sassSelectorOp   Operator
hi! link sassVariable     Normal

" SQL
hi! link Quote        String
hi! link sqlFunction  SublimeFunctionCall
hi! link sqlKeyword   Keyword
hi! link sqlStatement Keyword

" Syntastic

hi! link SyntasticErrorSign Error
call s:h('SyntasticWarningSign',    { 'fg': s:lightblack, 'bg': s:orange })

" VimL

hi! link vimCommand       Keyword
" Variation: Interesting how this could vary...
hi! link vimCommentTitle  Comment
hi! link vimEnvvar        SublimeAqua
hi! link vimFBVar         SublimeWhite
hi! link vimFuncName      SublimeAqua
hi! link vimFuncNameTag   SublimeAqua
hi! link vimFunction      SublimeGreen
hi! link vimFuncVar       SublimeContextParam
hi! link vimHiGroup       Normal
hi! link vimIsCommand     SublimeAqua
hi! link vimMapModKey     SublimeAqua
hi! link vimMapRhs        SublimeYellow
hi! link vimNotation      SublimeAqua
hi! link vimOption        SublimeAqua
hi! link vimParenSep      SublimeWhite
hi! link vimScriptFuncTag SublimePink
hi! link vimSet           Keyword
hi! link vimSetEqual      Operator
hi! link vimUserFunc      SublimeAqua
hi! link vimVar           SublimeWhite

" XML

hi! link xmlArg             Tag
hi! link xmlAttrib          Tag
" XXX: This highlight the brackets and end slash too...which we don't want.
hi! link xmlEndTag          Keyword
" Variation: I actually liked it when this was faded
hi! link xmlProcessingDelim Normal
hi! link xmlTagName         Keyword
