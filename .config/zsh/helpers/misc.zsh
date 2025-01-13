#!/usr/bin/zsh

# Miscellaneous configurations

# Set alias to 'nvim' for machines without Neovim installed
if ! hash nvim 2> /dev/null; then
  alias nvim="vim"
fi
