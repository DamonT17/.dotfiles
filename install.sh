#!/usr/bin/env bash

# ------------------------------------------------------------------------ #
# .dotfiles - Dotfiles Setup and Update Script
# ------------------------------------------------------------------------ #
# This script clones and installs, or updates, personal dotfiles from git.
#
# OPTIONS:
#   --help: Show help information
#   --force: Bypass all prompts and auto-accept all actions
#   --no-clear: Do not clear the terminal before running the script
# ENVIRONMENT VARIABLES:
#   DOTFILES_DIR: Directory where the dotfiles will be installed
#   DOTFILES_REPO: Git repository URL for the dotfiles
# ------------------------------------------------------------------------ #

#+--- Variables ---+#
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/DamonT17/.dotfiles.git}"

ARGS=$*
CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SYSTEM_TYPE=$(uname -s) # Linux | MacOS (Darwin)
PROMPT_TIMEOUT=15       # User input prompt timeout (seconds)
AUTO_RESPONSE=false     # Auto-accept all user input prompts
START_TIME=$(date +%s)
SOURCE_DIR=$(dirname ${0})

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

# Verify package installation, outputs "ERROR" or "WARNING" depending on package status
package_verify() {
  if ! package_exists $1; then
    if $2; then
      echo -e "${RED}ERROR: ${PURPLE}$1${RESET} is not installed. Please install $1 before continuing. Exiting..."
      exit 1
    else
      echo -e "${YELLOW}WARNING: ${PURPLE}$1${RESET} is not installed"
    fi
  fi
}

# Installs / updates MacOS packages using Homebrew
install_packages_macos() {
  if ! package_exists brew; then
    echo -e "${PURPLE}Homebrew is not installed. Do you want to install Homebrew? (y/N)${RESET}"
    read -t $PROMPT_TIMEOUT -r user_response
    if [[ $user_response =~ ^[Yy]$ ]] || [[ $AUTO_RESPONSE = true ]]; then
      echo -e "🍺 ${PURPLE}Installing Homebrew...${RESET}"
      brew_url="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
      /bin/bash -c "$(curl -fsSL $brew_url)"
      export PATH="/opt/homebrew/bin:$PATH"
    else
      echo -e "${PURPLE}Skipping Homebrew installation and installation / update of system packages${RESET}"
      return
    fi
  fi

  # TODO: Continue here!
}

# Installs / updates a package using the appropriate package manager for the detected OS
install_packages() {
  echo -e "${PURPLE}Do you want to install / update system packages (y/N)${RESET}"
  read -t $PROMPT_TIMEOUT -r user_response
  if [[ ! $user_response =~ ^[Yy]$ ]] && [[ $AUTO_RESPONSE != true ]]; then
    echo -e "${YELLOW}Skipping package installation / update${RESET}"
    return
  fi

  if [[ $SYSTEM_TYPE = "Darwin" ]]; then # MacOS
    # MacOS
    install_packages_macos
  else 
    # Linux (Debian / Ubuntu)
    package_install_script="${HOME}/scripts/install/linux-packages.sh"
    chmod +x $package_install_script
    $package_install_script $ARGS
  fi
}

# Applies application preferences and configurations
apply_preferences() {
  # Select default shell
  if [[ $SHELL != *"zsh"* ]] && package_exists zsh; then
    echo -e "${PURPLE}Do you want to set Zsh as the default shell? (y/N)${RESET}"
    read -t $PROMPT_TIMEOUT -r user_response
    if [[ $user_response =~ ^[Yy]$ ]] || [[ $AUTO_RESPONSE = true ]]; then
      echo -e "${PURPLE}Setting Zsh as the default shell${RESET}"
      chsh -s $(which zsh) $USER
    fi
  fi

  # TODO: Add more preferences as needed
}

# Final touches, cleanup, and output summary
finalize_setup() {
  # Update source to Zsh entry point
  source "${HOME}/.zshenv"

  # Calculate completeion time
  total_time=$((`date +%s`-START_TIME))
  if [[ $total_time -gt 60 ]]; then
    total_time="$((total_time/60)) minutes"
  else
    total_time="${total_time} seconds"
  fi

  # Output completion message
  echo -e "${GREEN}Setup complete! ${PURPLE}Total time: ${total_time}${RESET}"

  # Refresh terminal
  exec $SHELL

  # Prompt to restart the system
  echo -e "${PURPLE}Press any key to exit.${RESET}\n"
  read -t $PROMPT_TIMEOUT -n 1 -s

  exit 0
}

# Cleanup tasks on exit of script
cleanup() {
  unset PROMPT_TIMEOUT
  unset AUTO_RESPONSE
}

