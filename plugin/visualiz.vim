" vim plugin file
" Filename:     visualiz.vim
" Maintainer:   janus_wel <janus.wel.3@gmail.com>
" Refer:        http://d.hatena.ne.jp/thinca/20091121/1258748377
"
" License:      MIT License {{{1
"   See under URL.  Note that redistribution is permitted with LICENSE.
"   http://github.com/januswel/visualiz.vim/blob/master/LICENSE

" preparations {{{1
" check if this plugin is already loaded or not
if exists('loaded_visualiz')
    finish
endif
let loaded_visualiz = 1

" check vim has the required feature
if !has('autocmd')
    finish
endif

" reset the value of 'cpoptions' for portability
let s:save_cpoptions = &cpoptions
set cpoptions&vim

" main {{{1
" constants {{{2
" default patterns
" name:      a unique name
" pattern:   a pattern string
" highlight: the highlight group to map to
scriptencoding utf-8
let s:patterns_default = [
            \   {
            \       'name':         'TrailingWhiteSpace',
            \       'pattern':      '\s\+$',
            \       'highlight':    'Error'
            \   },
            \   {
            \       'name':         'IdeographicSpace',
            \       'pattern':      '　',
            \       'highlight':    'Error'
            \   },
            \ ]
scriptencoding
lockvar s:patterns_default

" functions {{{2
" Just calls the function matchadd(), and returns its returned values
function s:AddMatch(patterns)
    let l:matchidlist = []
    for item in a:patterns
        call add(l:matchidlist, matchadd(item.name, item.pattern))
    endfor
    return l:matchidlist
endfunction

" Deletes existing matchids, and adds new match patterns
function s:SetMatch()
    " Check if match is already set or not
    if exists('w:matchidlist')
        return
    endif

    let w:matchidlist = s:AddMatch(s:patterns)
endfunction

" Defines highlight group
function s:DefineHighlightGroups(groups)
    if version >= 508 || !exists('did_visualiz_syntax_inits')
        if version < 508
            let did_visualiz_syntax_inits = 1
            command -nargs=+ HiLink hi link <args>
        else
            command -nargs=+ HiLink hi def link <args>
        endif

        for item in a:groups
            execute 'HiLink ' . item.name . ' ' . item.highlight
        endfor

        delcommand HiLink
    endif
endfunction

" Builds definitions from default and user settings
function s:GetPatterns()
    if exists('g:visualiz_patterns')
        if exists('g:visualiz_add') && g:visualiz_add
            return s:patterns_default + g:visualiz_patterns
        endif
        return g:visualiz_patterns
    endif
    return s:patterns_default
endfunction

" autocommands {{{2
augroup visualiz
    autocmd! visualiz

    autocmd VIMEnter,WinEnter * call s:SetMatch()
    autocmd ColorScheme * call s:DefineHighlightGroups(s:patterns)
augroup END

" code executions {{{2
let s:patterns = s:GetPatterns()
lockvar s:patterns

" Function matchadd() needs the highlight groups that is specified its
" arguments. So register highlight groups here on ahead.
call s:DefineHighlightGroups(s:patterns)

" post-processings {{{1
" restore the value of 'cpoptions'
let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions

" }}}1
" vim: ts=4 sw=4 sts=0 et fdm=marker fdc=3 fenc=utf-8
