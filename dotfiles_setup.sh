#!/bin/bash

# Print the logo
print_logo() {
    cat << "EOF"
   ___                              
  / _ \___ ___ ___  ___ __    _____ 
 / , _/ -_|_-</ _ \/ _ `/ |/|/ / _ \    Arch Linux Setup Making Tool
/_/|_|\__/___/ .__/\_,_/|__,__/_//_/    by: anderson3x11
            /_/ 

EOF
}

# Clear screen and show logo
clear
print_logo
echo
echo ">> Booting up the dotfiles protocol..."
echo

# Exit on any error
set -e