# ------------------------------------------------------------------------ #
# Script Entry Point
# ------------------------------------------------------------------------ #

trap cleanup EXIT # Cleanup tasks on exit

# Show help information
if [[ $ARGS == *"--help"* ]]; then
  echo -e "Usage: install.sh [options]"
  echo -e  "Options:\n"\
    "  --help\tShow help information\n"
    "  --force\tBypass prompts and auto-accept actions\n"
    "  --no-clear\tDo not clear the terminal before script entry\n"
  exit 0
fi

# Clear terminal
if [[ ! $ARGS == *"--no-clear"* ]] && [[ ! $ARGS == *"--help"* ]]; then
  clear
fi

# Steps to completion do not require user input
if [[ $ARGS == *"--force"* ]]; then
  PROMPT_TIMEOUT=1
  AUTO_RESPONSE=true
fi

# Entry message
echo -e "${PURPLE}~/.dotfiles --> Installation / Update Script${RESET}"
echo -e "${PURPLE}Source: ${DOTFILES_REPO}${RESET}"
echo -e "${PURPLE}Destination: ${DOTFILES_DIR}${RESET}"

# Install core packages using the appropriate package manager for the detected OS
if ! package_exists git; then
  echo -e "${YELLOW}Core packages not detected, running prerequisites script...${RESET}"
  bash <(curl -s -L 'https://raw.githubusercontent.com/DamonT17/.dotfiles/refs/heads/main/scripts/install/prerequisites.sh')
fi

# Clone or update the dotfiles repository
if [[ ! -d "${DOTFILES_DIR}" ]]; then
  echo -e "${PURPLE}Cloning ${DOTFILES_REPO} to ${DOTFILES_DIR}${RESET}"
  mkdir -p "${DOTFILES_DIR}" && git clone --recursive "${DOTFILES_REPO}" "${DOTFILES_DIR}"
else
  echo -e "${PURPLE}Updating ${DOTFILES_DIR} from ${DOTFILES_REPO}${RESET}"
  cd "${DOTFILES_DIR}" && git pull origin main
  echo -e "${PURPLE}Updating submodules${RESET}"
  git submodule update --recursive --remote --init
fi

# Exit if clone or update failed
if [[ ! test "$?" -eq 0 ]]; then
  echo -e "${RED}ERROR: ${PURPLE}Failed to clone or update the dotfiles repository. Exiting...${RESET}"
  exit 1
fi

# Verify core packages are installed
package_verify "git" true
package_verify "zsh" false
package_verify "vim" false
package_verify "nvim" false
package_verify "tmux" false

# Configure XDG environment variables
if [[ -z ${XDG_CONFIG_HOME+x} ]]; then
  echo -e "${PURPLE}Setting ${BLUE}XDG_CONFIG_HOME ${PURPLE}to ${BLUE}${HOME}/.config${RESET}"
  export XDG_CONFIG_HOME="${HOME}/.config"
fi
if [[ -z ${XDG_BIN_HOME+x} ]]; then
  echo -e "${PURPLE}Setting ${BLUE}XDG_BIN_HOME ${PURPLE}to ${BLUE}${HOME}/.local/bin${RESET}"
  export XDG_BIN_HOME="${HOME}/.local/bin"
fi
if [[ -z ${XDG_LIB_HOME+x} ]]; then
  echo -e "${PURPLE}Setting ${BLUE}XDG_LIB_HOME ${PURPLE}to ${BLUE}${HOME}/.local/lib${RESET}"
  export XDG_LIB_HOME="${HOME}/.local/lib"
fi
if [[ -z ${XDG_DATA_HOME+x} ]]; then
  echo -e "${PURPLE}Setting ${BLUE}XDG_DATA_HOME ${PURPLE}to ${BLUE}${HOME}/.local/share${RESET}"
  export XDG_DATA_HOME="${HOME}/.local/share"
fi
if [[ -z ${XDG_STATE_HOME+x} ]]; then
  echo -e "${PURPLE}Setting ${BLUE}XDG_STATE_HOME ${PURPLE}to ${BLUE}${HOME}/.local/state${RESET}"
  export XDG_STATE_HOME="${HOME}/.local/state"
fi
if [[ -z ${XDG_CACHE_HOME+x} ]]; then
  echo -e "${PURPLE}Setting ${BLUE}XDG_CACHE_HOME ${PURPLE}to ${BLUE}${HOME}/.cache${RESET}"
  export XDG_CACHE_HOME="${HOME}/.cache"
fi

install_packages  # Prompt user to install / update system packages
apply_preferences # Apply application preferences and configurations
finalize_setup    # Finalize setup and output summary
