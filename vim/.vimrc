" ----------------------------------------------------------------------------
" KEY MAPS
" ----------------------------------------------------------------------------

let mapleader = ','

" Useful macros
nmap \W mt:Goyo<CR>'tzz
nmap \q :nohlsearch<CR>

" Turn off linewise keys. Normally, the `j' and `k' keys move the cursor down
" one entire line. with line wrapping on, this can cause the cursor to actually
" skip a few lines on the screen because it's moving from line N to line N+1 in
" the file. I want this to act more visually.
nmap j gj
nmap k gk

" Move between open buffers.
nmap <C-n> :bnext<CR>
nmap <C-p> :bprev<CR>

" Comment/un-comment like Sublime
nnoremap <C-\> :TComment<CR>
vnoremap <C-\> :TComment<CR>

" keep selection after indenting
xnoremap < <gv
xnoremap > >gv

" Use the space key to toggle folds
nnoremap <space> za
vnoremap <space> zf

" Super fast window movement shortcuts
nmap <C-j> <C-W>j
nmap <C-k> <C-W>k
nmap <C-h> <C-W>h
nmap <C-l> <C-W>l

" Resize panes when window/terminal gets resize
autocmd VimResized * :wincmd =

" Quickly fix spelling errors choosing the first result
nmap <Leader>z z=1<CR><CR>

" Pressing <,>ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<cr>

" Shortcuts using <leader>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=

" Unfuck my screen
nnoremap U :syntax sync fromstart<cr>:redraw!<cr>

" Get off my lawn
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

" ----------------------------------------------------------------------------
" OPTIONS
" ----------------------------------------------------------------------------

set autoread                    " Don't bother me hen a file changes
set autowrite                   " Automatically :write before running commands
set backspace=eol,start,indent  " Backspace deletes like most programs in insert mode
set belloff=all                 " No flashing or beeping at all
set cindent                     " Automatic program indenting
set cinkeys-=0#                 " Comments don't fiddle with indenting
set cino=                       " See :h cinoptions-values
set clipboard=unnamed           " Copy selection to clipboard
set colorcolumn=+1              " Make it obvious where 80 characters is
set commentstring=\ \ #%s       " When folds are created, add them to this
set complete+=kspell            " Autocomplete with dictionary words when spell check is on
set copyindent                  " Make autoindent use the same chars as prev line
set cursorline                  " Highlight the current line
set directory-=.                " Don't store temp files in cwd
set encoding=utf8               " UTF-8 by default
set expandtab                   " No tabs
set fileformats=unix,dos,mac    " Prefer Unix
set fillchars=vert:\ ,stl:\ ,stlnc:\ ,fold:-,diff:┄
                                " Unicode chars for diffs/folds, and rely on
                                " Colors for window borders
silent! set foldmethod=marker   " Use braces by default
set formatoptions=tcqn1         " t - autowrap normal text
                                " c - autowrap comments
                                " q - gq formats comments
                                " n - autowrap lists
                                " 1 - break _before_ single-letter words
                                " 2 - use indenting from 2nd line of para
