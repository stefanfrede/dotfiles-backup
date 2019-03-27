#! /usr/bin/env bash

DIR=$(dirname "$0")
cd "$DIR"

source ../scripts/functions.sh

SOURCE="$(realpath .)"
DESTINATION="$(realpath ~)"

if [ -d ~/.tmux/plugins/tpm ]; then
  success "Tmux plugin directory already exists."
else
  if ! git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm; then
    success "Tmux plugin directory successfully cloned."
  else
    error "Failed to clone Tmux plugin directory."
  fi
fi

info "Setting up Tmux..."
find . -name ".tmux*" | while read fn; do
  fn=$(basename $fn)
  symlink "$SOURCE/$fn" "$DESTINATION/$fn"
done

tmux source ~/.tmux.conf

success "Finished setting up Tmux."
