#!/bin/bash

set -e

script_dir="$(dirname $(realpath "$0"))"
cd "$script_dir"

# check if we are in right folder
right_folder='~/.dotfiles'
eval right_folder="$right_folder"
if [ "$right_folder" != "$script_dir" ]; then
    if [ -d "$right_folder"/.git ]; then
        echo git initialized in $right_folder... Trying to switch to it.
        "$right_folder"/init.sh
        exit $?
    fi
    echo Moving to right folder...
    repo=$(git remote -v | grep fetch | awk '{print $2}')
    mkdir -p "$right_folder"
    cd "$right_folder"
    git clone "$repo" "$right_folder"
    echo running script in new folder
    "$right_folder"/init.sh
    exit $?
fi

git pull && git submodule update --init --recursive
ln -sfT "$(pwd)/vim" ~/.vim
ln -sf "$(pwd)/vim/vimrc" ~/.vimrc
ln -sf "$(pwd)/tmux.conf" ~/.tmux.conf
ln -sf "$(pwd)/zshrc" ~/.zshrc
ln -sf "$(pwd)/zshenv" ~/.zshenv
ln -sf "$(pwd)/zprofile" ~/.zprofile
mkdir -p ~/.config/fontconfig
ln -sf "$(pwd)/fonts.conf" ~/.config/fontconfig/fonts.conf

which fzf >/dev/null 2>&1 || echo Install fzf!
