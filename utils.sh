#!/bin/bash

# ── Spinner ───────────────────────────────────────────────────────────────────

_spinner_pid=0
_spinner_chars='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

_spin_loop() {
    local msg="$1"
    local i=0
    while true; do
        printf "\r  \033[33m${_spinner_chars:$((i % 10)):1}\033[0m %s" "$msg"
        i=$(( i + 1 ))
        sleep 0.08
    done
}

start_spinner() {
    _spin_loop "$1" &
    _spinner_pid=$!
}

stop_spinner() {
    if [ "$_spinner_pid" -ne 0 ]; then
        kill "$_spinner_pid" 2>/dev/null
        wait "$_spinner_pid" 2>/dev/null || true
        _spinner_pid=0
    fi
    printf "\r\033[K"
}

ok()   { stop_spinner; printf "  \033[32m✓\033[0m %s\n" "$1"; }
skip() { stop_spinner; printf "  \033[34m–\033[0m %s\n" "$1"; }
fail() { stop_spinner; printf "  \033[31m✗\033[0m %s\n" "$1"; }

# ── Package installers ────────────────────────────────────────────────────────

install_packages() {
    for pkg in "$@"; do
        if pacman -Q "$pkg" &>/dev/null; then
            skip "Already installed: $pkg"
        else
            start_spinner "Installing $pkg"
            if sudo pacman -S --noconfirm --needed -q "$pkg" &>> "$LOG_FILE"; then
                ok "Installed $pkg"
            else
                fail "Failed to install $pkg"
            fi
        fi
    done
}

install_aur_packages() {
    for pkg in "$@"; do
        start_spinner "Installing AUR: $pkg"
        if yay -S --noconfirm --needed -q "$pkg" &>> "$LOG_FILE"; then
            ok "Installed $pkg"
        else
            fail "Failed to install $pkg"
        fi
    done
}

install_npm_packages() {
    for pkg in "$@"; do
        if npm list -g --depth=0 "$pkg" &>/dev/null; then
            skip "Already installed: $pkg"
        else
            start_spinner "Installing npm: $pkg"
            if sudo npm install -g "$pkg" &>> "$LOG_FILE"; then
                ok "Installed $pkg"
            else
                fail "Failed to install $pkg"
            fi
        fi
    done
}

# ── Services ──────────────────────────────────────────────────────────────────

enable_services() {
    for svc in "${SERVICES[@]}"; do
        start_spinner "Enabling $svc"
        if sudo systemctl enable --now "$svc" &>> "$LOG_FILE"; then
            ok "Enabled $svc"
        else
            fail "Failed to enable $svc"
        fi
    done
}

# ── Dotfiles ──────────────────────────────────────────────────────────────────

setup_dotfiles() {
    local dotfiles_repo="https://github.com/anderson3x11/dot-files.git"
    local tmp_dir="/tmp/dot-files"

    rm -rf "$tmp_dir"
    start_spinner "Cloning dotfiles"
    if ! git clone "$dotfiles_repo" "$tmp_dir" &>> "$LOG_FILE"; then
        fail "Failed to clone dotfiles"
        return 1
    fi
    ok "Cloned dotfiles"

    for f in .zshrc .bashrc; do
        start_spinner "Copying $f"
        cp "$tmp_dir/$f" "$HOME/$f" && ok "Copied $f" || fail "Failed to copy $f"
    done

    start_spinner "Copying starship.toml"
    mkdir -p "$HOME/.config"
    cp "$tmp_dir/starship.toml" "$HOME/.config/starship.toml" \
        && ok "Copied starship.toml" || fail "Failed to copy starship.toml"

    start_spinner "Copying .config/"
    cp -r "$tmp_dir/.config/." "$HOME/.config/" \
        && ok "Copied .config/" || fail "Failed to copy .config/"

    rm -rf "$tmp_dir"
}

# ── Shell ─────────────────────────────────────────────────────────────────────

setup_zsh() {
    local zsh_path
    zsh_path=$(which zsh)

    if [ "$SHELL" = "$zsh_path" ]; then
        skip "zsh is already the default shell"
    else
        start_spinner "Changing default shell to zsh"
        if sudo chsh -s "$zsh_path" "$USER"; then
            ok "Default shell changed to zsh"
        else
            fail "Failed to change shell"
        fi
    fi
}
