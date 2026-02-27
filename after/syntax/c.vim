
" extra fixed keywords (add/remove as you like)
syn keyword cTodo contained WARN WARNING NOTE INFO BUG HACK FIXIT ISSUE

" QTBUG-12345 (match only the token; stops before ')' ':' space etc.)
syn match   cTodo contained /\<QTBUG-\d\+\>/

" exactly "### Qt7" token
syn match   cTodo contained /###\s\+Qt\d\+\>/
