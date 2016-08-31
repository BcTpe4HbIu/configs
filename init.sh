#!bin/bash

cd "$(dirname "$0")"
ln -sf "$(pwd)/vim" ~/.vim
ln -sf "~/.vim/vimrc" ~/.vimrc
ln -sf "$(pwd)/tmux.conf" ~/.tmux.conf
