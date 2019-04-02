# Attach to existing or start a new TMUX session
if status is-interactive; and not set -q TMUX
  tmux new-session -A -s workbench
end

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

# Use ripgrep
set -U FZF_DEFAULT_COMMAND 'rg --files --hidden --follow --glob "!.git/*"'

#
# GPG
#

# Start or re-use a gpg-agent.
gpgconf --launch gpg-agent

# Get a password prompt when signing commits
set -x GPG_TTY (tty)

