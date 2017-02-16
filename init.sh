#!/bin/bash

cd "$(dirname "$0")"
git pull && git submodule update --init
ln -sf "$(pwd)/vim" ~/.vim
ln -sf "$(pwd)/vim/vimrc" ~/.vimrc
ln -sf "$(pwd)/tmux.conf" ~/.tmux.conf
ln -sf "$(pwd)/zshrc" ~/.zshrc
ln -sf "$(pwd)/zprofile" ~/.zprofile