set hidden                      " Don't prompt to save hidden windows until exit
set history=50                  " How many lines of history to save
set hlsearch                    " Hilight searching
set ignorecase                  " Case insensitive
set incsearch                   " Search as you type
set infercase                   " Completion recognizes capitalization
set laststatus=2                " Always show the status bar
set lazyredraw                  " Don't redraw while executing macros
set linebreak                   " Break long lines by word, not char
set list                        " Show whitespace as special chars - see listchars
set listchars=tab:»\ ,extends:›,precedes:‹,nbsp:·,trail:· " Unicode characters for various things
set magic                       " For regular expressions turn magic on
set matchtime=2                 " Tenths of second to hilight matching paren
set modelines=5                 " How many lines of head & tail to look for ml's
set nobackup                    " No backups left after done editing
set nocompatible                " Vim, not vi!
set nojoinspaces                " Use one space, not two, after punctuation.
set noshowmode                  " Hide mode information -- INSERT --
set noswapfile                  " http://robots.thoughtbot.com/post/18739402579/global-gitignore#comment-458413287
set nowritebackup               " No backups made while editing
set number
set numberwidth=5
set ruler                       " Show row/col and percentage
set scrolloff=3                 " Keep cursor away from this many chars top/bot
set sessionoptions-=options     " Don't save runtimepath in Vim session (see tpope/vim-pathogen docs)
set shiftround                  " Shift to certain columns, not just n spaces
set shiftwidth=2                " Number of spaces to shift for autoindent or >,<
set shortmess+=A                " Don't bother me when a swapfile exists
set showbreak=                  " Show for lines that have been wrapped, like Emacs
set showcmd                     " display incomplete commands
set showmatch                   " Hilight matching braces/parens/etc.
set sidescroll=1
set sidescrolloff=7             " Keep cursor away from this many chars left/right
set smartcase                   " Lets you search for ALL CAPS
set softtabstop=2               " Spaces 'feel' like tabs
set spellfile=~/.vim/spell/en.utf-8.add,~/.vim/spell/de.utf-8.add
set spelllang=en,de
set splitbelow                  " Open new split panes to bottom
set splitright                  " Open new split panes to right
set tabstop=2                   " The One True Tab
set textwidth=80                " 80 is the new 80
set thesaurus+=~/.vim/mthes10/mthesaur.txt
set ttyfast                     " Rendering
set whichwrap+=<,>,h,l          " Configure backspace so it acts as it should act
set wildmenu                    " Show possible completions on command line
set wildmode=list:longest,full  " List all options and complete

" Essential for filetype plugins.
filetype plugin indent on

" OmniCompletion
set omnifunc=syntaxcomplete#Complete

" Close scratch window on finishing a complete or leaving insert
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" ----------------------------------------------------------------------------
" CUSTOM COMMANDS AND FUNCTIONS
" ----------------------------------------------------------------------------

" Trim spaces at EOL and retab.
command! TEOL %s/\s\+$//
command! CLEAN retab | TEOL

" Close all buffers except this one
command! BufCloseOthers %bd|e#

" ----------------------------------------------------------------------------
" PLUGIN SETTINGS
" ----------------------------------------------------------------------------

" For any plugins that use this, make their keymappings use comma
let maplocalleader = ","

augroup vimrcEx
  autocmd!

  " When editing a file, always jump to the last known cursor position.
  " Don't do it for commit messages, when the position is invalid, or when
  " inside an event handler (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " Set syntax highlighting for specific file types
  autocmd BufRead,BufNewFile *.md set filetype=markdown
  autocmd BufRead,BufNewFile .{jscs,jshint,eslint}rc set filetype=json
augroup END

" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

" Tab completion will insert tab at beginning of line, will use completion if
" not at beginning
function! InsertTabWrapper()
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<Tab>"
  else
    return "\<C-p>"
  endif
endfunction
inoremap <Tab> <C-r>=InsertTabWrapper()<CR>
inoremap <S-Tab> <C-n>

if executable('rg')
  " Use Ripgrep over Grep
  set grepprg=rg\ --vimgrep\ --no-heading
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif

" ALE linting events
augroup ale
  autocmd!

  autocmd VimEnter *
    \ set updatetime=1000 |
    \ let g:ale_lint_on_text_changed = 0
  autocmd CursorHold * call ale#Queue(0)
  autocmd CursorHoldI * call ale#Queue(0)
  autocmd InsertEnter * call ale#Queue(0)
  autocmd InsertLeave * call ale#Queue(0)
augroup END

