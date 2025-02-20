#!/usr/bin/zsh

# Zsh aliases for common commands and frequently used tools (e.g., git, docker, etc.).

package_exists() {
  hash "$1" 2> /dev/null
}

# Directory
#--------------
if package_exists eza; then
  alias l="eza --icons --group-directories-first"
  alias la="eza -a --icons --group-directories-first"   # List all files
  alias ll="eza -lah --icons --group-directories-first" # List all files with details
  alias lm="eza -lah --icons -s=modified --reverse"     # Sort by recently modified
  alias lb="eza -lah --icons -s=size --reverse"         # Sort by size
  alias tree="f() { eza -a --tree -L=${1:-2} --icons --group-directories-first }; f"
else
  alias la="ls -A"
  alias ll="ls -lAFh"  # List all files with details
  alias lm="ls -lAFth" # Sort by recently modified
  alias lb="ls -lAFSh" # Sort by size
fi

# Terminal
#--------------
alias c="clear"
alias reload="source ${ZDOTDIR}/.zshrc"

# Tmux
#--------------
alias tmux="tmux -u"
alias t="tmux"
alias ta="tmux attach-session -t"
alias tn="tmux new-session -s"
alias tl="tmux list-sessions"
alias tk="tmux kill-session -t"

# System Monitoring
#--------------
alias cpuinfo="lscpu"                                       # Show CPU info
alias cpuhog="ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head" # Processes consuming most CPU
alias meminfo="free -lth --mega"                            # Show free/used memory
alias memhog="ps -eo pid,ppid,cmd,%mem --sort=-%mem | head" # Processes consuming most memory
alias distro="bat /etc/*-release"                           # Show OS info

# Utilities
#--------------
alias mkdir="mkdir -pv"
alias ping="ping -c 5"
alias upgrade="sudo apt update && sudo apt upgrade"

# Dotfiles Management
#--------------
alias dot="/usr/bin/git --git-dir=${HOME}/.dotfiles/ --work-tree=$HOME"
