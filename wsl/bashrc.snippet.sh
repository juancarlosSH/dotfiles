
# ============================================================
#  Personalizacion dev (agregado por Claude)
# ============================================================
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
