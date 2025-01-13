#!/usr/bin/zsh

#+--- Setup fzf ---+#
# Path to binary
#--------------
if [[ ! "$PATH" == *"${XDG_CONFIG_HOME}/fzf/bin"* ]]; then
  PATH="${PATH:+${PATH}:}${XDG_CONFIG_HOME}/fzf/bin"
fi

# Auto-completion
#--------------
source "${XDG_CONFIG_HOME}/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
#--------------
source "${XDG_CONFIG_HOME}/fzf/shell/key-bindings.zsh"
export FZF_DEFAULT_COMMAND='fd --type f --color=never --follow --hidden --exclude .git'
export FZF_DEFAULT_OPTS='--no-height'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat -p --color=always --line-range :50 {}'"
export FZF_ALT_C_COMMAND='fd --type d . --color=never'
export FZF_ALT_C_OPTS="--preview 'exa -T -s new {} | head -50'"

source <(fzf --zsh)
