" ~/.config/nvim/syntax/qdoc.vim

if exists("b:current_syntax")
  finish
endif

syn case match

" --- Sync (prevents drifting into "everything is a comment") ---
syntax sync fromstart
syntax sync minlines=200

" --- Basic non-doc comments (top-of-file // lines, etc.) ---
syntax match qdocLineComment /^\s*\/\/.*$/
highlight default link qdocLineComment Comment


" =========================
"  Core QDoc (inside /*! */)
" =========================

" Delimiters only look like comments; body is explicitly Normal.
syntax region qdocDoc
      \ matchgroup=qdocDocDelim
      \ start=/\/\*!/
      \ end=/\*\//
      \ keepend
      \ contains=@qdocDocContains,@Spell

highlight default link qdocDocDelim Comment
highlight default link qdocDoc Normal


" -------------------------
" Commands and arguments
" -------------------------

" All commands are Keywords (\foo, \section2, \endlist, etc.)
syntax match qdocCommand /\\[A-Za-z_]\+\d*/ contained nextgroup=qdocBraceArg skipwhite
highlight default link qdocCommand Keyword

" Headings: highlight whole heading line (still Title)
syntax match qdocHeadingLine /^\s*\\\%(part\|chapter\|section\)\d\+\>\s\+.*$/ contained
syntax match qdocHeadingLine /^\s*\\\%(part\|chapter\|section\)\>\s\+.*$/ contained
highlight default link qdocHeadingLine Title

" Braced argument as a region so we can color only { }.
" The content stays Normal by default.
syntax region qdocBraceArg
      \ matchgroup=qdocBraceDelim
      \ start=/{/
      \ end=/}/
      \ keepend
      \ contained

highlight default link qdocBraceDelim Keyword
highlight default link qdocBraceArg Normal

" Inline code: \c{...} should stand out; keep as Structure-ish
syntax match qdocInlineCode /\\c\>\s*{[^}]*}/ contained
highlight default link qdocInlineCode PreProc


" -------------------------
" Block commands (code-ish)
" -------------------------

" Use Structure for blocks (more neutral than String in many schemes)
syntax region qdocCodeBlock
      \ matchgroup=qdocBlockDelim
      \ start=/^\s*\\code\>/
      \ end=/^\s*\\endcode\>/
      \ keepend
      \ contained
      \ contains=NONE
highlight default link qdocCodeBlock PreProc
highlight default link qdocBlockDelim Keyword

syntax region qdocBadCodeBlock
      \ matchgroup=qdocBlockDelim
      \ start=/^\s*\\badcode\>/
      \ end=/^\s*\\endcode\>/
      \ keepend
      \ contained
      \ contains=NONE
highlight default link qdocBadCodeBlock PreProc


" -------------------------
" Lists: \li blocks (multi-line)
" -------------------------

" List delimiters as Keyword too
syntax match qdocListDelim /^\s*\\\%(list\|endlist\)\>/ contained
highlight default link qdocListDelim Keyword

" Whole \li item as a region until next \li or \endlist.
" We keep it transparent so only the marker pops.
syntax region qdocListItemBody
      \ matchgroup=qdocListItemMarker
      \ start=/^\s*\\li\>/
      \ end=/^\s*\\\%(li\|endlist\)\>/me=s-1
      \ keepend
      \ contained
      \ transparent
      \ contains=@qdocInline

" Marker highlight: keyword-ish but distinguishable from command tokens
" If you want it identical to commands: link to Keyword.
highlight default link qdocListItemMarker Special


" -------------------------
" Clusters
" -------------------------

syntax cluster qdocInline contains=
      \ qdocHeadingLine,qdocCommand,qdocBraceArg,qdocInlineCode,
      \ qdocListDelim,qdocCodeBlock,qdocBadCodeBlock

syntax cluster qdocDocContains contains=@qdocInline,qdocListItemBody


let b:current_syntax = "qdoc"
