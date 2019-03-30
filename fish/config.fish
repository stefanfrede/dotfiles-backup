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
# SSH-agent
#

# Auto-launch SSH-agent
setenv SSH_ENV $HOME/.ssh/environment

function start_agent                                                                                                                                                                    
  echo "Initializing new SSH agent ..."
  ssh-agent -c | sed 's/^echo/#echo/' > $SSH_ENV
  echo "succeeded"
  chmod 600 $SSH_ENV 
  . $SSH_ENV > /dev/null
  ssh-add
end

function test_identities                                                                                                                                                                
  ssh-add -l | grep "The agent has no identities" > /dev/null
  if [ $status -eq 0 ]
    ssh-add
    if [ $status -eq 2 ]
      start_agent
    end
  end
end

if [ -n "$SSH_AGENT_PID" ] 
  ps -ef | grep $SSH_AGENT_PID | grep ssh-agent > /dev/null
  if [ $status -eq 0 ]
    test_identities
  end  
else
  if [ -f $SSH_ENV ]
    . $SSH_ENV > /dev/null
  end  
  ps -ef | grep $SSH_AGENT_PID | grep -v grep | grep ssh-agent > /dev/null
  if [ $status -eq 0 ]
    test_identities
  else 
    start_agent
  end  
end

#
# GPG
#

# Start or re-use a gpg-agent.
gpgconf --launch gpg-agent

# Get a password prompt when signing commits
set -x GPG_TTY (tty)

