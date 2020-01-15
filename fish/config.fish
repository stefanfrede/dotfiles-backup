# Automate the installation process for fisher on a new system
if not functions -q fisher
  set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
  curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
  fish -c fisher
end

# Set vim as editor
set -U EDITOR vim

#
# FZF
#

# Use the new fzf keybindings
set -U FZF_LEGACY_KEYBINDINGS 0

# Use a tmux friendly fzf version
set -U FZF_TMUX 1

# Use fd
set -U FZF_DEFAULT_COMMAND 'fd --type file --follow --hidden --exclude .git'

#
# GPG
#

# Get a password prompt when signing commits
set -x GPG_TTY (tty)

#
# Locales
#

# en_US.UTF-8
set -x LC_ALL en_US.UTF-8

#
# TMUX
#

# Attach to existing or start a new TMUX session named workbench
#if status is-interactive; and not set -q TMUX
#  tmux new-session -A -s workbench
#end

# Homebrew was complaining
set -g fish_user_paths "/usr/local/sbin" $fish_user_paths

# GitHub API token for Homebrew
set -gx HOMEBREW_GITHUB_API_TOKEN c139cfa16c22b6fda76b20e06b75a02f3488e832

source ~/.config/fish/aliases.fish
