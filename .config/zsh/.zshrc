#!/usr/bin/zsh

# Variables
#--------------
zsh_dir=${${ZDOTDIR}:-${HOME}/.config/zsh}

# If not an interactive shell, do not continue
[[ $- != *i* ]] && return

# Source Zsh config files
if [[ -d ${zsh_dir} ]]; then
  source "${zsh_dir}/lib/alias.zsh"
  source "${zsh_dir}/lib/history.zsh"
  source "${zsh_dir}/lib/fzf.zsh"
  source "${zsh_dir}/lib/zsh-autosuggestions/zsh-autosuggestions.zsh"
  source "${zsh_dir}/lib/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

  source "${zsh_dir}/helpers/misc.zsh"
fi

# Other configs
#--------------
unsetopt BEEP

# SSH config
eval $(ssh-agent)

#+--- Setup zoxide ---+#
export _ZO_DATA_DIR=$XDG_DATA_HOME

#+--- Setup SML/NJ ---+#
export SMLROOT="$HOME/.smlnj"

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
eval "$(gh copilot alias -- zsh)"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
