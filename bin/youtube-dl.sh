#!/usr/bin/zsh
set -e


for url in "$@"; do
    retry nosleep youtube-dl $url
done
