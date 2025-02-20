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
  'gh'     # Github CLI
  'tmux'   # Terminal multiplexer
  'curl'   # Transfer data
  'wget'   # Download files
  'zsh'    # Shell

  # CLI tools
  'bat'     # Output highlighting (cat clone)
  'exa'     # List files (ls clone)
  'fd-find' # Find files (find clone)
  'ripgrep' # Search tool (grep clone)

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
  for pkg in "${linux_pkgs[@]}"; do
    if ! package_exists $pkg; then
      echo -e "${PURPLE}Installing ${BLUE}${pkg}...${RESET}"
      sudo apt install "${pkg}" --assume-yes
    else
      echo -e "${BLUE}${pkg} ${PURPLE}is already installed, skipping${RESET}"
    fi
  done

  # Create user's local bin directory
  if [[ ! -d ~/.local/bin ]]; then
    echo -e "${PURPLE}Do you want to create a local bin directory at ${BLUE}~/.local/bin${PURPLE}? (y/N)${RESET}"
    read -t $PROMPT_TIMEOUT -r user_response
    if [[ $user_response =~ ^[Yy]$ ]] || [[ $AUTO_RESPONSE = true ]]; then
      mkdir -p ~/.local/bin

      # Switch to user's local bin directory
      cd ~/.local/bin

      # Symlink 'batcat' -> 'bat'
      echo -e "${PURPLE}Creating symlink for ${BLUE}bat${PURPLE}...${RESET}"
      sudo ln -s $(which batcat) ./bat

      # Symlink 'fdfind' -> 'fd'
      echo -e "${PURPLE}Creating symlink for ${BLUE}fd${PURPLE}...${RESET}"
      sudo ln -s $(which fdfind) ./fd

      # Switch back to the user's home directory
      cd ~
    else
      echo -e "${YELLOW}WARNING: ${PURPLE}Skipping creation of local bin directory...${RESET}"
      echo -e "${YELLOW}WARNING: ${PURPLE}Useful package symlinks will not be created!${RESET}"
    fi
  fi

  #+--- Install remaining packages from source (e.g., starship) ---+#
  # fzf (fuzzy finder)
  if ! package_exists fzf; then
    echo -e "${PURPLE}Installing ${BLUE}fzf ${PURPLE}...${RESET}"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.config/fzf && ~/.config/fzf/install --bin
  else
    echo -e "${BLUE}fzf ${PURPLE}is already installed, skipping${RESET}"
  fi

  # zoxide (directory navigation)
  if ! package_exists zoxide; then
    echo -e "${PURPLE}Installing ${BLUE}zoxide ${PURPLE}...${RESET}"
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  else
    echo -e "${BLUE}zoxide ${PURPLE}is already installed, skipping${RESET}"
  fi

  # neovim (text editor)
  if ! package_exists nvim; then
    echo -e "${PURPLE}Installing ${BLUE}neovim ${PURPLE}...${RESET}"
    cd ~/.local/bin
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo rm -rf ~/.local/bin/nvim-linux-x86_64
    sudo tar -C ~/.local/bin -xzf nvim-linux-x86_64.tar.gz

    # Cleanup
    rm nvim-linux-x86_64.tar.gz

    # Symlink 'nvim-linux86_64/bin/nvim' -> 'nvim'
    echo -e "${PURPLE}Creating symlink for ${BLUE}nvim${PURPLE}...${RESET}"
    sudo ln -s ./nvim-linux-x86_64/bin/nvim ./nvim

    # Switch back to the user's home directory
    cd ~
  else
    echo -e "${BLUE}neovim ${PURPLE}is already installed, skipping${RESET}"
  fi

  # eza (ls, exa clone)
  if ! package_exists eza; then
    echo -e "${PURPLE}Installing ${BLUE}eza ${PURPLE}...${RESET}"
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza
  else
    echo -e "${BLUE}eza ${PURPLE}is already installed, skipping${RESET}"
  fi

  # starship (prompt)
  if ! package_exists starship; then
    echo -e "${PURPLE}Installing ${BLUE}starship ${PURPLE}...${RESET}"
    curl -sS https://starship.rs/install.sh | sh
  else
    echo -e "${BLUE}starship ${PURPLE}is already installed, skipping${RESET}"
  fi
fi

echo -e "${GREEN}Installation / update of Linux system packages complete!${RESET}"
