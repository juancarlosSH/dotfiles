**English** | [Español](README.es.md)

# dotfiles

My development environment setup (PowerShell + Windows Terminal + WSL),
ready to restore on a new or freshly formatted machine in minutes.

## What's included

- **PowerShell**: profile with [Starship](https://starship.rs), predictive
  autocompletion (PSReadLine), file icons (Terminal-Icons), fast navigation
  (`zoxide`), and Unix-style aliases (`ll`, `la`, `which`, `touch`, `grep`).
- **Windows Terminal**: **Catppuccin Mocha** color scheme, `JetBrainsMono
  Nerd Font` (Mono variant), and a vertical bar cursor.
- **WSL (bash)**: the same Starship/zoxide/alias setup, so it looks and
  feels the same as on Windows, plus [ble.sh](https://github.com/akinomyoga/ble.sh)
  (syntax highlighting and a better line editor) and `bash-completion`
  (tab-completion for commands, flags, git branches, etc.).
- **Starship**: a single `starship.toml` shared between Windows and WSL,
  with badges for Python, Node.js, TypeScript, React, Vue, Express, FastAPI,
  Java, C/C++, C#, Docker, and a warning when a `.env` file is present.
  It also shows the time and the currently playing Spotify track.
  - React/Vue/Express/FastAPI are only evaluated inside WSL/Linux (that's
    where the actual coding happens); they're no-ops on native Windows.
  - The Spotify badge only works on Windows (it reads the system media
    session via a background watcher, see below) and adds ~150-200ms to
    every prompt render on Windows (spawning a process costs that much
    there). If it feels slow, comment out the `${custom.spotify}` line in
    `shared/starship.toml`.

## Installing on a new machine

### 1. Clone the repo

```powershell
git clone https://github.com/juancarlosSH/dotfiles.git $HOME\dotfiles
cd $HOME\dotfiles
```

### 2. Windows (PowerShell)

```powershell
./windows/install.ps1
```

This installs (via `winget`) the Nerd Font, Starship, zoxide, and GitHub
CLI; installs the `Terminal-Icons` module; copies the PowerShell profile to
`$PROFILE`; copies `starship.toml`; applies the theme/font/cursor to
Windows Terminal; and registers the Spotify watcher to start automatically
(a shortcut in the Startup folder — not Task Scheduler, since that needs
admin rights).

It's **idempotent**: safe to run multiple times without duplicating
anything, and it automatically backs up your `$PROFILE` and Windows
Terminal's `settings.json` before touching them.

Close and reopen Windows Terminal when it's done.

### 3. WSL (optional, if you use a distro)

```bash
bash /mnt/c/Users/<your-user>/dotfiles/wsl/install.sh
```

Installs Starship, zoxide, and ble.sh without needing `sudo` (they land in
`~/.local/bin` / `~/.local/share`), links the same `starship.toml`, and
appends the config block to your `~/.bashrc` (without duplicating it if
it's already there). `bash-completion` does need `sudo` (it's an `apt`
package); the script installs it via `sudo apt install` if `sudo` is
available, and just warns you to install it manually otherwise.

## Structure

```
dotfiles/
├── windows/
│   ├── install.ps1                     # full Windows bootstrap
│   ├── apply-terminal-settings.ps1     # only applies the Windows Terminal theme
│   ├── spotify-watcher.ps1             # reads Spotify (SMTC) every 5s -> cache
│   └── PowerShell/
│       └── Microsoft.PowerShell_profile.ps1
├── wsl/
│   ├── install.sh                      # full WSL bootstrap
│   └── bashrc.snippet.sh               # block appended to ~/.bashrc
└── shared/
    └── starship.toml                   # Catppuccin Mocha theme + prompt badges
```

## Updating the repo with local changes

If you tweak your PowerShell profile or `starship.toml` locally and want to
save the change back to the repo:

```powershell
Copy-Item $PROFILE ./windows/PowerShell/Microsoft.PowerShell_profile.ps1 -Force
Copy-Item "$HOME\.config\starship.toml" ./shared/starship.toml -Force
git add -A
git commit -m "update dotfiles"
git push
```
