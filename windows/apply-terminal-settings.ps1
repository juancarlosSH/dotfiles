<#
.SYNOPSIS
    Aplica el color scheme, fuente y cursor a Windows Terminal sin pisar
    tus perfiles/keybindings existentes. Seguro correr varias veces.
#>

$ErrorActionPreference = "Stop"

$wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

if (-not (Test-Path $wtSettingsPath)) {
    Write-Host "Windows Terminal no esta instalado (no se encontro settings.json). Saltando." -ForegroundColor DarkGray
    return
}

# Backup antes de tocar nada
Copy-Item $wtSettingsPath "$wtSettingsPath.backup-$(Get-Date -Format yyyyMMddHHmmss)" -Force

$settings = Get-Content $wtSettingsPath -Raw | ConvertFrom-Json -Depth 100

# --- Color scheme: Catppuccin Mocha -----------------------------------
$schemeName = "Catppuccin Mocha"
$scheme = [PSCustomObject]@{
    name                = $schemeName
    background          = "#1E1E2E"
    foreground          = "#CDD6F4"
    cursorColor         = "#F5E0DC"
    selectionBackground = "#585B70"
    black               = "#45475A"
    red                 = "#F38BA8"
    green               = "#A6E3A1"
    yellow              = "#F9E2AF"
    blue                = "#89B4FA"
    purple              = "#F5C2E7"
    cyan                = "#94E2D5"
    white               = "#BAC2DE"
    brightBlack         = "#585B70"
    brightRed           = "#F38BA8"
    brightGreen         = "#A6E3A1"
    brightYellow        = "#F9E2AF"
    brightBlue          = "#89B4FA"
    brightPurple        = "#F5C2E7"
    brightCyan          = "#94E2D5"
    brightWhite         = "#A6ADC8"
}

if ($settings.PSObject.Properties.Name -notcontains "schemes") {
    $settings | Add-Member -MemberType NoteProperty -Name schemes -Value @()
}
$existingIdx = -1
for ($i = 0; $i -lt $settings.schemes.Count; $i++) {
    if ($settings.schemes[$i].name -eq $schemeName) { $existingIdx = $i; break }
}
if ($existingIdx -ge 0) {
    $settings.schemes[$existingIdx] = $scheme
} else {
    $settings.schemes = @($settings.schemes) + $scheme
}

# --- profiles.defaults: fuente, cursor, colorScheme, transparencia ------
if (-not $settings.profiles.defaults) {
    $settings.profiles | Add-Member -MemberType NoteProperty -Name defaults -Value ([PSCustomObject]@{}) -Force
}
$defaults = $settings.profiles.defaults
$desired = @{
    colorScheme      = $schemeName
    cursorShape      = "bar"
    opacity          = 90
    useAcrylic       = $true
    padding          = "8, 8, 8, 8"
    antialiasingMode = "cleartype"
}
foreach ($key in $desired.Keys) {
    if ($defaults.PSObject.Properties.Name -contains $key) {
        $defaults.$key = $desired[$key]
    } else {
        $defaults | Add-Member -MemberType NoteProperty -Name $key -Value $desired[$key]
    }
}
if ($defaults.PSObject.Properties.Name -contains "font") {
    $defaults.font.face = "JetBrainsMono NFM"
    if (-not $defaults.font.size) { $defaults.font.size = 11 }
} else {
    $defaults | Add-Member -MemberType NoteProperty -Name font -Value ([PSCustomObject]@{ face = "JetBrainsMono NFM"; size = 11 })
}

$settings | ConvertTo-Json -Depth 100 | Set-Content $wtSettingsPath -Encoding utf8
Write-Host "    OK: Windows Terminal actualizado (backup guardado junto al settings.json)" -ForegroundColor Green
