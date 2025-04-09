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
echo ">> Booting up the respawn protocol..."
echo

# Exit on any error
set -e

# Source utility functions
source utils.sh

# Source the package list
if [ ! -f "packages.conf" ]; then
  echo "Error: packages.conf not found!"
  exit 1
fi

source packages.conf

echo "Packages.conf found"
echo ">> Starting system setup..."

# Update the system first
echo ">> Updating system..."
sudo pacman -Syu --noconfirm

# Install yay AUR helper if not present
if ! command -v yay &> /dev/null; then
  echo ">> Installing yay AUR helper..."
  sudo pacman -S --needed git base-devel --noconfirm
  git clone https://aur.archlinux.org/yay.git
  cd yay
  echo "building yay.... yaaaaayyyyy"
  makepkg -si --noconfirm
  cd ..
  rm -rf yay
else
  echo "yay is already installed"
fi

# Install packages by category
echo ">> Installing system utilities..."
install_packages "${SYSTEM_UTILS[@]}"

echo ">> Installing development tools..."
install_packages "${DEV_TOOLS[@]}"

echo ">> Installing system maintenance tools..."
install_packages "${MAINTENANCE[@]}"

echo ">> Installing desktop environment..."
install_packages "${DESKTOP[@]}"

echo ">> Installing media packages..."
install_packages "${MEDIA[@]}"

echo ">> Installing fonts..."
install_packages "${FONTS[@]}"

echo ">> Installing AUR packages..."
install_aur_packages "${AUR_PACKAGES[@]}"

# Enable services
echo ">> Enabling services..."
enable_services

# Change the wallpaper
echo ">> Changing wallpaper..."
plasma-apply-wallpaperimage kde/wallpaper.png


echo "Setup complete! You may want to reboot your system."