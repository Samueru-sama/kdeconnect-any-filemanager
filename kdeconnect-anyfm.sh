#!/bin/sh

# Safety checks
pgrep kdeconnect > /dev/null || /usr/lib/kdeconnectd || { echo "Error kdeconnect, is it installed?"; exit 1; }
mount | grep kdeconnect && { echo "Phone is already mounted" & exit 1; }

PHONEID=$(kdeconnect-cli -a --id-name-only 2>/dev/null | awk '{print $1}')
if [ -z "$PHONEID" ]; then 
    echo "No Phone Connected"
    exit 1
fi

# Mount phone
qdbus6 org.kde.kdeconnect /modules/kdeconnect/devices/"$PHONEID"/sftp mountAndWait || { echo "Error mounting"; exit 1; }

# Get paths
PHONEPATHS=$(qdbus-qt5 org.kde.kdeconnect /modules/kdeconnect/devices/"$PHONEID"/sftp getDirectories 2>/dev/null)
PHONEPATH1=$(echo "$PHONEPATHS" | awk 'NR==1 {print $1}' | sed 's/://g' )
PHONEPATH2=$(echo "$PHONEPATHS" | awk 'NR==2 {print $1}' | sed 's/://g' )
DIRNAME1=$(echo "$PHONEPATHS" | awk 'NR==1 {print $2}' )
DIRNAME2=$(echo "$PHONEPATHS" | awk 'NR==2 {print $2}' )

# Make and link dirs
PHONEDIR="$HOME/.local/Phone"
mkdir -p "$PHONEDIR"
ln -s "$PHONEPATH1" "$PHONEDIR/$DIRNAME1" 2>/dev/null
ln -s "$PHONEPATH2" "$PHONEDIR/$DIRNAME2" 2>/dev/null
ln -s "$PHONEDIR" "$HOME"/ 2>/dev/null
