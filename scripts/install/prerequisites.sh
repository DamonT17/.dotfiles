#!/usr/bin/env bash

#+--- Core prerequisite packages ---+
# Installs the core prerequisite packages when setting up a new system.

# List of core packages
core_packages=(
  'git' # Version control system
  'vim' # Text editor
  'zsh' # Shell
)

# Prints help information on script start
print_help() {
  echo -e "Usage: prerequisites.sh [options]"
  echo -e "Options:\n"\
    "  --help\tShow help information\n"\
    "  --force\tBypass prompts and auto-accept actions\n"
  echo -e "Installs core prerequisite packages when setting up a new system and its dotfiles."
  echo -e "This script will detect the system type and install the core packages using the appropriate package manager."
  echo -e "Elevated permissions may be needed!"
}

# Check if a package already exists on the system
package_exists() {
  hash "$1" 2> /dev/null
}

# Installation on Debian-based systems
install_debian() {
  echo -e "Installing ${1} via apt-get"
  sudo apt install $1
}

# Installation on MacOS
install_macos() {
  echo -e "Installing ${1} via Homebrew"
  brew install $1
}

setup_homebrew() {
  echo -e "Setting up Homebrew\n"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  export PATH="/opt/homebrew/bin:$PATH"
}

# Installs core packages using the appropriate package manager for the detected OS
install_package() {
  pkg=$1
  if [ -f "/etc/debian_version" ] && package_exists apt; then
    install_debian $pkg # Debian via apt
  elif [ "$(uname -s)" = "Darwin" ]; then
    if ! package_exists brew; then setup_homebrew; fi
    install_macos $pkg # MacOS via Homebrew
  else
    echo -e "Skipping ${pkg}, system type not detected or package manager not found"
  fi
}

# ------------------------------------------------------------------------ #
# Script Entry Point
# ------------------------------------------------------------------------ #

# Show help information
if [[ $* == *"--help"* ]]; then
  print_help
  exit 0
fi

# Entry message
echo -e "~/.dotfiles --> Core Prerequisite Packages Installation"
echo -e "This script will install the following core packages:\n"\
  "  - git\n"\
  "  - vim\n"\
  "  - zsh\n"

# Prompt confirmation before continuing
if [[ ! $* == *"--force"* ]]; then
  echo -e "Do you wish to install the prerequisite core packages? (y/N)"
  read -t 15 -r
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "Installation aborted, exiting..."
    exit 0
  fi
fi

# Installs core packages if not present on the system
for pkg in ${core_packages[@]}; do
  if ! package_exists $pkg
    install_package $pkg
  else
    echo -e "${pkg} is already installed, skipping"
  fi
done

# Script finish, exit with success
echo -e "\nCore packages installed successfully, exiting..."
exit 0
