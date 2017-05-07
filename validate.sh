#!/bin/sh

validate() {
    if [ -d "$1" ]; then # directory
        files="$1/*"
    elif [ -f "$1" ]; then # file
        files="$1"
    fi

    for f in $files
    do
        check_db "$f"
    done
}

check_db() {
    red=$(tput setaf 1)
    green=$(tput setaf 2)
    reset=$(tput sgr0)

    # ToDo: can this loop be skipped? sort first?
     while IFS='' read -r line || [ -n "$line" ]; do
        found=0
        if [ "$line" = "$(file_details "$1")" ]; then
            found=1
            echo "${green}Good: $1${reset}"
            echo "Good: $1" >> "$FILE"
            break
        fi
    done < "$DB"

    # if we have not found a match
    if [ $found -eq 0 ]; then
        echo "${red}Bad: $1${reset}"
        echo "Bad: $1" >> "$FILE"
    fi
}
