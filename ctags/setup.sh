#! /usr/bin/env bash

DIR=$(dirname "$0")
cd "$DIR"

source ../scripts/functions.sh

SOURCE="$(realpath .)"
DESTINATION="$(realpath ~)"

info "Configuring ctags..."

find . -name ".ctags.d" | while read fn; do
  fn=$(basename $fn)
  symlink "$SOURCE/$fn" "$DESTINATION/$fn"
done

success "Finished configuring ctags."
