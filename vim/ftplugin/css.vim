" Use indentation by default
silent! set foldmethod=indent

" Enable keyword completion
setlocal iskeyword+=-


" CSS Omni Complete Function for CSS3
setlocal omnifunc=csscomplete#CompleteCSS noci

" Enable linting
let b:ale_linters = ['stylelint']

" Enable fixing
let b:ale_fixers = ['prettier', 'stylelint']
