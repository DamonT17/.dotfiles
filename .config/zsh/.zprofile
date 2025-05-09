#!/usr/bin/zsh

# Additional configuration options for MacOS
if [[ $(uname -s) == "Darwin" && $(uname -m) == "arm64" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # Check if Homebrew is part of PATH
  if [[ ":$PATH:" != *":/opt/homebrew/bin:"* && ":$PATH:" != *":/opt/homebrew/sbin:"* ]]; then
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
  fi

  # Make Homebrew install folders known
  # export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

  # Use Homebrew installed llvm clang instead of system clang
  export PATH="/opt/homebrew/opt/llvm@19/bin:$PATH"
  # export CC="/opt/homebrew/opt/llvm@19/bin/clang"
  # export CXX="${CC}++"
  # export LDFLAGS="$LDFLAGS -L/opt/homebrew/opt/llvm/lib"
  # export CPPFLAGS="$CPPFLAGS -I/opt/homebrew/opt/llvm/include"
fi
