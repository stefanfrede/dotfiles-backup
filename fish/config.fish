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

source ~/.config/fish/aliases.fish

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

# Refresh gpg-agent tty
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=835394
if [ (pgrep -x -u $USER gpg-agent) ]
else
  gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
end

# Ensure that GPG Agent is used as the SSH agent
set -e SSH_AUTH_SOCK
set -U -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)

# Get a password prompt when signing commits
set -x GPG_TTY (tty)
