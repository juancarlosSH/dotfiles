# dotfiles

Mi configuración de entorno de desarrollo (PowerShell + Windows Terminal + WSL),
lista para restaurar en un equipo nuevo o recién formateado en minutos.

## Qué incluye

- **PowerShell**: perfil con [Starship](https://starship.rs), autocompletado
  predictivo (PSReadLine), iconos de archivos (Terminal-Icons), navegación
  rápida (`zoxide`) y alias estilo Unix (`ll`, `la`, `which`, `touch`, `grep`).
- **Windows Terminal**: tema de color **Catppuccin Mocha**, fuente
  `JetBrainsMono Nerd Font` (variante Mono) y cursor tipo barra vertical.
- **WSL (bash)**: la misma configuración de Starship/zoxide/alias, para que
  se vea y se sienta igual que en Windows.
- **Starship**: un único `starship.toml` compartido entre Windows y WSL.

## Instalación en un equipo nuevo

### 1. Clona el repo

```powershell
git clone https://github.com/juancarlosSH/dotfiles.git $HOME\dotfiles
cd $HOME\dotfiles
```

### 2. Windows (PowerShell)

```powershell
./windows/install.ps1
```

Esto instala (via `winget`) la Nerd Font, Starship, zoxide y GitHub CLI;
instala el módulo `Terminal-Icons`; copia el perfil de PowerShell a `$PROFILE`;
copia `starship.toml`; y aplica el tema/fuente/cursor a Windows Terminal.

Es **idempotente**: se puede correr varias veces sin duplicar nada, y hace
backup automático de tu `$PROFILE` y del `settings.json` de Windows Terminal
antes de tocarlos.

Cierra y vuelve a abrir Windows Terminal al terminar.

### 3. WSL (opcional, si usas alguna distro)

```bash
bash /mnt/c/Users/<tu-usuario>/dotfiles/wsl/install.sh
```

Instala Starship y zoxide sin necesitar `sudo` (quedan en `~/.local/bin`),
enlaza el mismo `starship.toml` y agrega el bloque de configuración a tu
`~/.bashrc` (sin duplicar si ya existe).

## Estructura

```
dotfiles/
├── windows/
│   ├── install.ps1                     # bootstrap completo de Windows
│   ├── apply-terminal-settings.ps1     # solo aplica tema a Windows Terminal
│   └── PowerShell/
│       └── Microsoft.PowerShell_profile.ps1
├── wsl/
│   ├── install.sh                      # bootstrap completo de WSL
│   └── bashrc.snippet.sh               # bloque que se agrega a ~/.bashrc
└── shared/
    └── starship.toml                   # tema Catppuccin Mocha del prompt
```

## Actualizar el repo con cambios locales

Si modificas tu perfil de PowerShell o `starship.toml` localmente y quieres
guardar el cambio en el repo:

```powershell
Copy-Item $PROFILE ./windows/PowerShell/Microsoft.PowerShell_profile.ps1 -Force
Copy-Item "$HOME\.config\starship.toml" ./shared/starship.toml -Force
git add -A
git commit -m "update dotfiles"
git push
```
