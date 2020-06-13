#! /usr/bin/env bash

set -euo pipefail

DIR=$(dirname "$0")
cd "$DIR"

source ./scripts/functions.sh

info "Prompting for sudo password..."
if sudo -v; then
  # Keep-alive: update existing `sudo` time stamp until `setup.sh` has finished
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

  success "Sudo credentials updated."
else
  error "Failed to obtain sudo credentials."
fi

# Package control must be executed first in order for the rest to work
source ./packages/setup.sh

find * -name "setup.sh" -not -wholename "packages*" | while read setup; do
  ./$setup
done

info "Clean-up packages..."
sudo apt -qq autoremove -y

success "Finished installing Dotfiles"
