
augroup paste_easy
    au!
    autocmd InsertCharPre * call <sid>char_inserted()
    autocmd InsertLeave   * call <sid>stop_easy_paste()

    autocmd User MultipleCursorsPre  let s:lock = or(s:lock, 1)
    autocmd User MultipleCursorsPost let s:lock = and(s:lock, invert(0x01))
augroup END

command! PasteEasyDisable let g:paste_easy_enable=0
command! PasteEasyEnable let g:paste_easy_enable=1

let g:paste_easy_enable = get(g:,'paste_easy_enable',1)
let g:paste_char_threshold = get(g:,'paste_char_threshold', 1)
let g:paste_easy_message = get(g:,'paste_easy_message', 1)

" lock
" 1 - vim-multipl-cursors
let s:lock = 0

let s:start = reltime()
let s:past_easy_mode = 0
let s:paste_char_count = 0

if exists('*reltimefloat')
    let s:Reltimefloat = function('reltimefloat')
else
    func! s:Reltimefloat(rt)
        execute 'let f = ' . reltimestr(a:rt)
        return f
    endfunc
endif

func! s:char_inserted()
    if g:paste_easy_enable==0
        return
    endif
    if s:lock
        return
    endif
    if s:past_easy_mode
        return
    endif
    let l:passed = s:Reltimefloat(reltime(s:start))
    let s:start = reltime()
    if l:passed <= 0.01
        " no way a human could get fast like that
        let s:paste_char_count = s:paste_char_count + 1
        if s:paste_char_count >= g:paste_char_threshold
            call s:start_easy_paste()
        endif
    else
        let s:paste_char_count = 0
    endif
endfunc

func! s:start_easy_paste()
    if s:past_easy_mode
        return
    endif
    let s:counter = 0
    let s:changedtick = 0
    let s:past_easy_mode = 1
    set paste

    if !has('timers')
        return
    endif

    let s:changedtick = 0
    let s:counter = 0
    let s:timer = timer_start(50,function('s:on_timer'), {'repeat': -1})

endfunc

func! s:stop_easy_paste()
    if s:past_easy_mode==0
        return
    endif

    let s:past_easy_mode = 0
    set nopaste
    if g:paste_easy_message
        echom 'paste-easy end'
    endif

    if !has('timers')
        return
    endif
    call timer_stop(s:timer)
endfunc

func! s:on_timer(timer)

    if s:changedtick == b:changedtick
        let s:counter += 1
    else
        let s:counter = 0
    endif

    let s:changedtick = b:changedtick

    if s:counter >= 2
        call s:stop_easy_paste()
    endif

endfunc

