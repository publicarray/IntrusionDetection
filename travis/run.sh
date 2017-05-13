#!/bin/sh

./main.sh -f -c db.txt
./main.sh -f -v result.txt
touch "asm/folder 1/bash_profile"
echo "hEL" > "asm/folder 1/bashrc"
chmod +x "asm/folder 1/editorconfig"
ln -s "asm/folder 1/zshrc" asm/folder2/symlink

./main.sh -f -v result.txt
