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
  echo -e "Usage: prerequisites.sh [options]\n"\
    "Options:\n"\
    "  --help\t\tShow help information\n"\
    "  --force\t\tBypass prompts and auto-accept actions\n\n"
    "Installs core prerequisite packages when setting up a new system and its dotfiles.\n"\
    "This script will detect the system type and install the core packages using the appropriate package manager.\n"\
    "Elevated permissions may be needed!\n"
}

# Check if a package already exists on the system
package_exists() {
  hash "$1" 2> /dev/null
}

# Installation on Debian-based systems
install_debian() {
  echo -e "Installing ${1} via apt-get\n"
  sudo apt install $1
}

# Installation on MacOS
install_macos() {
  echo -e "Installing ${1} via Homebrew\n"
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
    echo -e "Skipping ${pkg}, system type not detected or package manager not found\n"
  fi
}

# Show help information
if [[ $* == *"--help"* ]]; then
  print_help
  exit 0
fi

# Prompt confirmation before continuing
if [[ ! $* == *"--force"* ]]; then
  echo -e "Do you wish to continue installing core packages? (y/N)"
  read -t 15 -n 1 -r
  echo
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
    echo -e "${pkg} is already installed, skipping\n"
  fi
done

# Script finish, exit with success
echo -e "\nCore packages installed successfully, exiting..."
exit 0
