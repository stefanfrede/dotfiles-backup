" Enable keyword completion
setlocal iskeyword+=-

" Enable linting
let b:ale_linters = ['stylelint']

" Enable fixing
let b:ale_fixers = ['prettier', 'stylelint']
