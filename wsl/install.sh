#!/usr/bin/env bash
# Bootstrap de entorno de desarrollo dentro de WSL (bash).
# Idempotente: se puede correr varias veces sin duplicar configuracion.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MARKER="# ============================================================"
MARKER_LINE="#  Personalizacion dev (agregado por Claude)"

echo "==> Instalando Starship"
if ! command -v starship >/dev/null 2>&1; then
    mkdir -p "$HOME/.local/bin"
    curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$HOME/.local/bin"
else
    echo "    (ya existe)"
fi

echo "==> Instalando zoxide"
if ! command -v zoxide >/dev/null 2>&1; then
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
else
    echo "    (ya existe)"
fi

echo "==> Instalando ble.sh (resaltado de sintaxis + line editor)"
if [ ! -f "$HOME/.local/share/blesh/ble.sh" ]; then
    tmpdir="$(mktemp -d)"
    curl -sSL https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz | tar xJf - -C "$tmpdir"
    bash "$tmpdir"/ble-nightly/ble.sh --install "$HOME/.local/share"
    rm -rf "$tmpdir"
else
    echo "    (ya existe)"
fi

echo "==> Instalando bash-completion"
if ! dpkg -s bash-completion >/dev/null 2>&1; then
    if command -v sudo >/dev/null 2>&1; then
        sudo apt-get update -qq && sudo apt-get install -y -qq bash-completion
    else
        echo "    Aviso: no hay 'sudo' disponible, no se pudo instalar bash-completion automaticamente."
        echo "    Instalalo manualmente con: sudo apt install bash-completion"
    fi
else
    echo "    (ya existe)"
fi

echo "==> Aplicando starship.toml"
mkdir -p "$HOME/.config"
cp -f "$REPO_ROOT/shared/starship.toml" "$HOME/.config/starship.toml"

echo "==> Actualizando .bashrc"
if ! grep -qF "$MARKER_LINE" "$HOME/.bashrc" 2>/dev/null; then
    cp "$HOME/.bashrc" "$HOME/.bashrc.backup-$(date +%Y%m%d%H%M%S)" 2>/dev/null || true
    cat "$REPO_ROOT/wsl/bashrc.snippet.sh" >> "$HOME/.bashrc"
    echo "    Bloque agregado a ~/.bashrc"
else
    echo "    (ya existe)"
fi

echo ""
echo "Listo. Corre 'exec bash' o abre una terminal nueva para ver los cambios."
