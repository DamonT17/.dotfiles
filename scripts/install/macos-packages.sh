#!/usr/bin/env bash

#+--- MacOS-based system packages to install external to Homebrew ---+#
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
echo -e "${PURPLE}Installing / updating MacOS system packages from source...${RESET}"

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
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-macos-arm64.tar.gz
  sudo rm -rf ~/.local/bin/nvim-macos-arm64
  sudo xattr -c ~/.local/bin/nvim-macos-arm64.tar.gz
  sudo tar -C ~/.local/bin -xzvf nvim-macos-arm64.tar.gz

  # Cleanup
  rm nvim-macos-arm64.tar.gz

  # Symlink 'nvim-macos-arm64/bin/nvim' -> 'nvim'
  echo -e "${PURPLE}Creating symlink for ${BLUE}nvim${PURPLE}...${RESET}"
  sudo ln -s ./nvim-macos-arm64/bin/nvim ./nvim

  # Switch back to the user's home directory
  cd ~
else
  echo -e "${BLUE}neovim ${PURPLE}is already installed, skipping${RESET}"
fi

echo -e "${GREEN}Installation / update of MacOS system packages complete!${RESET}"
