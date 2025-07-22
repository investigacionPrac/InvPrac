param (
    [string]$RepoPath = $env:GITHUB_WORKSPACE
)

$defaultUrl = 'https://www.tecon.es/'
$defaultLogo = './Logo/Tecon.png'
$fieldsToCheck = @('privacyStatement', 'EULA', 'help', 'url')

Write-Host "Analizando repo en: $RepoPath"

$appFiles = Get-ChildItem -Path $RepoPath -Filter "app.json" -Recurse -File

if (-not $appFiles) {
    Write-Host "No se encontraron archivos app.json"
    exit 1
}

$filesWithDates = @()

foreach ($file in $appFiles) {
    $relativePath = $file.FullName.Substring($RepoPath.Length + 1).Replace('\', '/')
    $timestamp = git -C $RepoPath log -1 --format="%ct" -- "$relativePath"
    $message = git -C $RepoPath log -1 --format="%s" -- "$relativePath"
    Write-Host "mensaje: $message"
    if ($timestamp -and $message -match '^New PTE\s+\(.+\)$') {
        Write-Host "Archivo app.json encontrado: $($file.FullName) con mensaje: $message"
        $filesWithDates += [PSCustomObject]@{
            Path = $file.FullName
            CommitTimestamp = [int]$timestamp
        }
    }
}

$latest = $filesWithDates | Sort-Object CommitTimestamp -Descending | Select-Object -First 1

if (-not $latest) {
    Write-Host "No se pudo determinar el archivo más reciente por Git"
    exit 1
}

Write-Host "Archivo app.json más recientemente modificado en Git:"
Write-Host $($latest.Path)

# Leer y actualizar JSON
$data = Get-Content -Path $latest.Path -Raw | ConvertFrom-Json

foreach ($field in $fieldsToCheck) {
            if (-not $data.$field) {
                $data.$field = $defaultUrl
            }
        }
if (-not $data.logo) {
    $data.logo = $defaultLogo
}
$data.version = "2.$((Get-Date).ToString('yyyyMMdd')).0.0"
$data | ConvertTo-Json -Depth 10 | Set-Content -Path $latest.Path -Encoding utf8

Write-Host "Archivo actualizado: $($latest.Path)"
Write-Host "Nueva versión: $($data.version)"