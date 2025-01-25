#!/usr/bin/env bash

#+--- Linux-based system packages to install ---+#
# Installs system packages using apt-get

#+--- Variables ---+#
PROMPT_TIMEOUT=15
AUTO_RESPONSE=false

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
echo -e "Installing / updating Linux system packages"

# Prompt for password if not root
if [[ $EUID -ne 0 ]]; then
  echo -e "Elevated permissions required to install packages"\
    "Please enter your password when prompted\n"
  sudo -v
  if [[ $? -eq 1 ]]; then
    echo -e "ERROR: Password authentication failed. Exiting..."
    exit 1
  fi
fi

# Verify 'apt' package manager is installed
if ! package_exists apt; then
  echo "ERROR: apt package manager is not installed. Exiting..."
  exit 1
fi

# Enable upstream system repositories
echo -e "Do you want to enable upstream system repositories? (y/N)"
read -t $PROMPT_TIMEOUT -n 1 -r user_response
if [[ $user_response =~ ^[Yy]$ ]] || [[ $AUTO_RESPONSE = true ]]; then
  if ! package_exists add-apt-repository; then
    sudo apt install --reinstall software-properties-common
  fi

  # Enable Ubuntu repositories
  if [[ grep -q "ID=ubuntu" /etc/os-release ]]; then
    for repo in ${ubuntu_repos[@]}; do
      echo -e "Enabling ${repo} repository..."
      sudo add-apt-repository $repo
    done
  else
    # Otherwise, enable Debian repositories
    for repo in ${debian_repos[@]}; do
      echo -e "Enabling ${repo} repository..."
      sudo add-apt-repository $repo
    done
  fi
fi

# Prompt to update existing packages
echo -e "Do you want to update existing packages? (y/N)"
read -t $PROMPT_TIMEOUT -n 1 -r user_response
if [[ $user_response =~ ^[Yy]$ ]] || [[ $AUTO_RESPONSE = true ]]; then
  echo -e "Updating existing packages..."
  sudo apt update
fi

# Prompt to upgrade existing packages
echo -e "Do you want to upgrade existing packages? (y/N)"
read -t $PROMPT_TIMEOUT -n 1 -r user_response
if [[ $user_response =~ ^[Yy]$ ]] || [[ $AUTO_RESPONSE = true ]]; then
  echo -e "Upgrading existing packages..."
  sudo apt upgrade
fi

# Prompt to clear out unused packages
echo -e "Do you want to clear out unused packages? (y/N)"
read -t $PROMPT_TIMEOUT -n 1 -r user_response
if [[ $user_response =~ ^[Yy]$ ]] || [[ $AUTO_RESPONSE = true ]]; then
  echo -e "Fressing up disk space..."
  sudo apt autoclean
fi

# Prompt user to install packages
echo -e "Do you want to install system packages? (y/N)"
read -t $PROMPT_TIMEOUT -n 1 -r user_response
if [[ $user_response =~ ^[Yy]$ ]] || [[ $AUTO_RESPONSE = true ]]; then
  for pkg in ${linux_pkgs[@]}; do
    if ! package_exists $pkg; then
      echo -e "Installing ${pkg}..."
      sudo apt install $pkg --assume-yes
    else
      echo -e "${pkg} is already installed, skipping"
    fi
  done
fi

echo -e "Installation / update of Linux system packages complete"
