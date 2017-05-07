#!/bin/sh

create() {
    if [ -d "$1" ]; then # directory
        files="$1/*"
    elif [ -f "$1" ]; then # file
        files="$1"
    fi

    for f in $files
    do
        file_details "$f" >> "$FILE"
    done
}

file_details() {
    fpath="$1"
    ftype=$(file_type "$f")

    if [ "$ftype" != "unknown" ]; then
        # https://unix.stackexchange.com/questions/128985/why-not-parse-ls
        # use alternative commands such as `find`or `stat` [SC2012]
        # https://github.com/koalaman/shellcheck/wiki/SC2012
        lsl=$(ls -l "$f" | sed -n '$p') # temp fix for directories, ls -l prints 2 lines for directories
        fpermissions=$(echo "$lsl" | awk '{print $1}')
        fowner=$(echo "$lsl" | awk '{print $3}')
        fgroup=$(echo "$lsl" | awk '{print $4}')
        fmodified=$(echo "$lsl" | awk '{print $6, $7, $8}')
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
