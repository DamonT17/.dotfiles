#!/usr/bin/env bash

#+--- Core prerequisite packages ---+
# Installs the core prerequisite packages when setting up a new system.

# List of core packages
core_packages=(
  'git' # Version control system
  'vim' # Text editor
  'zsh' # Shell
)

# Colors
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
LIGHT='\x1b[2m'
RESET='\033[0m'

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
  echo -e "${PURPLE}Installing ${1} via apt-get${RESET}"
  sudo apt install $1
}

# Installation on MacOS
install_macos() {
  echo -e "${PURPLE}Installing ${1} via Homebrew${RESET}"
  brew install $1
}

setup_homebrew() {
  echo -e "${PURPLE}Setting up Homebrew${RESET}"
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
    echo -e "${YELLOW}Skipping ${pkg}, system type not detected or package manager not found${RESET}"
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
echo -e "${PURPLE}~/.dotfiles --> Core Prerequisite Packages Installation${RESET}"
echo -e "${LIGHT}This script will install the following core packages:\n"\
  "  - git\n"\
  "  - vim\n"\
  "  - zsh\n${RESET}"

# Prompt confirmation before continuing
if [[ ! $* == *"--force"* ]]; then
  echo -e "${PURPLE}Do you wish to install the prerequisite core packages? (y/N)${RESET}"
  read -t 15 -r
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installation aborted, exiting...${RESET}"
    exit 0
  fi
fi

# Installs core packages if not present on the system
for pkg in ${core_packages[@]}; do
  if ! package_exists $pkg; then
    install_package $pkg
  else
    echo -e "${YELLOW}${pkg} is already installed, skipping${RESET}"
  fi
done

# Script finish, exit with success
echo -e "\n${PURPLE}Core packages installed successfully, exiting...${RESET}"
exit 0
