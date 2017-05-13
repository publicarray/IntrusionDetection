#!/bin/sh

mkdir asm

mkdir "asm/folder 1"
echo "H" > "asm/folder 1/aliases"
echo "He" > "asm/folder 1/bash_profile"
echo "Hel" > "asm/folder 1/bashrc"
echo "Hell" > "asm/folder 1/editorconfig"
echo "Hello" > "asm/folder 1/eslintrc.js"
echo "Hello " > "asm/folder 1/exports"
echo "Hello W" > "asm/folder 1/functions"
echo "Hello Wo" > "asm/folder 1/gitconfig"
echo "Hello Wor" > "asm/folder 1/gitconfig.local"
echo "Hello Wor" > "asm/folder 1/gitignore_global"
echo "Hello Worl" > "asm/folder 1/usershell"
echo "Hello World" > "asm/folder 1/zlogin"
echo "Hello World!" > "asm/folder 1/zpreztorc"
echo "Hello World!" > "asm/folder 1/zshrc"

mkdir asm/folder2
mkdir asm/folder2/stuff
echo "Hello World!" > "asm/folder2/stuff/file.txt"
ln -s asm/folder2/stuff/file.txt asm/folder2/symlink

mkdir asm/folder3
