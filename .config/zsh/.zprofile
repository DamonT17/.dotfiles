#!/usr/bin/zsh

# Additional configuration options for MacOS
if [[ $(uname -s) == "Darwin" && $(uname -m) == "arm64" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # Make Homebrew install folders known
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

  # Use Homebrew installed llvm clang instead of system clang
  export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
  export CC="/opt/homebrew/opt/llvm/bin/clang"
  export CXX="${CC}++"
  # export LDFLAGS="$LDFLAGS -L/opt/homebrew/opt/llvm/lib"
  # export CPPFLAGS="$CPPFLAGS -I/opt/homebrew/opt/llvm/include"
fi
