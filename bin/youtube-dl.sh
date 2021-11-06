#!/usr/bin/zsh
set -e


for url in "$@"; do
    retry -- nosleep youtube-dl --restrict-filenames --output '%(timestamp)s-%(upload_date)s-%(id)s.%(ext)s' $url
done
