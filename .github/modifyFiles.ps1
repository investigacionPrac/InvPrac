param (
    [string]$RepoPath = $env:GITHUB_WORKSPACE,
    [int]$CommitsToCheck = 50
)

$defaultUrl = 'https://www.tecon.es/'
$defaultLogo = './Logo/Tecon.png'
$fieldsToCheck = @('privacyStatement', 'EULA', 'help', 'url')

Write-Host "Analizando repo en: $RepoPath"

# Obtener últimos N commits con mensaje y timestamp
$commitsRaw = git -C $RepoPath log -n $CommitsToCheck --format="%H|%s|%ct"

if (-not $commitsRaw) {
    Write-Warning "No se pudieron obtener commits recientes"
    return
}

$validCommits = @()

foreach ($line in $commitsRaw) {
    $parts = $line -split '\|', 3
    $commitHash = $parts[0]
    $commitMessage = $parts[1]
    $commitTimestamp = [int]$parts[2]

    if ($commitMessage -match '^New PTE\s+\(.+\)$') {
        # Obtener archivos modificados en ese commit
        $filesChangedRaw = git -C $RepoPath diff-tree --no-commit-id --name-only -r $commitHash
        foreach ($fileChanged in $filesChangedRaw) {
            if ($fileChanged -like '*app.json') {
                $validCommits += [PSCustomObject]@{
                    CommitHash = $commitHash
                    CommitTimestamp = $commitTimestamp
                    CommitMessage = $commitMessage
                    FilePath = Join-Path $RepoPath $fileChanged
                }
            }
        }
    }
}

if (-not $validCommits) {
    Write-Warning "No se encontró ningún commit reciente con mensaje tipo 'New PTE (...)' que modifique un app.json"
    return
}

# Ordenar por timestamp descendente y tomar el más reciente
$latest = $validCommits | Sort-Object CommitTimestamp -Descending | Select-Object -First 1

Write-Host "Archivo app.json más recientemente modificado en un commit válido:"
Write-Host $($latest.FilePath)
Write-Host "Mensaje de commit: $($latest.CommitMessage)"
Write-Host "Fecha commit: $(Get-Date ([DateTimeOffset]::FromUnixTimeSeconds($latest.CommitTimestamp).DateTime) -Format 'yyyy-MM-dd HH:mm:ss')"

# Leer y actualizar JSON
$data = Get-Content -Path $latest.FilePath -Raw | ConvertFrom-Json

foreach ($field in $fieldsToCheck) {
    if (-not $data.$field) {
        $data.$field = $defaultUrl
    }
}

if (-not $data.logo) {
    $data.logo = $defaultLogo
}

$data.version = "2.$((Get-Date).ToString('yyyyMMdd')).0.0"

# Sobrescribir archivo
$data | ConvertTo-Json -Depth 10 | Set-Content -Path $latest.FilePath -Encoding utf8

Write-Host "Archivo actualizado: $($latest.FilePath)"
Write-Host "Nueva versión: $($data.version)"