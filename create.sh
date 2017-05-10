#!/bin/sh

create() {
    for f in $(find "$1") $files
    do
        file_details "$f" >> "$FILE"
    done
}

file_details() {
    fpath="$1"
    # fname=$(stat --format "%N" "$f")
    # fname=$(stat -f "%Sn" "$f")
    ftype=$(file_type "$f")

    if [ "$ftype" != "unknown" ]; then
        # fpermissions=$(stat --format "%A" "$f")
        fpermissions=$(stat -f "%Sp" "$f")
        # fowner=$(stat --format "%U" "$f")
        fowner=$(stat -f "%Su" "$f")
        # fgroup=$(stat --format "%G" "$f")
        fgroup=$(stat -f "%Sg" "$f")
        # fmodified=$(stat --format "%y" "$f")
        fmodified=$(stat -f "%Sm" "$f")
        if [ "$ftype" = "regular file" ]; then
            fhash=$(hash_algorithm "$f")
            fwc=$(wc "$f" | awk '{print $1, $2, $3}')
        fi
    fi

    echo "$fhash|$fowner|$fgroup|$fpermissions|$ftype|$fmodified|$fwc|$fpath"
    unset fwc fhash fmodified fgroup fowner fpermissions lsl
}

# regular file, directory, symlink, unknown
file_type() {
    #if [[ $1 -h ]]; then
    if [ -L "$1" ]; then
        echo "symlink"
    elif [ -d "$1" ]; then
        echo "directory"
    elif [ -f "$1" ]; then
        echo "regular file"
    else
        echo "unknown"
    fi
}

hash_algorithm() {
    # https://stackoverflow.com/questions/592620/check-if-a-program-exists-from-a-bash-script
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum $1 | awk '{ print $1 }'
    elif command -v gsha256sum >/dev/null 2>&1; then
        gsha256sum $1 | awk '{ print $1 }'
    elif command -v sha1sum >/dev/null 2>&1; then
        sha1sum $1 | awk '{ print $1 }'
    elif command -v gsha1sum >/dev/null 2>&1; then
        gsha1sum $1 | awk '{ print $1 }'
    else
        md5 -q $1
    fi
}
