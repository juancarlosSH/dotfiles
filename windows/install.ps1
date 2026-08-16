<#
.SYNOPSIS
    Bootstrap de entorno de desarrollo en Windows (PowerShell + Windows Terminal).
.DESCRIPTION
    Instala Nerd Font, Starship, zoxide, modulos de PowerShell, aplica el perfil
    de PowerShell y el tema de Windows Terminal (Catppuccin Mocha). Idempotente:
    se puede correr varias veces sin romper nada.
.EXAMPLE
    ./install.ps1
#>

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot

function Write-Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "    OK: $msg" -ForegroundColor Green }
function Write-Skip($msg) { Write-Host "    (ya existe) $msg" -ForegroundColor DarkGray }

# --- 1. Requisitos ------------------------------------------------------
Write-Step "Verificando winget"
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget no esta disponible. Instala 'App Installer' desde la Microsoft Store primero."
}

# --- 2. Paquetes winget ---------------------------------------------------
$packages = @(
    @{ Id = "DEVCOM.JetBrainsMonoNerdFont"; Name = "JetBrainsMono Nerd Font" },
    @{ Id = "Starship.Starship";            Name = "Starship" },
    @{ Id = "ajeetdsouza.zoxide";           Name = "zoxide" },
    @{ Id = "GitHub.cli";                   Name = "GitHub CLI" }
)
foreach ($pkg in $packages) {
    Write-Step "Instalando $($pkg.Name)"
    $installed = winget list --id $pkg.Id --accept-source-agreements 2>$null | Select-String $pkg.Id
    if ($installed) {
        Write-Skip $pkg.Name
    } else {
        winget install -e --id $pkg.Id --accept-package-agreements --accept-source-agreements
        Write-Ok $pkg.Name
    }
}

# --- 3. Modulos de PowerShell ---------------------------------------------
Write-Step "Modulos de PowerShell (Terminal-Icons)"
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Scope CurrentUser
    Write-Ok "Terminal-Icons"
} else {
    Write-Skip "Terminal-Icons"
}

# --- 4. Perfil de PowerShell ------------------------------------------------
Write-Step "Aplicando perfil de PowerShell"
$profileDir = Split-Path -Parent $PROFILE
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
if (Test-Path $PROFILE) {
    Copy-Item $PROFILE "$PROFILE.backup-$(Get-Date -Format yyyyMMddHHmmss)" -Force
}
Copy-Item "$RepoRoot\windows\PowerShell\Microsoft.PowerShell_profile.ps1" $PROFILE -Force
Write-Ok "Perfil copiado a $PROFILE"

# --- 5. starship.toml ------------------------------------------------------
Write-Step "Aplicando configuracion de Starship"
$starshipConfigDir = "$HOME\.config"
if (-not (Test-Path $starshipConfigDir)) { New-Item -ItemType Directory -Path $starshipConfigDir -Force | Out-Null }
Copy-Item "$RepoRoot\shared\starship.toml" "$starshipConfigDir\starship.toml" -Force
Write-Ok "starship.toml copiado a $starshipConfigDir"

# --- 6. Windows Terminal ----------------------------------------------------
Write-Step "Aplicando tema a Windows Terminal"
& "$PSScriptRoot\apply-terminal-settings.ps1"

# --- 7. Watcher de Spotify (badge del prompt) --------------------------------
# Usa un acceso directo en la carpeta de Inicio (no Task Scheduler: registrar
# tareas programadas pide permisos de administrador; Inicio no).
Write-Step "Registrando watcher de Spotify (arranque automatico)"
$startupDir = [Environment]::GetFolderPath("Startup")
$shortcutPath = "$startupDir\SpotifyNowPlayingWatcher.lnk"
$watcherScript = "$RepoRoot\windows\spotify-watcher.ps1"
$WshShell = New-Object -ComObject WScript.Shell
$shortcut = $WshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$watcherScript`""
$shortcut.WindowStyle = 7
$shortcut.Description = "Actualiza ~/.cache/spotify_now_playing.txt para el prompt de Starship"
$shortcut.Save()
Write-Ok "Acceso directo creado en Inicio"

Write-Step "Iniciando el watcher de Spotify para esta sesion"
Start-Process powershell.exe -ArgumentList "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$watcherScript`"" -WindowStyle Hidden
Write-Ok "Watcher corriendo (se reiniciara solo en cada inicio de sesion)"

Write-Host "`nListo. Cierra y vuelve a abrir Windows Terminal para ver los cambios." -ForegroundColor Yellow
Write-Host "Si tienes WSL, corre tambien: wsl bash -c ""$($RepoRoot -replace '\\','/' -replace '^C:','/mnt/c')/wsl/install.sh""" -ForegroundColor Yellow
