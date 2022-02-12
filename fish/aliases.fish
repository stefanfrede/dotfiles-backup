# Alias commands to include common flags
alias mkdir "mkdir -p"

# Alias the cat command to use bat instead
alias cat "bat"

# Alias the gitversion command to use docker 
alias gitversion 'docker run --rm -v (pwd)":/repo" gittools/gitversion:5.6.10-alpine.3.12-x64-3.1 /repo'

# Abbreviate commonly used functions
# An abbreviation will expand after <space> or <Enter> is hit
abbr g git
