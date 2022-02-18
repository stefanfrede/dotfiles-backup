" Use indentation by default
silent! set foldmethod=indent

" Enable linting
let b:ale_linters = ['prettier']

" Enable fixing
let b:ale_fixers = ['prettier']
