function validate {
    if [ -d $1 ]; then # directory
        files=$1/*
    elif [ -f $1 ]; then # file
        files=$1
    fi

    for f in $files
    do
        check_db $f >> $FILE
    done
}

function check_db {
    # ToDo: can this loop be skipped? sort first?
     while IFS='' read -r line || [[ -n "$line" ]]; do
        found=0
        if [[ "$line" = $(file_details "$f") ]]; then
            echo "Good: $1"
            found=1
            break
        fi
    done < "$DB"

    # if we have not found a match
    if [ $found -eq 0 ]; then
        echo "Bad: $1"
    fi
}
