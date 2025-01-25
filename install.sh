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

#+--- Helper Functions ---+#
# Check if a package already exists on the system
package_exists() {
  hash "$1" 2> /dev/null
}

# Verify package installation, outputs "ERROR" or "WARNING" depending on package status
package_verify() {
  if ! package_exists $1; then
    if $2; then
      echo -e "ERROR: $1 is not installed. Please install $1 before continuing. Exiting..."
      exit 1
    else
      echo -e " WARNING: $1 is not installed"
    fi
  fi
}

# Installs / updates MacOS packages using Homebrew
install_packages_macos() {
  if ! package_exists brew; then
    echo -e "Homebrew is not installed. Do you want to install Homebrew? (y/N)"
    read -t $PROMPT_TIMEOUT -n 1 -r user_response
    if [[ $user_response =~ ^[Yy]$ ]] || [[ $AUTO_RESPONSE = true ]]; then
      echo -en "🍺 Installing Homebrew...\n"
      brew_url="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
      /bin/bash -c "$(curl -fsSL $brew_url)"
      export PATH="/opt/homebrew/bin:$PATH"
    else
      echo -e "\nSkipping Homebrew installation and installation / update of system packages"
      return
    fi
  fi

  # TODO: Continue here!
}

# Installs / updates a package using the appropriate package manager for the detected OS
install_packages() {
  echo -e "Do you want to install / update system packages (y/N)"
  read -t $PROMPT_TIMEOUT -n 1 -r user_response
  if [[ ! $user_response =~ ^[Yy]$ ]] && [[ $AUTO_RESPONSE != true ]]; then
    echo -e "\nSkipping package installation / update"
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
    echo -e "Do you want to set Zsh as the default shell? (y/N)"
    read -t $PROMPT_TIMEOUT -n 1 -r user_response
    if [[ $user_response =~ ^[Yy]$ ]] || [[ $AUTO_RESPONSE = true ]]; then
      echo -e "Setting Zsh as the default shell"
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
  echo -e "Setup complete! Total time: ${total_time}"

  # Refresh terminal
  exec $SHELL

  # Prompt to restart the system
  echo -e "Press any key to exit.\n"
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
  echo -e "Usage: install.sh [OPTIONS]\n"\
    "Options:\n"\
    "  --help\t\tShow help information\n"
    "  --force\t\tBypass prompts and auto-accept actions\n"
    "  --no-clear\t\tDo not clear the terminal before script entry\n"
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
echo -e "~/.dotfiles installation / update script"\
  "Source: ${DOTFILES_REPO}"\
  "Destination: ${DOTFILES_DIR}\n"

# Install core packages using the appropriate package manager for the detected OS
if ! package_exists git; then
  echo -e "Core packages not detected, running prerequisites script...\n"
  bash <(curl -s -L 'https://raw.githubusercontent.com/DamonT17/.dotfiles/refs/heads/main/scripts/install/prerequisites.sh')
fi

# Clone or update the dotfiles repository
if [[ ! -d "${DOTFILES_DIR}" ]]; then
  echo -e "Cloning ${DOTFILES_REPO} to ${DOTFILES_DIR}\n"
  mkdir -p "${DOTFILES_DIR}" && git clone --recursive "${DOTFILES_REPO}" "${DOTFILES_DIR}"
else
  echo -e "Updating ${DOTFILES_DIR} from ${DOTFILES_REPO}\n"
  cd "${DOTFILES_DIR}" && git pull origin main
  echo -e "Updating submodules"
  git submodule update --recursive --remote --init
fi

# Exit if clone or update failed
if [[ ! test "$?" -eq 0 ]]; then
  echo -e "ERROR: Failed to clone or update the dotfiles repository. Exiting..."
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
  echo -e "Setting XDG_CONFIG_HOME to ${HOME}/.config"
  export XDG_CONFIG_HOME="${HOME}/.config"
fi
if [[ -z ${XDG_BIN_HOME+x} ]]; then
  echo -e "Setting XDG_BIN_HOME to ${HOME}/.local/bin"
  export XDG_BIN_HOME="${HOME}/.local/bin"
fi
if [[ -z ${XDG_LIB_HOME+x} ]]; then
  echo -e "Setting XDG_LIB_HOME to ${HOME}/.local/lib"
  export XDG_LIB_HOME="${HOME}/.local/lib"
fi
if [[ -z ${XDG_DATA_HOME+x} ]]; then
  echo -e "Setting XDG_DATA_HOME to ${HOME}/.local/share"
  export XDG_DATA_HOME="${HOME}/.local/share"
fi
if [[ -z ${XDG_STATE_HOME+x} ]]; then
  echo -e "Setting XDG_STATE_HOME to ${HOME}/.local/state"
  export XDG_STATE_HOME="${HOME}/.local/state"
fi
if [[ -z ${XDG_CACHE_HOME+x} ]]; then
  echo -e "Setting XDG_CACHE_HOME to ${HOME}/.cache"
  export XDG_CACHE_HOME="${HOME}/.cache"
fi

install_packages  # Prompt user to install / update system packages
apply_preferences # Apply application preferences and configurations
finalize_setup    # Finalize setup and output summary
