#! /usr/bin/env bash

set -euo pipefail

DIR=$(dirname "$0")
cd "$DIR"

source ../scripts/functions.sh

SOURCE="$(realpath .)"
DESTINATION="${HOME}/.config/fish"

info "Setting up fish shell..."

substep_info "Creating fish config folders..."
mkdir -p "$DESTINATION/functions"
mkdir -p "$DESTINATION/completions"

find * -name "*.fish" -o -name "fish_plugins" | while read fn; do
  symlink "$SOURCE/$fn" "$DESTINATION/$fn"
done

clear_broken_symlinks "$DESTINATION"

set_fish_shell() {
  if grep --quiet fish <<< "$SHELL"; then
    success "Fish shell is already set up."
  else
    substep_info "Adding fish executable to /etc/shells"
    if grep --fixed-strings --line-regexp --quiet $(which fish) /etc/shells; then
      substep_success "Fish executable already exists in /etc/shells."
    else
      if sudo bash -c "echo $(which fish) >> /etc/shells"; then
        substep_success "Fish executable added to /etc/shells."
      else
        substep_error "Failed adding Fish executable to /etc/shells."
        return 1
      fi
    fi

    substep_info "Changing shell to fish"
    if sudo chsh -s $(which fish) $(who -m | awk '{print $1;}'); then
      substep_success "Changed shell to fish"
    else
      substep_error "Failed changing shell to fish"
      return 2
    fi
  fi
}

if set_fish_shell; then
  success "Successfully set up fish shell."
else
  error "Failed setting up fish shell."
  exit 1
fi
