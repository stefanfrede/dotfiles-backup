#! /usr/bin/env bash

DIR=$(dirname "$0")
cd "$DIR"

source ../scripts/functions.sh

info "Update apt..."
sudo apt update

info "Installing git..."
if git --version; then
  success "Git already installed."
else
  if sudo apt install git; then
    success "Git successful installed."
  else
    error "Failed to install Git."
  fi
fi

info "Installing node..."
if nodejs --version; then
  success "Node already installed."
else
  curl -sL https://deb.nodesource.com/setup_11.x -o nodesource_setup.sh

  if sudo bash nodesource_setup.sh; then
    if sudo apt install nodejs; then
      success "Node successful installed."
    else
      error "Failed to install Node."
    fi
  else
    error "Failed to install Node."
  fi

  rm nodesource_setup.sh
fi

info "Update npm..."
if npm -v; then
  sudo apt install build-essential
  sudo npm i -g npm@latest
fi

info "Installing Tmux..."
if tmux -V; then
  success "Tmux already installed"
else
  if sudo apt install tmux; then
    success "Tmux successful installed."
  else
    error "Failed to install Tmux."
  fi
fi

info "Installing ripgrep..."
if rg --version; then
  success "ripgrep already installed"
else
  curl -LO https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep_0.10.0_amd64.deb

  if sudo dpkg -i ripgrep_0.10.0_amd64.deb; then
    success "ripgrep successful installed."
  else
    error "Failed to install ripgrep."
  fi

  rm ripgrep_0.10.0_amd64.deb
fi

info "Installing fzf..."
if fzf --version; then
  success "fzf already installed."
else
  if sudo apt install fzf; then
    success "fzf successful installed."
  else
    error "Failed to install fzf."
  fi
fi

info "Installing asdf..."
if test -d ~/.asdf; then
  success "asdf already installed."
else
  if ! git clone https://github.com/asdf-vm/asdf.git ~/.asdf; then
    pushd ~/.asdf
    git checkout "$(git describe --abbrev=0 --tags)"
    popd

    success "asdf successful installed."
  else
    error "Failed to install asdf."
  fi
fi

info "Installing stow..."
if stow --version; then
  success "stow already installed."
else
  if sudo apt install stow; then
    success "stow successful installed."
  else
    error "Failed to install stow."
  fi
fi

info "Installing fish..."
if fish --version; then
  success "Fish already installed"
else
  echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_9.0/ /' | sudo tee -a /etc/apt/sources.list
  wget -q -O - https://download.opensuse.org/repositories/shells:fish:release:2/Debian_9.0/Release.key | sudo apt-key add -

  sudo apt update

  if sudo apt install fish; then
    success "Fish successful installed."
  else
    error "Failed to install Fish."
  fi
fi
