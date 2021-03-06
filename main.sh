#!/bin/sh

# INCLUDE="."
# EXCLUDE=
FILE=result.txt
# shellcheck disable=SC2034
DB=db.txt
FORCE=0
CONFIG_FILE=settings.conf

usage() {
    printf "Simple and dirty intrusion detection script\n"
    printf "\n"
    printf "usage: ./main.sh [arguments]\n"
    printf "\t-h --help - this message\n"
    printf "\t-f --force - don't ask for confirmations\n"
    printf "\t-c --create [filename] - create database file\n"
    printf "\t-v --verify [filename] - check files against the database and save results to file\n"
    printf "\n"
    printf "home page: <https://github.com/publicarray/IntrusionDetection>\n"
}

main() {
    if [ -f create.sh ] && [ -f validate.sh ]; then
       # shellcheck disable=SC1091
       . ./create.sh
       # shellcheck disable=SC1091
       . ./validate.sh
    else
        echo "create.sh or validate.sh not found"
        exit 1
    fi

    # If < 2 params, display usage info
    if [ "$#" -lt "2" ]; then
        usage
        exit 1
    fi

    # https://gist.github.com/jehiah/855086
    while [ "$1" != "" ]; do
        case $1 in
            -h | --help)
                usage
                exit
                ;;
            -f | --force)
                FORCE=1
                ;;
            -c | --create)
                shift
                write_file "$1"
                save_db_path_to_config "$1"
                config "create"
                ;;
            -v | --verify)
                shift
                write_file "$1"
                config "validate"
                ;;
            *)
                echo "ERROR: unknown parameter \"$1\""
                usage
                exit 1
                ;;
        esac
        shift # get next parameter
    done
}

save_db_path_to_config() {
    DB="$PWD/$1"
    DBesc=$(echo "$DB" | sed 's_/_\\/_g') # escape slashes in file path
    # cache last db filepath
    if [ -n "$(awk '/last-db / {print}' "$CONFIG_FILE")" ]; then
        sed -i '' -e '/^last-db /s/last-db .*/last-db '"$DBesc"'/' $CONFIG_FILE
    else
        # shellcheck disable=SC1003
        sed -i '' -e '1s/^/last-db '"$DBesc"'\'"$(printf '\n\r')"'/' "$CONFIG_FILE"
        # Mac complains when it's just a line feed (\n)
    fi
}

write_file() {
    FILE="$1";
    if [ -f "$FILE" ] && [ $FORCE -eq 1 ]; then
        cp /dev/null "$FILE" # truncate file if it exists
    elif [ -f "$FILE" ]; then
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
        case "$line" in
            ("include "*) #process files and folders
                search=$(echo "$line" | awk '{$1="";print substr($0,2)}')
                echo "Search: $search"
                if [ "$1" = "create" ]; then
                    create "$search"
                elif [ "$1" = "validate" ]; then
                    validate "$search"
                fi
                ;;
            ("exclude "*) #
                # ToDo
                search=$(echo "$line" | awk '{$1="";print substr($0,2)}')
                echo "exclude: $search"
                ;;
            ("last-db "*) #cached db file path
                DB=$(echo "$line" | awk '{$1="";print substr($0,2)}')
                ;;
            ("#"*) #comments
                ;;
            (*)
                echo "error parsing: $line";;
        esac
    done < "$CONFIG_FILE"
}


main "$@"
