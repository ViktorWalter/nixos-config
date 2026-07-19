au BufNewFile,BufRead *.cpp,*.h,*.hpp,*.hh,*.cc let b:ale_linters = ['clangd']
au BufNewFile,BufRead *.py let b:ale_linters = ['flake8', 'pylint']
let b:ale_warn_about_trailing_whitespace = 0
