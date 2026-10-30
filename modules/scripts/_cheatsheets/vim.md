# Neovim: editing

## Modes
    i / a / o        insert before cursor / after / on a new line below (O: above)
    Esc              back to normal mode
    v / V / Ctrl+V   select characters / lines / a block
    :w  :q  :wq  :q! save, quit, both, quit without saving

## Moving
    h j k l          left, down, up, right
    w / b / e        next word / previous word / end of word
    0 / ^ / $        start of line / first character / end of line
    gg / G / 42G     first line / last line / line 42
    Ctrl+D / Ctrl+U  half a page down / up
    % / f( / t,      matching bracket / to the next ( / just before the next ,
    Ctrl+O / Ctrl+I  back / forward through where you've been

## Editing (verb + where: dw deletes a word, ci" changes inside quotes)
    d / c / y        delete / change / copy (yank); doubled for the whole line: dd cc yy
    p / P            paste after / before
    u / Ctrl+R       undo / redo
    .                repeat the last change
    iw  i"  i(  ip   inside a word, quotes, brackets, paragraph (aw, a" ...: with them)
    >> / <<          indent / unindent
    gcc / gc         comment line / selection

## Searching
    /text  ?text     search forward / back; n / N next / previous
    *                search for the word under the cursor
    :%s/old/new/g    replace in the whole file (add c to confirm each)

## This configuration (Space is the leader; wait after it for a menu)
    Space Space      find a file           Space /      search the project
    Space c a        code actions          Space c r    rename
    gd / gr / K      definition / uses / documentation
    ]d [d            next / previous error  Space c d   the error in full
    Ctrl+S           save                   Shift+H/L   previous / next file
