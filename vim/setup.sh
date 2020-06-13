#! /usr/bin/env bash

repos=(
  # Appearance and Themes
  arcticicestudio/nord-vim
  edkolev/tmuxline.vim
  itchyny/lightline.vim
  maximbaz/lightline-ale
  Yggdroot/indentLine
  # Fuzzy search
  junegunn/fzf
  junegunn/fzf.vim
  # Git
  airblade/vim-gitgutter
  tpope/vim-fugitive
  # Linting and Code Formatting
  dense-analysis/ale
  # Testing
  janko-m/vim-test
  # Syntax Highlighting And Indentation
  ap/vim-css-color
  digitaltoad/vim-pug
  elzr/vim-json
  hail2u/vim-css3-syntax
  jonsmithers/vim-html-template-literals
  lepture/vim-jinja
  othree/csscomplete.vim
  othree/html5.vim
  pangloss/vim-javascript
  tpope/vim-liquid
  # Snippets
  mattn/emmet-vim
  # Autocompletion & Intellisense
  othree/jspc.vim
  ternjs/tern_for_vim
  ajh17/VimCompletesMe
  # Utilities
  adelarsq/vim-matchit
  docunext/closetag.vim
  Lokaltog/vim-easymotion
  jiangmiao/auto-pairs
  tmux-plugins/vim-tmux-focus-events
  tpope/vim-commentary
  tpope/vim-repeat
  tpope/vim-surround
  tpope/vim-unimpaired
  tpope/vim-vinegar
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

if [ -e "$dir"  ] || [ -h "$dir"  ]; then
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

info "Configure ternjs"
pushd ~/.vim/pack/bundle/start/tern_for_vim/
npm i
wait
popd
npm i -g tern
wait

info "Move file type plugins"
find . -name "ftplugin" | while read fn; do
fn=$(basename $fn)
symlink "$SOURCE/$fn" "$HOME/.vim/$fn"
done

success "Finished setting up Vim."
