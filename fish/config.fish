# Automate the installation process for fisher on a new system
if not functions -q fisher
  set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
  curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
  fish -c fisher
end

# Set vim as editor
set -U EDITOR vim

# Set locales
# set -x LC_ALL en_US.UTF-8

# Use fd in fzf
set -U FZF_DEFAULT_COMMAND 'fd --type file --follow --hidden --exclude .git'

# Nord colours
set -U FZF_DEFAULT_OPTS '--color fg:#d8dee9,bg:#2e3440,hl:#a3be8c,fg+:#d8dee9,bg+:#434c5e,hl+:#a3be8c,pointer:#bf616a,info:#4c566a,spinner:#4c566a,header:#4c566a,prompt:#81a1c1'

# Install Starship (https://starship.rs/)
starship init fish | source

source ~/.config/fish/aliases.fish
