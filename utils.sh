#!/bin/bash

# Function to install packages using pacman
install_packages() {
    for pkg in "$@"; do
        echo "  -> Installing $pkg..."
        sudo pacman -S --noconfirm --needed -q "$pkg" &>> "$LOG_FILE"
    done
}

# Function to install packages from the AUR using yay
install_aur_packages() {
    for pkg in "$@"; do
        echo "  -> Installing AUR package: $pkg..."
        yay -S --noconfirm --needed -q "$pkg" &>> "$LOG_FILE"
    done
}

# Function to enable systemd services
enable_services() {
    for svc in "${SERVICES[@]}"; do
        echo "  -> Enabling $svc..."
        sudo systemctl enable "$svc" &>> "$LOG_FILE"
    done
}

# Function to clone and copy dotfiles
setup_dotfiles() {
    local dotfiles_repo="https://github.com/anderson3x11/dot-files.git"
    local tmp_dir="/tmp/dot-files"

    echo "  -> Cloning dotfiles repo..."
    rm -rf "$tmp_dir"
    git clone "$dotfiles_repo" "$tmp_dir" &>> "$LOG_FILE"

    echo "  -> Copying .zshrc..."
    cp "$tmp_dir/.zshrc" "$HOME/.zshrc"

    echo "  -> Copying .bashrc..."
    cp "$tmp_dir/.bashrc" "$HOME/.bashrc"

    echo "  -> Copying starship.toml..."
    mkdir -p "$HOME/.config"
    cp "$tmp_dir/starship.toml" "$HOME/.config/starship.toml"

    echo "  -> Copying .config/..."
    cp -r "$tmp_dir/.config/." "$HOME/.config/"

    rm -rf "$tmp_dir"
    echo "  -> Dotfiles installed!"
}

# Function to set zsh as the default shell
setup_zsh() {
    local zsh_path
    zsh_path=$(which zsh)

    if [ "$SHELL" = "$zsh_path" ]; then
        echo "  -> zsh is already the default shell."
    else
        echo "  -> Changing default shell to zsh..."
        chsh -s "$zsh_path" "$USER"
        echo "  -> Default shell changed to zsh. Changes will apply on next login."
    fi
}