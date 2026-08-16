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

Write-Host "`nListo. Cierra y vuelve a abrir Windows Terminal para ver los cambios." -ForegroundColor Yellow
Write-Host "Si tienes WSL, corre tambien: wsl bash -c ""$($RepoRoot -replace '\\','/' -replace '^C:','/mnt/c')/wsl/install.sh""" -ForegroundColor Yellow
