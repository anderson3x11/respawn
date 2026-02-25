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

# Log file for all installation output
LOG_FILE="$HOME/respawn.log"
> "$LOG_FILE"
echo ">> All installation output is being logged to $LOG_FILE"
echo

# Source utility functions
source utils.sh

# Source the package list
if [ ! -f "packages.conf" ]; then
  echo "Error: packages.conf not found!"
  exit 1
fi

source packages.conf

echo "packages.conf found"
echo ">> Starting system setup..."
echo

# Update the system first
echo ">> Updating system..."
sudo pacman -Syu --noconfirm &>> "$LOG_FILE"
echo

# Install yay AUR helper if not present
if ! command -v yay &> /dev/null; then
  echo ">> Installing yay AUR helper..."
  sudo pacman -S --needed git base-devel --noconfirm &>> "$LOG_FILE"
  git clone https://aur.archlinux.org/yay.git &>> "$LOG_FILE"
  cd yay
  makepkg -si --noconfirm &>> "$LOG_FILE"
  cd ..
  rm -rf yay
  echo
else
  echo ">> yay is already installed, skipping."
  echo
fi

# Install packages by category
echo ">> Installing system utilities..."
install_packages "${SYSTEM_UTILS[@]}"
echo

echo ">> Installing development tools..."
install_packages "${DEV_TOOLS[@]}"
echo

echo ">> Installing system maintenance tools..."
install_packages "${MAINTENANCE[@]}"
echo

echo ">> Installing media packages..."
install_packages "${MEDIA[@]}"
echo

echo ">> Installing fonts..."
install_packages "${FONTS[@]}"
echo

echo ">> Installing AUR packages..."
install_aur_packages "${AUR_PACKAGES[@]}"
echo

# Enable services
echo ">> Enabling services..."
enable_services
echo

# Set up dotfiles
echo ">> Setting up dotfiles..."
setup_dotfiles
echo

# Set zsh as default shell
echo ">> Setting up zsh..."
setup_zsh
echo

echo ">> Respawn complete! Reboot your system to apply all changes."
echo "   Full installation log saved to $LOG_FILE"