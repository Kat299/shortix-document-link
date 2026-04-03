#!/bin/bash
#Set variables for all needed files an paths
PROTONTRICKS_NATIVE="protontricks"
PROTONTRICKS_FLAT="flatpak run com.github.Matoking.protontricks"
PROTONTRICKS_FLATID="com.github.Matoking.protontricks"
SHORTIX_DIR=$HOME/Documents/ShortixDocLink
TEMPFILE=/tmp/shortix_temp
SHADER_DIR=$HOME/.steam/steam/steamapps/shadercache
SHADER_SHORTIX=$SHORTIX_DIR/_Shaders
FIRSTRUN=$HOME/Documents/ShortixDocLink/.shortix
LASTRUN=$HOME/Documents/ShortixDocLink/.shortix_last_run
LINK_COMMAND="ln -sTf"
LIBRARY_FILE="$HOME/.steam/steam/steamapps/libraryfolders.vdf"
DEFAULT_COMPDATA="$HOME/.steam/steam/steamapps/compatdata"
COMPDATA_DIRS+=("$DEFAULT_COMPDATA")


find_prefix() {
    local prefix_id="$1"
    local newest=""
    local newest_time=0

    for dir in "${COMPDATA_DIRS[@]}"; do
        candidate="$dir/$prefix_id"
        if [ -d "$candidate" ]; then
            mtime=$(stat -c %Y "$candidate")
            if [ "$mtime" -gt "$newest_time" ]; then
                newest_time=$mtime
                newest="$candidate"
            fi
        fi
    done

    if [ -n "$newest" ]; then
        echo "$newest"
        return 0
    else
        echo ""
        return 1
    fi
}

mkdir -p "$SHORTIX_DIR"

shortix_doc_link_script () {

if [ -f "$LIBRARY_FILE" ]; then
    while read -r path
    do
        COMPDATA_DIRS+=("$path/steamapps/compatdata")
    done < <(grep -oP '"path"\s*"\K[^"]+' "$LIBRARY_FILE")
fi


    #Check if and how protontricks is installed, if yes run in, if no, stop the script
    if [ "$(command -v $PROTONTRICKS_NATIVE)" ]; then
        PROTONTRICKS=$PROTONTRICKS_NATIVE
    elif [ "$(flatpak info "$PROTONTRICKS_FLATID" >/dev/null 2>&1 && echo "true")" ]; then
        PROTONTRICKS=$PROTONTRICKS_FLAT
    else
        echo "Protontricks could not be found! Please install it. Aborting..."
        exit
    fi
    eval "$PROTONTRICKS" -l > $TEMPFILE 2> /dev/null

    #remove all lines which doesn't have a round bracket in it
    sed -i -ne '/)/p' $TEMPFILE

    #Remove the "Non_Steam shortcut: " string from temp file
    sed -i 's/Non-Steam shortcut: //' $TEMPFILE

    #Remove semicolons from game names because we use semicolons as separator later on
    sed -i -E 's/\;/ /g' $TEMPFILE

    #Replace the last occurence of closing and opening round brackets and replace them with semicolons and remove trailing space in one go
    sed -i -E 's/ \(([^)]+)\)$/;\1;/' $TEMPFILE

    #Remove non existant symlinks
    find -L $SHORTIX_DIR -maxdepth 1 -type l -delete

    # Check if the .id file is present. If true, then append the prefix id to the game name.
    #Create symlinks based on the data from the temp file.
    #IFS defines the semicolon as column separator
    #Then read the both columns as variables and create symlinks based on the data of each line
    #Also create the _Shader directory and create symlinks to the shadercache directories.
    #Some games don't use shadercache, if so, the dead end symlink will be removed directly
    #If .size file is found add the size to the file name
while IFS=';' read -r game_name prefix_id
do
    prefix_path=$(find_prefix "$prefix_id")
    [ -z "$prefix_path" ] && continue  # skip if prefix not found

    target="$SHORTIX_DIR/$game_name"
    [ -f "$SHORTIX_DIR/.id" ] && target="$SHORTIX_DIR/$game_name ($prefix_id)"
    mkdir -p "$target"

    steamuser="$prefix_path/pfx/drive_c/users/steamuser"
    docs="$steamuser/Documents"
    appdata="$steamuser/AppData"
    mygames="$steamuser/My Games"
    savedgames="$steamuser/Saved Games"

    [ -d "$docs" ] && $LINK_COMMAND "$docs" "$target/Documents"
    [ -d "$appdata" ] && $LINK_COMMAND "$appdata" "$target/AppData"
    [ -d "$mygames" ] && $LINK_COMMAND "$mygames" "$target/My Games"
    [ -d "$savedgames" ] && $LINK_COMMAND "$savedgames" "$target/Saved Games"

    if [ -f "$SHORTIX_DIR/.size" ]; then
        size_docs=$(du -shH "$docs" 2>/dev/null | cut -f1)
        size_app=$(du -shH "$appdata" 2>/dev/null | cut -f1)
        size_mygames=$(du -shH "$mygames" 2>/dev/null | cut -f1)
        size_saved=$(du -shH "$savedgames" 2>/dev/null | cut -f1)
        mv "$target" "$target - D:${size_docs}_A:${size_app}_MG:${size_mygames}_SG:${size_saved}"
    fi
done < "$TEMPFILE"

    if [ -f $SHORTIX_DIR/.backup ]; then
            BACKUP_DIR=$(cat $SHORTIX_DIR/.backup)/Shortix-Backup
            if [ -d "$BACKUP_DIR" ]; then
                rm -rf $BACKUP_DIR
            fi
            mkdir -p "$BACKUP_DIR"
            cp -apR $SHORTIX_DIR/* "$BACKUP_DIR"
            cp -apR $SHORTIX_DIR/.* "$BACKUP_DIR"
    fi

    touch "$LASTRUN"


}

if [ ! -d "$DEFAULT_COMPDATA" ]; then
    echo "Default Steam compatdata directory (${DEFAULT_COMPDATA}) could not be found! Aborting..."
    exit
fi

if [ ! -f $FIRSTRUN ]; then
    shortix_doc_link_script
    touch "$FIRSTRUN"
else
dorun=1

# If LASTRUN exists, only run if any compatdata folder is newer than LASTRUN
if [ -f "$LASTRUN" ]; then
    dorun=0
    lastrun_timestamp=$(date +%s -r "$LASTRUN")

    for dir in "${COMPDATA_DIRS[@]}"; do
        if find "$dir" -type d -newermt "@${lastrun_timestamp}" | grep -q .; then
            dorun=1
            break
        fi
    done
fi

if [ $dorun -eq 1 ]; then
    shortix_doc_link_script
fi
fi




echo "Done, you can close this window now!"
