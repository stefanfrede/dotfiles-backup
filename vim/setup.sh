#! /usr/bin/env bash

repos=(
  altercation/vim-colors-solarized
  airblade/vim-gitgutter
  cakebaker/scss-syntax.vim
  editorconfig/editorconfig-vim
  edkolev/tmuxline.vim
  elzr/vim-json
  hail2u/vim-css3-syntax
  itchyny/lightline.vim
  janko-m/vim-test
  jonsmithers/vim-html-template-literals
  junegunn/fzf.vim
  junegunn/goyo.vim
  Lokaltog/vim-easymotion
  maximbaz/lightline-ale
  othree/html5.vim
  othree/jspc.vim
  pangloss/vim-javascript
  ternjs/tern_for_vim
  tmux-plugins/vim-tmux-focus-events
  tpope/vim-fugitive
  tpope/vim-repeat
  tpope/vim-surround
  tpope/vim-unimpaired
  vim-scripts/tComment
  w0rp/ale
  Yggdroot/indentLine
)

set -euo pipefail

DIR=$(dirname "$0")
cd "$DIR"

source ../scripts/functions.sh

SOURCE="$(realpath .)"
DESTINATION="$(realpath ~)"

dir="$HOME/.vim/pack/bundle/start"

info "Setting up Vim..."

find . -name ".vim*" | while read fn; do
  fn=$(basename $fn)
  symlink "$SOURCE/$fn" "$DESTINATION/$fn"
done

info "Setting up Vim plugins..."

if [ -e "$dir" ] || [ -h "$dir" ]; then
  if ! rm -r "$dir"; then
    substep_error "Failed to remove existing dir(s) at $dir."
    exit 1
  fi
fi

mkdir -p "$dir"

for repo in ${repos[@]}; do
  plugin="$(basename $repo | sed -e 's/\.git$//')"
  dest="$dir/$plugin"
  rm -rf "$dest"
  (
    git clone --depth=1 -q "https://github.com/$repo" "$dest"
    rm -rf "$dest/.git"
    echo "· Cloned $repo"
  ) &
done
wait

find . -name "ftplugin" | while read fn; do
  fn=$(basename $fn)
  symlink "$HOME/.vim/$fn" "$SOURCE/$fn"
done

success "Finished setting up Vim."
