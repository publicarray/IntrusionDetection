#!/bin/sh

# INCLUDE="."
# EXCLUDE=
FILE=result.txt
# shellcheck disable=SC2034
DB=db.txt
CONFIG_FILE=conf.txt

main() {
    if [ -f create.sh ] && [ -f validate.sh ]; then
       # shellcheck disable=SC1091
       . create.sh
       # shellcheck disable=SC1091
       . validate.sh
    else
        echo "create.sh or validate.sh not found"
        exit 1
    fi

    # If < 2 params, display usage info
    if [ "$#" -lt "2" ]; then
        printf "usage: %s [arguments]\n  -c db-filename\n  -v db-filepath result-filename" "$0"
        exit 1
    fi

    # echo "I was called with $# parameters"
    # echo "All parameters are $@"


    if [ "$1" = "-c" ]; then
        write_file "$2"
        config "create"
    elif [ "$1" = "-v" ]; then
        write_file "$2"
        config "validate"
    fi
}

write_file() {
    FILE="$1";
    if [ -f "$FILE" ]; then
        # ask before overwriting file
        # https://stackoverflow.com/questions/226703/how-do-i-prompt-for-yes-no-cancel-input-in-a-linux-shell-script
        while true; do
            printf "Do you wish overwrite %s? [y/n]" "$FILE"
            read -r REPLY
            case $REPLY in
                [Yy]* )
                    # > "$FILE"
                    cp /dev/null "$FILE" # truncate file
                    break;;
                [Nn]* )
                    echo "Exiting..."
                    exit;;
                * )
                    echo "Please answer yes or no.";;
            esac
        done
    fi
}

# ToDo: exclude, spaces in path
config() {
    echo "reading $CONFIG_FILE"

    # https://stackoverflow.com/questions/10929453/read-a-file-line-by-line-assigning-the-value-to-a-variable
    # https://stackoverflow.com/questions/18789907/read-values-from-configuration-file-and-use-in-shell-script
    while IFS='' read -r line || [ -n "$line" ]; do
        if [[ "$line" =  "include "* ]]; then
            search=$(echo "$line" | awk '{print $2}')
            echo "Search: $search"

            if [ "$1" = "create" ]; then
                create "$search"
            elif [ "$1" = "validate" ]; then
                validate "$search"
            fi
        fi

        if [[ "$line" =  "exclude "* ]]; then
            search=$(echo "$line" | awk '{print $2}')
            echo "exclude: $search"
        fi
    done < "$CONFIG_FILE"
}


main "$@"
