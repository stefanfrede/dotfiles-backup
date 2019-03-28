# Start tmux automatically
if status is-interactive
and not set -q TMUX
  exec tmux
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

# Get a password prompt when signing commits
set -x GPG_TTY (tty)

# Start or re-use a gpg-agent.
gpgconf --launch gpg-agent

# Ensure that GPG Agent is used as the SSH agent
set -e SSH_AUTH_SOCK
set -U -x SSH_AUTH_SOCK ~/.gnupg/S.gpg-agent.ssh