" Move between linting errors
nnoremap ]r :ALENextWrap<CR>
nnoremap [r :ALEPreviousWrap<CR>

" Fix lintint errors
nmap <Leader>f <Plug>(ale_fix)

" Allow custom tags
let g:ale_html_tidy_options = ["--custom-tags true"]

" Fix files automatically on save
let g:ale_fix_on_save = 1

let g:ale_linters = {
  \ 'javascript': [
  \   'eslint'
  \ ],
  \ 'css': [
  \   'stylelint'
  \ ],
  \ 'less': [
  \   'stylelint'
  \ ],
  \ 'sass': [
  \   'stylelint'
  \ ],
  \ 'scss': [
  \   'stylelint'
  \ ] }

let g:ale_fixers = {
  \ 'javascript': [
  \   'prettier',
  \   'eslint'
  \ ],
  \ 'css': [
  \   'prettier',
  \   'stylelint'
  \ ],
  \ 'less': [
  \   'prettier',
  \   'stylelint'
  \ ],
  \ 'sass': [
  \   'prettier',
  \   'stylelint'
  \ ],
  \ 'scss': [
  \   'prettier',
  \   'stylelint'
  \ ] }

" FZF (replaces Ctrl-P, FuzzyFinder and Command-T)
source /usr/share/doc/fzf/examples/fzf.vim

nmap ; :Buffers<CR>
nmap <Leader>r :Tags<CR>
nmap <Leader>t :Files<CR>
nmap <Leader>a :Rg!<CR>
nmap <Leader>c :Colors<CR>

let $FZF_DEFAULT_COMMAND = 'rg --files --follow -g "!{.git,node_modules}/*" 2>/dev/null'

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -g "!{*.lock,*-lock.json}" '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:40%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

" Customize fzf colors to match your color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" indentLine
let g:vim_json_syntax_conceal = 0

" editorconfig-vim
" Ensure that this plugin works well with Tim Pope's fugitive
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

" Avoid loading EditorConfig for any remote files over ssh
let g:EditorConfig_exclude_patterns = ['scp://.*']

" vim-html-template-literals
let g:html_indent_style1 = 'inc'

" vim-javascript
let g:javascript_plugin_flow = 1

" tern_for_vim
let g:tern_show_argument_hints = 'on_hold'
let g:tern_show_signature_in_pum = 1

" Lightline
let g:lightline = {
    \ 'colorscheme': 'solarized',
    \ 'active': {
    \   'left':  [[ 'mode', 'paste' ],
    \             [ 'gitbranch', 'readonly', 'filename', 'modified' ]],
    \   'right': [['lineinfo'], ['percent'],
    \             ['readonly', 'linter_warnings', 'linter_errors', 'linter_ok']]
    \ },
    \ 'component_function': {
    \   'gitbranch': 'fugitive#head'
    \ },
    \ 'component_expand': {
    \   'linter_warnings': 'LightlineLinterWarnings',
    \   'linter_errors': 'LightlineLinterErrors',
    \   'linter_ok': 'LightlineLinterOK'
    \ },
    \ 'component_type': {
    \   'readonly': 'error',
    \   'linter_warnings': 'warning',
    \   'linter_errors': 'error'
    \ },
    \ }

function! LightlineLinterWarnings() abort
  let l:counts = ale#statusline#Count(bufnr(''))
  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors
  return l:counts.total == 0 ? '' : printf('%d ◆', all_non_errors)
endfunction

function! LightlineLinterErrors() abort
  let l:counts = ale#statusline#Count(bufnr(''))
  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors
  return l:counts.total == 0 ? '' : printf('%d ✗', all_errors)
endfunction

function! LightlineLinterOK() abort
  let l:counts = ale#statusline#Count(bufnr(''))
  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors
  return l:counts.total == 0 ? '✓ ' : ''
endfunction

" Tmuxline
let g:tmuxline_powerline_separators = 0

let g:tmuxline_preset = {
    \'a'    : '#S',
    \'win'  : ['#I', '#W'],
    \'cwin' : ['#I', '#W', '#F'],
    \'z'    : '#H',
    \'options' : {'status-justify' : 'left'}
    \ }

" Goyo

function! s:goyo_enter()
  silent !tmux set status off
  silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
  set noshowcmd
  set scrolloff=999
endfunction

function! s:goyo_leave()
  silent !tmux set status on
  silent !tmux list-panes -F '\#F' | grep -q Z && tmux
  resize-pane -Z
  set showcmd
  set scrolloff=3
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

" ----------------------------------------------------------------------------
" COLORS
" ----------------------------------------------------------------------------

" set Vim-specific sequences for RGB colors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

syntax enable
set background=light
colorscheme solarized

set t_Co=256

" Disable Background Color Erase when within tmux -
" https://stackoverflow.com/q/6427650/102704
if $TMUX != ""
  set t_ut=
endif
