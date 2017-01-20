
augroup paste_easy
	au!
	autocmd InsertCharPre * call <sid>char_inserted()
	autocmd InsertLeave   * call <sid>insert_leave()
augroup END

let s:start = reltime()
let s:past_easy_mode = 0

func! s:insert_leave()
	if s:past_easy_mode
		echom 'paste-easy end'
		let s:past_easy_mode = 0
		set nopaste
	endif
endfunc

func! s:char_inserted()
	let l:passed = reltimefloat(reltime(s:start))
	let s:start = reltime()
	if s:past_easy_mode
		return
	endif
	if l:passed <= 0.01
		" no way a human could get fast like that
		" let g:operator = copy(v:event)
		let s:past_easy_mode = 1
		set paste
	endif
endfunc

