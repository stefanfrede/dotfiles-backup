" Basic Settings
" {{{
filetype plugin indent on
syntax on

set autoread                    " Don't bother me when a file changes
set autowrite                   " Automatically :write before running commands
set backspace=eol,start,indent  " Backspace deletes like most programs in insert mode
set belloff=all                 " No flashing or beeping at all
set colorcolumn=+1              " Make it obvious where 80 characters is
set diffopt+=vertical           " Always use vertical diffs
set encoding=utf8               " UTF-8 by default
set hidden                      " Don't prompt to save hidden windows until exit
set history=50                  " How many lines of history to save
set hlsearch                    " Hilight searching
set gdefault                    " Replace all matches on a line instead of just the first
set ignorecase                  " Case insensitive
set incsearch                   " Search as you type
set laststatus=2                " Always display the status line
set linebreak                   " Break long lines by word, not char
set list                        " Show whitespace as special chars - see listchars
set listchars=tab:»·,trail:·,nbsp:·
set matchtime=0                 " Speed up escape after (){} chars
set modelines=0                 " Disable modelines as a security precaution
set nocompatible                " Vim, not vi!
set nojoinspaces                " Use one space, not two, after punctuation
set noshowmode                  " Hide mode information -- INSERT --
set nomodeline
set number
set numberwidth=5
set redrawtime=1000             " Stop highlighting if it takes more than a second
set ruler                       " Show row/col and percentage
set scrolloff=3                 " Keep cursor away from this many chars top/bottom
set showcmd                     " display incomplete commands
set shortmess+=A                " Don't bother me when a swapfile exists
set smartcase                   " Lets you search for ALL CAPS
set splitbelow                  " Open new split panes to bottom
set splitright                  " Open new split panes to right
set synmaxcol=250               " Don't try to highlight lines longer than 250 characters
set tags^=.git/tags             " Set tags for vim-fugitive
set textwidth=80                " 80 is the new 80
set ttyfast                     " Rendering
set wildmenu                    " Show possible completions on command line
set wildmode=list:longest,full  " List all options and complete

" No backup
set nobackup
set noswapfile
set nowritebackup
set noundofile

" Softtabs, 2 spaces
set expandtab                   " No tabs"
set shiftround                  " Shift to certain columns, not just n spaces
set shiftwidth=2                " Number of spaces to shift for autoindent or >,<
set softtabstop=2               " Spaces 'feel' like tabs
set tabstop=2

" Use braces by default
silent! set foldmethod=marker

" Set spellfile
set spellfile=$HOME/.vim/spell/en.utf-8.add,~/.vim/spell/de.utf-8.add

" Autocomplete with dictionary words when spell check is on
set complete+=kspell

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
  autocmd BufRead,BufNewFile .{eslint,lintstaged,prettier}rc set filetype=json
augroup END

" When the type of shell script is /bin/sh, assume a POSIX-compatible shell
" for syntax highlighting purposes.
let g:is_posix = 1

" Resize panes when window/terminal gets resize
autocmd VimResized * :wincmd =
" }}}

" Mappings and shortcuts
" {{{
" Leader <space>
let mapleader = ' '

" Toggle search highlight
nmap <silent><expr> \q (&hls && v:hlsearch ? ':nohls' : ':set hls')."\n"

" Super fast window movement shortcuts.
nmap <C-j> <C-W>j
nmap <C-k> <C-W>k
nmap <C-h> <C-W>h
nmap <C-l> <C-W>l

" Toggle and untoggle spell checking
map <leader>ss :setlocal spell!<cr>

" Get off my lawn.
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

" Turn off linewise keys.
nmap j gj
nmap k gk

" Keep selection after indenting.
xnoremap < <gv
xnoremap > >gv

" Trim spaces at EOL and retab.
command! TEOL %s/\s\+$//
command! CLEAN retab | TEOL
nmap \c :CLEAN<CR>

" Close all buffers except this one
command! BufCloseOthers %bd|e#

" Unfuck my screen!
nmap \u :syntax sync fromstart<cr>:redraw!<cr>
" }}}

" Aesthetics
" {{{
" set Vim-specific sequences for RGB colors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

" Fix background color erase for 256-color tmux and GNU screen
if &term =~ '256color'
  " disable Background Color Erase (BCE) so that color schemes
  " render properly when inside 256-color tmux and GNU screen.
  " see also http://snk.tuxfamily.org/log/vim-256color-bce.html
  set t_ut=
endif

set background=light
colorscheme solarized
" }}}

" Plugins
" {{{

" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

" netrw
let g:netrw_banner = 0

" Use Ripgrep over Grep
if executable('rg')
  set grepprg=rg\ --vimgrep\ --no-heading
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif

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
    \'a': '#S',
    \'win': ['#I', '#W'],
    \'cwin': ['#I', '#W', '#F'],
    \'z': '#H',
    \'options': {'status-justify' : 'left'}
    \ }

" IndentLine
let g:vim_json_syntax_conceal = 0

" FZF
let $FZF_DEFAULT_COMMAND = 'rg --files --follow -g "!{.git,node_modules}/*" 2>/dev/null'

" Use ripgrep instead of grep
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -g "!{*.lock,*-lock.json}" '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:40%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

" Customize fzf colors to match color scheme
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

" Keep ctags hidden in the .git folder
let g:fzf_tags_command = 'ctags -R -f ./.git/tags .'

nmap ; :Buffers<CR>
nmap <Leader>r :Tags<CR>
nmap <Leader>t :Files<CR>
nmap <Leader>a :Rg!<CR>
nmap <Leader>c :Colors<CR>


" Ale
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

" Fix linting errors
nmap \f <Plug>(ale_fix)

" Allow custom tags
let g:ale_html_tidy_options = ["--custom-tags true"]

" Fix files automatically on save
let g:ale_fix_on_save = 1

" VimCompletesMe
autocmd FileType vim let b:vcm_tab_complete = 'vim'
" Close scratch window on finishing a complete or leaving insert
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" UltiSnips
let g:UltiSnipsSnippetsDir='~/.vim/UltiSnips'
let g:UltiSnipsSnippetDirectories=["UltiSnips"]

let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

let g:UltiSnipsEditSplit="vertical""

" Emmet
" Enable just for html/css
let g:user_emmet_install_global = 0
autocmd FileType html,css,scss EmmetInstall
" }}}
