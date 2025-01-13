#!/usr/bin/zsh

# Core environment variables

# Set XDG directories
#--------------
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_BIN_HOME="${HOME}/.local/bin"
export XDG_LIB_HOME="${HOME}/.local/lib"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"
export XDG_CACHE_HOME="${HOME}/.cache"

# Set default applications
#--------------
export EDITOR="nvim"

# Variables with respect to XDG directories
#--------------
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
