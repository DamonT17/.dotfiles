#!/usr/bin/env bash

#+--- Linux-based system packages to install ---+#
# Installs system packages using apt-get

#+--- Variables ---+#
PROMPT_TIMEOUT=15
AUTO_RESPONSE=false

# Colors
RED='\x1b[31m'
GREEN='\x1b[32m'
YELLOW='\x1b[33m'
BLUE='\x1b[34m'
PURPLE='\x1b[35m'
BOLD='\x1b[1m'
FAINT='\x1b[2m'
RESET='\x1b[0m'

linux_pkgs=(
  # Essentials
  'git'    # Version control
  'neovim' # Text editor (TODO: Consider pulling latest version from source?)
  'tmux'   # Terminal multiplexer
  'curl'   # Transfer data
  'wget'   # Download files
  'zsh'    # Shell

  # CLI tools
  'bat'     # Output highlighting (cat clone)
  'exa'     # List files (ls clone)
  'fd'      # Find files (find clone)
  'fzf'     # Fuzzy finder (TODO: Pull from source)
  'ripgrep' # Search tool (grep clone)
  'zoxide'  # Directory navigation (TODO: Pull from source)

  # Languages, compilers, etc.
  'cmake'
  'cpp'
  'gcc'
  'make'
  'nodejs'
  'npm'
  'python3'

  # Security
  'gpg'      # Encryption
  'openssl'  # SSL/TLS toolkit
  'pass'     # Password manager

  # Utilities
)

ubuntu_repos=(
  'main'
  'universe'
  'restricted'
  'multiverse'
)

debian_repos=(
  'main'
  'contrib'
)

#+--- Helper Functions ---+#
# Check if a package already exists on the system
package_exists() {
  hash "$1" 2> /dev/null
}

# ------------------------------------------------------------------------ #
# Script Entry Point
# ------------------------------------------------------------------------ #

# Steps to completion do not require user input
if [[ $* == *"--force"* ]]; then
  PROMPT_TIMEOUT=1
  AUTO_RESPONSE=true
fi

# Entry message
echo -e "${PURPLE}Installing / updating Linux system packages...${RESET}"

# Prompt for password if not root
if [[ $EUID -ne 0 ]]; then
  echo -e "${YELLOW}Elevated permissions required to install packages!${RESET}"
  sudo -v
  if [[ $? -eq 1 ]]; then
    echo -e "${RED}ERROR: ${PURPLE}Password authentication failed. Exiting...${RESET}"
    exit 1
  fi
fi

# Verify 'apt' package manager is installed
if ! package_exists apt; then
  echo "${RED}ERROR: ${BLUE}apt ${PURPLE}package manager is not installed. Exiting...${RESET}"
  exit 1
fi

# Enable upstream system repositories
echo -e "${PURPLE}Do you want to enable upstream system repositories? (y/N)${RESET}"
read -t $PROMPT_TIMEOUT -r user_response
if [[ $user_response =~ ^[Yy]$ ]] || [[ $AUTO_RESPONSE = true ]]; then
  if ! package_exists add-apt-repository; then
    sudo apt install --reinstall software-properties-common
  fi

  # Enable Ubuntu repositories
  if grep -q "ID=ubuntu" /etc/os-release; then
    for repo in "${ubuntu_repos[@]}"; do
      echo -e "${PURPLE}Enabling ${BLUE}${repo} ${PURPLE}repository...${RESET}"
      sudo add-apt-repository "${repo}"
    done
  else
    # Otherwise, enable Debian repositories
    for repo in "${debian_repos[@]}"; do
      echo -e "${PURPLE}Enabling ${BLUE}${repo} ${PURPLE}repository...${RESET}"
      sudo add-apt-repository "${repo}"
    done
  fi
fi

# Prompt to update existing packages
echo -e "${PURPLE}Do you want to update existing packages? (y/N)${RESET}"
read -t $PROMPT_TIMEOUT -r user_response
if [[ $user_response =~ ^[Yy]$ ]] || [[ $AUTO_RESPONSE = true ]]; then
  echo -e "${PURPLE}Updating existing packages...${RESET}"
  sudo apt update
fi

# Prompt to upgrade existing packages
echo -e "${PURPLE}Do you want to upgrade existing packages? (y/N)${RESET}"
read -t $PROMPT_TIMEOUT -r user_response
if [[ $user_response =~ ^[Yy]$ ]] || [[ $AUTO_RESPONSE = true ]]; then
  echo -e "${PURPLE}Upgrading existing packages...${RESET}"
  sudo apt upgrade
fi

# Prompt to clear out unused packages
echo -e "${PURPLE}Do you want to clear out unused packages? (y/N)${RESET}"
read -t $PROMPT_TIMEOUT -r user_response
if [[ $user_response =~ ^[Yy]$ ]] || [[ $AUTO_RESPONSE = true ]]; then
  echo -e "${PURPLE}Freeing up disk space...${RESET}"
  sudo apt autoclean
fi

# Prompt user to install packages
echo -e "${PURPLE}Do you want to install system packages? (y/N)${RESET}"
read -t $PROMPT_TIMEOUT -r user_response
if [[ $user_response =~ ^[Yy]$ ]] || [[ $AUTO_RESPONSE = true ]]; then
  for pkg in ${linux_pkgs[@]}; do
    if ! package_exists $pkg; then
      echo -e "${PURPLE}Installing ${BLUE}${pkg}...${RESET}"
      sudo apt install $pkg --assume-yes
    else
      echo -e "${BLUE}${pkg} ${PURPLE}is already installed, skipping${RESET}"
    fi
  done
fi

echo -e "${GREEN}Installation / update of Linux system packages complete!${RESET}"
