#!/usr/bin/zsh

# History config
#--------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=5000
HISDUP=erase
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_SAVE_NO_DUPS

# Other configs
#--------------
unsetopt BEEP

#+--- Aliases ---+#
# Terminal
#--------------
alias c="clear"
alias reload="source ~/.zshrc"

# Utilities
#--------------
alias dot="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
alias mkdir="mkdir -pv"
alias ping="ping -c 5"
alias upgrade="sudo apt update && sudo apt upgrade"

# SSH config
eval $(ssh-agent)

#+--- Setup fzf ---+#
# Target binary
#--------------
if [[ ! "$PATH" == */$HOME/.fzf/bin* ]]; then
    export PATH="${PATH:+${PATH}:}/$HOME/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "$HOME/.fzf/shell/key-bindings.zsh"
export FZF_DEFAULT_COMMAND='fd --type f --color=never --follow --hidden --exclude .git'
export FZF_DEFAULT_OPTS='--no-height'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat -p --color=always --line-range :50 {}'"
export FZF_ALT_C_COMMAND='fd --type d . --color=never'
export FZF_ALT_C_OPTS="--preview 'exa -T -s new {} | head -50'"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#+--- Setup zoxide ---+#
export _ZO_DATA_DIR=$XDG_DATA_HOME

#+--- Setup SML/NJ ---+#
export SMLROOT="$HOME/.smlnj"

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
eval "$(gh copilot alias -- zsh)"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
