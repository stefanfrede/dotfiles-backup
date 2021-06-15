" Use syntax by default
silent! set foldmethod=syntax

" Enable linting
let b:ale_linters = ['eslint']

" Enable fixing
let b:ale_fixers = ['prettier', 'eslint']
