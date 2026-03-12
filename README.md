# Anderson's Respawn Tool 🛠️

⚡️ **respawn** is a personal Arch Linux setup automation tool built with Bash. It installs and configures packages and various utilities to create a fully functional development environment, right out of the box.

```
   ___                              
  / _ \___ ___ ___  ___ __    _____ 
 / , _/ -_|_-</ _ \/ _ `/ |/|/ / _ \        Arch Linux Setup Making Tool
/_/|_|\__/___/ .__/\_,_/|__,__/_//_/        by: anderson3x11
            /_/ 
```

## ✨ Features

- 🔧 Automatic package installation (pacman, AUR, npm)
- 🛠️ Automatic installation of yay AUR helper
- 💻 Sets up your terminal and dotfiles
- 🔒 Firewall (ufw) and bluetooth configured and enabled
- 🤖 Installs Claude CLI and Gemini CLI
- ♻️ Safe to re-run — already installed packages are skipped

## 📦 Prerequisites

- Arch Linux installation
- Internet connection
- sudo privileges
- Git installed

## 📥 Installation

1. Clone this repository:

```bash
git clone https://github.com/anderson3x11/respawn.git
```

2. Move into the directory

```bash
cd respawn/
```

3. Run the setup script:

```bash
bash ./setup.sh
```

4. Watch the script handle the rest of the process.

5. Once the script is done, reboot your system to see the changes !

## 🔒 Disclaimer
This is first and foremost a personal project, and may not correspond to your needs. Feel free to fork it and modify it to fit your setup. Be cautious when running scripts that modify system configurations.