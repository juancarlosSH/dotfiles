<#
.SYNOPSIS
    Corre en segundo plano y escribe "Artista - Cancion" en un archivo cache
    cuando Spotify Desktop esta reproduciendo algo, leyendo la API de medios
    de Windows (SMTC). El prompt de Starship solo LEE ese archivo (rapido);
    este script es el unico que hace el trabajo pesado (~cada 5s).
.NOTES
    Debe correr con Windows PowerShell (powershell.exe), no pwsh: la
    interop classica con WinRT que usa este script es la que funciona de
    forma confiable ahi.
#>

$cacheDir = "$HOME\.cache"
if (-not (Test-Path $cacheDir)) { New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null }
$cacheFile = "$cacheDir\spotify_now_playing.txt"

# Fuerza la carga de los tipos WinRT necesarios
[Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager, Windows.Media.Control, ContentType = WindowsRuntime] | Out-Null
[Windows.Foundation.IAsyncOperation`1, Windows.Foundation, ContentType = WindowsRuntime] | Out-Null

Add-Type -AssemblyName System.Runtime.WindowsRuntime
$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {
    $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
})[0]

function Wait-WinRtTask {
    param($WinRtTask, [Type]$ResultType)
    $task = $asTaskGeneric.MakeGenericMethod($ResultType).Invoke($null, @($WinRtTask))
    $task.Wait(-1) | Out-Null
    return $task.Result
}

function Get-NowPlaying {
    try {
        $managerTask = [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager]::RequestAsync()
        $manager = Wait-WinRtTask $managerTask ([Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager])
        $session = $manager.GetCurrentSession()

        if (-not $session -or $session.SourceAppUserModelId -notmatch "Spotify") {
            return ""
        }

        $playbackInfo = $session.GetPlaybackInfo()
        $isPlaying = $playbackInfo.PlaybackStatus -eq [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionPlaybackStatus]::Playing
        if (-not $isPlaying) { return "" }

        $propsTask = $session.TryGetMediaPropertiesAsync()
        $props = Wait-WinRtTask $propsTask ([Windows.Media.Control.GlobalSystemMediaTransportControlsSessionMediaProperties])
        if (-not $props.Artist -and -not $props.Title) { return "" }
        return "$($props.Artist) - $($props.Title)"
    } catch {
        return ""
    }
}

while ($true) {
    $nowPlaying = Get-NowPlaying
    try {
        Set-Content -Path $cacheFile -Value $nowPlaying -Encoding utf8 -NoNewline -ErrorAction Stop
    } catch { }
    Start-Sleep -Seconds 5
}
