
# ============================================================
#  Personalizacion dev (agregado por Claude)
# ============================================================

# ble.sh - resaltado de sintaxis y line editor mejorado (debe ir primero)
[[ $- == *i* ]] && [[ -f "$HOME/.local/share/blesh/ble.sh" ]] && source "$HOME/.local/share/blesh/ble.sh"

# bash-completion - autocompletado de comandos, flags, branches de git, etc.
if [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

export PATH="$HOME/.local/bin:$PATH"

# Starship prompt
eval "$(starship init bash)"

# zoxide - navegacion inteligente (usa 'z carpeta')
eval "$(zoxide init bash)"

# Alias utiles
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
