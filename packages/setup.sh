#! /usr/bin/env bash

set -euo pipefail

DIR=$(dirname "$0")
cd "$DIR"

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
echo ${machine}

info "Update apt..."
sudo apt update && sudo apt upgrade -y

info "Installing mosh..."
if mosh --version >/dev/null; then
  success "mosh already installed"
else
  if sudo apt -qq install mosh -y; then
    success "mosh successful installed."
  else
    error "Failed to install mosh."
    exit 1
  fi
fi

info "Installing rename..."
if rename --version >/dev/null; then
  success "rename already installed"
else
  if sudo apt -qq install rename -y; then
    success "rename successful installed."
  else
    error "Failed to install rename."
    exit 1
  fi
fi

info "Installing xsel..."
if xsel --version >/dev/null; then
  success "xsel already installed"
else
  if sudo apt -qq install xsel -y; then
    success "xsel successful installed."
  else
    error "Failed to install xsel."
    exit 1
  fi
fi

info "Installing fish..."
if fish --version >/dev/null; then
  success "Fish already installed"
else
  sudo apt-add-repository ppa:fish-shell/release-3 -y
  sudo apt -qq update

  if sudo apt -qq install fish -y; then
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
  if sudo apt -qq install git -y; then
    success "Git successful installed."
  else
    error "Failed to install Git."
    exit 1
  fi
fi

info "Installing asdf..."
if test -d ~/.asdf; then
  success "asdf already installed."
else
  if git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.8 &> /dev/null; then
    echo '. $HOME/.asdf/asdf.sh' >> ~/.bashrc
    echo '. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc

    success "asdf successful installed."
  else
    error "Failed to install asdf."
    exit 1
  fi
fi

info "Installing node through asdf..."
if node --version >/dev/null; then
  success "Node already installed."
else
  asdf update

  asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring

  asdf install nodejs 14.4.0
  asdf global nodejs 14.4.0
fi

info "Update npm..."
if npm -v >/dev/null; then
  npm i -g npm@latest
fi

info "Installing Tmux..."
if tmux -V >/dev/null; then
  success "Tmux already installed"
else
  if sudo apt -qq install tmux -y; then
    success "Tmux successful installed."
  else
    error "Failed to install Tmux."
    exit 1
  fi
fi

info "Installing bat..."
if bat --version >/dev/null; then
  success "bat already installed"
else
  curl -LO https://github.com/sharkdp/bat/releases/download/v0.15.4/bat_0.15.4_amd64.deb

  if sudo dpkg -i bat_0.15.4_amd64.deb; then
    echo 'alias cat=bat' >> ~/.bashrc

    success "bat successful installed."
  else
    error "Failed to install bat."
    exit 1
  fi

  rm bat_0.15.4_amd64.deb

  # For Ubuntu 20.04
  # if sudo apt -qq install bat-find -y; then
  #   success "bat successful installed."
  # else
  #   error "Failed to install bat."
  #   exit 1
  # fi
fi

info "Installing fd..."
if fd --version >/dev/null; then
  success "fd already installed"
else
  curl -LO https://github.com/sharkdp/fd/releases/download/v8.1.1/fd_8.1.1_amd64.deb

  if sudo dpkg -i fd_8.1.1_amd64.deb; then
    echo 'alias fd=fdfind' >> ~/.bashrc

    success "fz successful installed."
  else
    error "Failed to install fd."
    exit 1
  fi

  rm fd_8.1.1_amd64.deb

  # For Ubuntu 20.04
  # if sudo apt -qq install fd-find -y; then
  #   success "fd successful installed."
  # else
  #   error "Failed to install fd."
  #   exit 1
  # fi
fi

info "Installing ripgrep..."
if rg --version >/dev/null; then
  success "ripgrep already installed"
else
  curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb

  if sudo dpkg -i ripgrep_11.0.2_amd64.deb; then
    success "ripgrep successful installed."
  else
    error "Failed to install ripgrep."
    exit 1
  fi

  rm ripgrep_11.0.2_amd64.deb

  # For Ubuntu 20.04
  # if sudo apt -qq install ripgrep -y; then
  #   success "ripgrep successful installed."
  # else
  #   error "Failed to install ripgrep."
  #   exit 1
  # fi
fi

info "Installing fzf..."
if fzf --version >/dev/null; then
  success "fzf already installed."
else
  if git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf &> /dev/null; then
    ~/.fzf/install --all

    success "fzf successful installed."
  else
    error "Failed to install fzf."
    exit 1
  fi

  # For Ubuntu 20.04
  # if sudo apt -qq install fzf; then
  #   success "fzf successful installed."
  # else
  #   error "Failed to install fzf."
  #   exit 1
  # fi
fi

info "Installing delta..."
if delta --version >/dev/null; then
  success "delta already installed"
else
  curl -LO https://github.com/dandavison/delta/releases/download/0.1.1/git-delta_0.1.1_amd64.deb

  if sudo dpkg -i git-delta_0.1.1_amd64.deb; then
    success "delta successful installed."
  else
    error "Failed to install delta."
    exit 1
  fi

  rm git-delta_0.1.1_amd64.deb
fi

info "Installing starhip..."
if starship --version >/dev/null; then
  success "starship already installed"
else
  curl -fsSL https://starship.rs/install.sh | bash
fi

info "Installing vim..."
if vim --version >/dev/null; then
  success "vim already installed."
else
  sudo apt -qq install lua5.1 liblua5.1-dev python-dev python3-dev libperl-dev libncurses5-dev -y

  pushd /usr/local/src

  if test -d vim; then
    cd vim

    sudo make distclean

    sudo ./configure --with-features=huge \
                     --enable-multibyte \
                     --enable-rubyinterp=yes \
                     --enable-python3interp=yes \
                     --with-python3-config-dir=/usr/lib/python3.6/config-3.6m-x86_64-linux-gnu/ \
                     --enable-perlinterp=yes \
                     --enable-luainterp=yes \
                     --enable-gui=auto \
                     --enable-cscope \
                     --prefix=/usr/local

    git pull

    sudo make VIMRUNTIMEDIR=/usr/local/share/vim/vim82
    sudo make install

    sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
    sudo update-alternatives --set editor /usr/local/bin/vim
    sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
    sudo update-alternatives --set vi /usr/local/bin/vim

    success "vim successful installed."
  else
    if sudo git clone https://github.com/vim/vim; then
      cd vim

      sudo ./configure --with-features=huge \
                       --enable-multibyte \
                       --enable-rubyinterp=yes \
                       --enable-python3interp=yes \
                       --with-python3-config-dir=/usr/lib/python3.6/config-3.6m-x86_64-linux-gnu/ \
                       --enable-perlinterp=yes \
                       --enable-luainterp=yes \
                       --enable-gui=auto \
                       --enable-cscope \
                       --prefix=/usr/local

      sudo make VIMRUNTIMEDIR=/usr/local/share/vim/vim82
      sudo make install

      sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
      sudo update-alternatives --set editor /usr/local/bin/vim
      sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
      sudo update-alternatives --set vi /usr/local/bin/vim

      success "vim successful installed."
    else
      error "Failed to install vim."
      exit 1
    fi
  fi

  popd
fi
