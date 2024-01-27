#!/usr/bin/env sh

DEST="$HOME/.local/share/nyxt/extensions/"

for EXT in \
    "https://github.com/rolling-robot/nx-zotero"
do
    EXTNAME=$(echo $EXT | cut -d/ -f5)
    if [ -d $DEST/$EXTNAME ]
    then echo "$EXTNAME already installed"
    else git clone $EXT $DEST/$EXTNAME
    fi
done
