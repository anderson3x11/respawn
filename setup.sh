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

# ── Sudo keepalive ────────────────────────────────────────────────────────────

echo ">> Sudo credentials required for setup."
sudo -v
# Keep sudo alive in the background for the entire script
(while true; do sudo -n true; sleep 50; done) &
SUDO_PID=$!
trap 'kill $SUDO_PID 2>/dev/null' EXIT

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
    sudo pacman -S --needed git base-devel --noconfirm -q &>> "$LOG_FILE"
    rm -rf /tmp/yay-build
    start_spinner "Building yay"
    if git clone https://aur.archlinux.org/yay.git /tmp/yay-build &>> "$LOG_FILE" &&
       cd /tmp/yay-build &&
       makepkg -si --noconfirm &>> "$LOG_FILE"; then
        ok "Installed yay"
    else
        fail "Failed to install yay"
    fi
    cd "$SCRIPT_DIR"
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


# ── Services ──────────────────────────────────────────────────────────────────

echo ">> Enabling services..."
for svc in "${SERVICES[@]}"; do
    start_spinner "Enabling $svc"
    if sudo systemctl enable "$svc" &>> "$LOG_FILE"; then
        ok "Enabled $svc"
    else
        fail "Failed to enable $svc"
    fi
done
echo

echo ">> Enabling ufw firewall..."
start_spinner "Rate-limiting SSH"
if sudo ufw limit ssh &>> "$LOG_FILE"; then
    ok "SSH rate-limited"
else
    fail "Failed to limit SSH"
fi

start_spinner "Enabling ufw"
if sudo ufw enable &>> "$LOG_FILE"; then
    ok "ufw enabled"
else
    fail "Failed to enable ufw"
fi

start_spinner "Enabling ufw.service"
if sudo systemctl enable ufw &>> "$LOG_FILE"; then
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
