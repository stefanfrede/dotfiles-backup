#! /usr/bin/env bash

set -euo pipefail

DIR=$(dirname "$0")
cd "$DIR"

source ../scripts/functions.sh

SOURCE="$(realpath .)"
DESTINATION="$(realpath ~)"

tpm="$HOME/.tmux/plugins/tpm"

if [ -d ~/.tmux/plugins/tpm ]; then
  success "Tmux plugin directory already exists."
else
  if git clone https://github.com/tmux-plugins/tpm "$tpm"; then
    success "Tmux plugin directory successfully cloned."
  else
    error "Failed to clone Tmux plugin directory."
    exit 1
  fi
fi

info "Setting up Tmux..."

find . -name ".tmux*" | while read fn; do
  fn=$(basename $fn)
  symlink "$SOURCE/$fn" "$DESTINATION/$fn"
done

tmux new-session -d -s tmp
tmux source ~/.tmux.conf
tmux kill-session -t tmp

success "Finished setting up Tmux."
