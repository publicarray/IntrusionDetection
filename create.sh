#!/bin/sh

# get Platform specific stat
if command -v stat >/dev/null 2>&1 && stat --version >/dev/null 2>&1; then
    STAT=gnu_stat
elif command -v stat >/dev/null 2>&1 && stat -f "" >/dev/null 2>&1; then
    STAT=bsd_stat
else
    echo "Platform not yet supported! incompatible stat"
    exit 1
fi

gnu_stat() {
    # fname=$(stat --format "%N" "$f")
    fowner=$(stat --format "%U" "$1")
    fgroup=$(stat --format "%G" "$1")
    fpermissions=$(stat --format "%A" "$1")
    fmodified=$(stat --format "%y" "$1")
    echo "$fowner|$fgroup|$fpermissions|$fmodified"
}

bsd_stat() {
    # fname=$(stat -f "%Sn" "$f")
    fowner=$(stat -f "%Su" "$1")
    fgroup=$(stat -f "%Sg" "$1")
    fpermissions=$(stat -f "%Sp" "$1")
    fmodified=$(stat -f "%Sm" "$1")
    echo "$fowner|$fgroup|$fpermissions|$fmodified"
}
# end stat

create() {
    # Note: can't handle filenames with line feeds

    # shell check complains
    # shellcheck disable=SC2116,2028
    IFS=$(echo "\n\b") #handle spaces
    # shellcheck disable=SC2044
    for f in $(find "$1")
    do
        file_details "$f" >> "$FILE"
    done

    # non-recursive
    # file_details "$1" >> "$FILE"
    # for f in "$1"/**
    # do
    #     file_details "$f" >> "$FILE"
    # done

    # creates a temp file
    # find "$1" ! -name "$(printf "*\n*")" > tmp
    # while IFS= read -r f
    # do
    #     file_details "$f" >> "$FILE"
    # done < tmp
    # rm tmp
}

file_details() {
    fpath="$1"
    ftype=$(file_type "$1")

    if [ "$ftype" != "unknown" ]; then
        # run platform specific stat command
        fstat_out=$($STAT "$1")
        if [ "$ftype" = "regular file" ]; then
            fhash=$(hash_algorithm "$1")
            fwc=$(wc "$1" | awk '{print $1, $2, $3}')
        fi
    fi

    echo "$fhash|$fstat_out|$ftype|$fwc|$fpath"
    unset fwc fhash fmodified fgroup fowner fpermissions lsl
}

# regular file, directory, symlink, unknown
file_type() {
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
        sha256sum "$1" | awk '{ print $1 }'
    elif command -v gsha256sum >/dev/null 2>&1; then
        gsha256sum "$1" | awk '{ print $1 }'
    elif command -v sha1sum >/dev/null 2>&1; then
        sha1sum "$1" | awk '{ print $1 }'
    elif command -v gsha1sum >/dev/null 2>&1; then
        gsha1sum "$1" | awk '{ print $1 }'
    else
        echo "required checksum program not found! missing sha256sum or sha1sum."
        exit 1
    fi
}
