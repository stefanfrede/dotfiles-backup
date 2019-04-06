#! /usr/bin/env bash

set -euo pipefail

DIR=$(dirname "$0")
cd "$DIR"

info "Update apt..."
sudo apt update && sudo apt upgrade -y

info "Installing fish..."
if fish --version >/dev/null; then
  success "Fish already installed"
else
  echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_9.0/ /' | sudo tee -a /etc/apt/sources.list
  wget -q -O - https://download.opensuse.org/repositories/shells:fish:release:2/Debian_9.0/Release.key | sudo apt-key add -

  sudo apt -qq update

  if sudo apt -qq install fish; then
    success "Fish successful installed."
  else
    error "Failed to install Fish."
    exit 1
  fi
fi

info "Installing git..."
if git --version >/dev/null; then
  success "Git already installed."
else
  if sudo apt -qq install git; then
    success "Git successful installed."
  else
    error "Failed to install Git."
    exit 1
  fi
fi

info "Installing node..."
if nodejs --version >/dev/null; then
  success "Node already installed."
else
  curl -sL https://deb.nodesource.com/setup_11.x -o nodesource_setup.sh

  if sudo bash nodesource_setup.sh; then
    if sudo apt -qq install nodejs; then
      success "Node successful installed."
    else
      error "Failed to install Node."
      exit 1
    fi
  else
    error "Failed to install Node."
    exit 1
  fi

  rm nodesource_setup.sh
fi

info "Update npm..."
if npm -v >/dev/null; then
  sudo apt -qq install build-essential
  sudo npm i -g npm@latest
fi

info "Installing Tmux..."
if tmux -V >/dev/null; then
  success "Tmux already installed"
else
  if sudo apt -qq install tmux; then
    success "Tmux successful installed."
  else
    error "Failed to install Tmux."
    exit 1
  fi
fi

info "Installing ripgrep..."
if rg --version >/dev/null; then
  success "ripgrep already installed"
else
  curl -LO https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep_0.10.0_amd64.deb

  if sudo dpkg -i ripgrep_0.10.0_amd64.deb; then
    success "ripgrep successful installed."
  else
    error "Failed to install ripgrep."
    exit 1
  fi

  rm ripgrep_0.10.0_amd64.deb
fi

info "Installing fzf..."
if fzf --version >/dev/null; then
  success "fzf already installed."
else
  if sudo apt -qq install fzf; then
    success "fzf successful installed."
  else
    error "Failed to install fzf."
    exit 1
  fi
fi

info "Installing asdf..."
if test -d ~/.asdf; then
  success "asdf already installed."
else
  if ! git clone -q https://github.com/asdf-vm/asdf.git ~/.asdf; then
    pushd ~/.asdf
    git checkout "$(git describe --abbrev=0 --tags)"
    popd

    success "asdf successful installed."
  else
    error "Failed to install asdf."
    exit 1
  fi
fi
