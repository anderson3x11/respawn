#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# ── Logo ──────────────────────────────────────────────────────────────────────

clear
cat << "EOF"
   ___
  / _ \___ ___ ___  ___ __    _____
 / , _/ -_|_-</ _ \/ _ `/ |/|/ / _ \    Arch Linux Setup Making Tool
/_/|_|\__/___/ .__/\_,_/|__,__/_//_/    by: anderson3x11
            /_/

EOF
echo ">> Booting up the respawn protocol..."
echo

# ── Log ───────────────────────────────────────────────────────────────────────

LOG_FILE="$HOME/respawn.log"
echo "=== Respawn run: $(date) ===" >> "$LOG_FILE"
echo ">> Logging to $LOG_FILE"
echo

# ── Load files ────────────────────────────────────────────────────────────────

source "$SCRIPT_DIR/utils.sh"

if [ ! -f "$SCRIPT_DIR/packages.conf" ]; then
    echo "Error: packages.conf not found!"
    exit 1
fi
source "$SCRIPT_DIR/packages.conf"

echo ">> Starting system setup..."
echo

# ── System update ─────────────────────────────────────────────────────────────

echo ">> Updating system..."
start_spinner "Running pacman -Syu"
if sudo pacman -Syu --noconfirm -q &>> "$LOG_FILE"; then
    ok "System updated"
else
    fail "System update failed"
fi
echo

# ── yay ───────────────────────────────────────────────────────────────────────

if ! command -v yay &>/dev/null; then
    echo ">> Installing yay AUR helper..."
    start_spinner "Building yay"
    if (
        sudo pacman -S --needed git base-devel --noconfirm -q &>> "$LOG_FILE" &&
        git clone https://aur.archlinux.org/yay.git /tmp/yay-build &>> "$LOG_FILE" &&
        cd /tmp/yay-build &&
        sudo -v &&
        makepkg -si --noconfirm &>> "$LOG_FILE"
    ); then
        ok "Installed yay"
    else
        fail "Failed to install yay"
    fi
    rm -rf /tmp/yay-build
else
    skip "yay already installed"
fi
echo

# ── Packages ──────────────────────────────────────────────────────────────────

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

echo ">> Installing npm packages..."
install_npm_packages "${NPM_PACKAGES[@]}"
echo

echo ">> Installing Claude CLI..."
if command -v claude &>/dev/null; then
    skip "Claude CLI already installed"
else
    start_spinner "Installing Claude CLI"
    if curl -fsSL https://claude.ai/install.sh | bash &>> "$LOG_FILE"; then
        ok "Installed Claude CLI"
    else
        fail "Failed to install Claude CLI"
    fi
fi
echo

# ── Services ──────────────────────────────────────────────────────────────────

echo ">> Enabling services..."
enable_services
echo

echo ">> Configuring ufw firewall..."
start_spinner "Setting default rules"
if sudo ufw default deny incoming &>> "$LOG_FILE" && sudo ufw default allow outgoing &>> "$LOG_FILE"; then
    ok "Default rules set (deny incoming / allow outgoing)"
else
    fail "Failed to set default rules"
fi

start_spinner "Allowing SSH"
if sudo ufw allow ssh &>> "$LOG_FILE"; then
    ok "SSH allowed"
else
    fail "Failed to allow SSH"
fi

start_spinner "Enabling ufw"
if sudo ufw --force enable &>> "$LOG_FILE"; then
    ok "ufw enabled"
else
    fail "Failed to enable ufw"
fi

start_spinner "Enabling ufw.service"
if sudo systemctl enable --now ufw.service &>> "$LOG_FILE"; then
    ok "Enabled ufw.service"
else
    fail "Failed to enable ufw.service"
fi
echo

# ── Dotfiles & shell ──────────────────────────────────────────────────────────

echo ">> Setting up dotfiles..."
setup_dotfiles
echo

echo ">> Setting up zsh..."
setup_zsh
echo

# ── Done ──────────────────────────────────────────────────────────────────────

echo ">> Respawn complete! Reboot your system to apply all changes."
echo "   Full log: $LOG_FILE"
