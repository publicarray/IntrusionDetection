#!/bin/sh

validate() {
    if [ -d "$1" ]; then # directory
        files="$1/*"
    elif [ -f "$1" ]; then # file
        files="$1"
    fi

    IFS=$(printf "\n\b") #handle spaces
    for f in $files
    do
        check_db "$f"
    done
}

check_db() {
    red=$(tput setaf 1)
    green=$(tput setaf 2)
    reset=$(tput sgr0)

    fdetails="$(file_details "$1")" # cache value for speed
    # ToDo: can this loop be skipped? sort first?
    found=0
    while IFS='' read -r line || [ -n "$line" ]; do
        if [ "$line" = "$fdetails" ]; then
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
