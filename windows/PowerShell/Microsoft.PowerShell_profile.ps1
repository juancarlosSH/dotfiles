# ============================================================
#  PowerShell profile - juanc
#  Prompt: Starship | Iconos: Terminal-Icons | Nav: zoxide
# ============================================================

# --- Starship prompt --------------------------------------------------
$env:STARSHIP_CONFIG = "$HOME\.config\starship.toml"
Invoke-Expression (&starship init powershell)

# --- zoxide (navegacion inteligente: usa 'z carpeta') ------------------
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# --- Terminal-Icons (iconos al hacer ls/dir) ---------------------------
Import-Module -Name Terminal-Icons

# --- PSReadLine: autocompletado predictivo + resaltado -----------------
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -Colors @{
    Command   = 'Cyan'
    Parameter = 'Gray'
    Operator  = 'Magenta'
    Variable  = 'Green'
    String    = 'Yellow'
    Number    = 'Blue'
    Comment   = 'DarkGray'
}
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# --- Alias estilo Unix --------------------------------------------------
function ll { Get-ChildItem -Force @args }
function la { Get-ChildItem -Force -Hidden @args }
function which ($cmd) { Get-Command $cmd -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source }
function touch ($file) { if (-not (Test-Path $file)) { New-Item -ItemType File -Path $file | Out-Null } }
function grep ($regex, $dir) {
    if ($dir) { Get-ChildItem $dir -Recurse | Select-String $regex }
    else { $input | Select-String $regex }
}
function df { Get-Volume }
function reload { . $PROFILE }
Set-Alias -Name g -Value git
Set-Alias -Name vim -Value nvim -ErrorAction SilentlyContinue

# --- Colores por defecto para 'ls'/'dir' extendido ----------------------
$PSStyle.FileInfo.Directory = "`e[1;34m"
