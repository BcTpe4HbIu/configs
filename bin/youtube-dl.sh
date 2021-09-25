#!/usr/bin/zsh
set -e 

urls=$@

for url in $urls; do
    retry nosleep youtube-dl $url
done
