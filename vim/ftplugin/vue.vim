" Run both javascript and vue linters for vue files.
let b:ale_linter_aliases = ['css', 'javascript', 'vue']

" Enable linting
let b:ale_linters = ['stylelint', 'eslint']

" Enable fixing
let b:ale_fixers = ['prettier', 'eslint']
