#!/usr/bin/zsh

# Zsh history configurations

HISTFILE="${XDG_CACHE_HOME}/zsh/history"
HISTSIZE=10000
SAVEHIST=5000
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
