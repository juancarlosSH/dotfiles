[English](README.md) | **Español**

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
- **Starship**: un único `starship.toml` compartido entre Windows y WSL, con
  badges para Python, Node.js, TypeScript, React, Vue, Express, FastAPI,
  Java, C/C++, C#, Docker, y un aviso cuando hay un `.env` en la carpeta.
  También muestra la hora y la canción sonando en Spotify.
  - React/Vue/Express/FastAPI solo se evalúan dentro de WSL/Linux (ahí es
    donde realmente se programa); en Windows nativo no hacen nada.
  - El badge de Spotify solo funciona en Windows (lee la sesión de medios
    del sistema vía un watcher en segundo plano, ver abajo) y agrega
    ~150-200ms a cada render del prompt en Windows (arrancar un proceso
    tiene ese costo ahí). Si se siente lento, comenta la línea
    `${custom.spotify}` en `shared/starship.toml`.

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
copia `starship.toml`; aplica el tema/fuente/cursor a Windows Terminal; y
registra el watcher de Spotify para que arranque solo (acceso directo en la
carpeta de Inicio — no usa Task Scheduler porque eso pide admin).

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
│   ├── spotify-watcher.ps1             # lee Spotify (SMTC) cada 5s -> cache
│   └── PowerShell/
│       └── Microsoft.PowerShell_profile.ps1
├── wsl/
│   ├── install.sh                      # bootstrap completo de WSL
│   └── bashrc.snippet.sh               # bloque que se agrega a ~/.bashrc
└── shared/
    └── starship.toml                   # tema Catppuccin Mocha + badges del prompt
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
