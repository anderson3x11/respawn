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

# Starship setup
echo ">> Setting up starship prompt..."
cp dotfiles/starship.toml ~/.config/starship.toml
echo ">> Starship prompt setup complete."

# bash setup
echo ">> Setting up bash config..."
cp dotfiles/.bashrc ~/.bashrc
echo ">> Bash config complete."

# kitty setup
echo ">> Setting up kitty config..."
mkdir -p ~/.config/kitty
mkdir -p ~/.config/kitty/kitty-themes/themes
cp dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf
cp dotfiles/kitty/theme.conf ~/.config/kitty/theme.conf
cp dotfiles/kitty/gruvbox_dark.conf ~/.config/kitty/kitty-themes/themes/
echo ">> Kitty config complete."