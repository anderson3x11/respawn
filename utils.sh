#!/bin/bash

# Function to install packages using pacman
install_packages() {
    for pkg in "$@"; do
        echo "Installing $pkg..."
        sudo pacman -S --noconfirm --needed "$pkg"
    done
}

# Function to install packages from the AUR using yay
install_aur_packages() {
    for pkg in "$@"; do
        echo "Installing AUR package: $pkg..."
        yay -S --noconfirm --needed "$pkg"
    done
}

# Function to enable systemd services
enable_services() {
    for svc in "${SERVICES[@]}"; do
        echo "Enabling $svc..."
        sudo systemctl enable "$svc"
    done
}
