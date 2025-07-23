param (
    [string]$RepoPath = $env:GITHUB_WORKSPACE,
    [int]$CommitsToCheck = 50,
    [string]$Action = ""
)

$defaultUrl = 'https://www.tecon.es/'
$defaultLogo = './Logo/Tecon.png'
$fieldsToCheck = @('privacyStatement', 'EULA', 'help', 'url')

$launch = @{
    "version" = "0.2.0"
    "configurations" = @(
        @{
            "name" = "Sandbox"
            "request" = "launch"
            "type" = "al"
            "environmentType" = "Sandbox"
            "tenant" = ""
            "environmentName" = ""
            "breakOnError" = $true
            "launchBrowser" = $true
            "enableLongRunningSqlStatements" = $true
            "enableSqlInformationDebugger" = $true
        },
        @{
            "name" = "❌❌❌FORCE - Sandbox ❌❌❌"
            "request" = "launch"
            "type" = "al"
            "environmentType" = "Sandbox"
            "tenant" = ""
            "environmentName" = ""
            "breakOnError" = $true
            "launchBrowser" = $true
            "enableLongRunningSqlStatements" = $true
            "enableSqlInformationDebugger" = $true
            "schemaUpdateMode" = "ForceSync"
        }
    )
}

$settings = @{
    "CRS.ObjectNamePrefix" = "TCN"
    "CRS.ObjectNameSuffix" = ""
}

function Update-AppJson {
    param (
        [string]$RepoPath,
        [int]$CommitsToCheck
    )

    Write-Host "Buscando último app.json modificado por un commit tipo 'New PTE (...)'..."

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
        Write-Warning "No se encontró ningún commit tipo 'New PTE (...)' que modifique un app.json"
        return
    }

    $latest = $validCommits | Sort-Object CommitTimestamp -Descending | Select-Object -First 1

    Write-Host "Último app.json modificado:"
    Write-Host "Ruta     : $($latest.FilePath)"
    Write-Host "Mensaje  : $($latest.CommitMessage)"
    Write-Host "Fecha    : $(Get-Date ([DateTimeOffset]::FromUnixTimeSeconds($latest.CommitTimestamp).DateTime) -Format 'yyyy-MM-dd HH:mm:ss')"

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
    $data | ConvertTo-Json -Depth 10 | Set-Content -Path $latest.FilePath -Encoding utf8

    Write-Host "app.json actualizado con versión: $($data.version)"
}

function Update-LaunchJson {
    param ([string]$RepoPath)

    $vscodePath = Join-Path $RepoPath '.vscode'
    if (-not (Test-Path $vscodePath)) {
        New-Item -Path $vscodePath -ItemType Directory -Force | Out-Null
    }

    $launchPath = Join-Path $vscodePath 'launch.json'
    $launch | ConvertTo-Json -Depth 10 | Set-Content -Path $launchPath -Encoding utf8
    Write-Host "launch.json actualizado en $launchPath"
}

function Update-SettingsJson {
    param ([string]$RepoPath)

    $vscodePath = Join-Path $RepoPath '.vscode'
    if (-not (Test-Path $vscodePath)) {
        New-Item -Path $vscodePath -ItemType Directory -Force | Out-Null
    }

    $settingsPath = Join-Path $vscodePath 'settings.json'
    $settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath -Encoding utf8
    Write-Host "settings.json actualizado en $settingsPath"
}

switch ($Action.ToLower()) {
    'appjson' {
        Update-AppJson -RepoPath $RepoPath -CommitsToCheck $CommitsToCheck
    }
    'launch' {
        Update-LaunchJson -RepoPath $RepoPath
    }
    'settings' {
        Update-SettingsJson -RepoPath $RepoPath
    }
    default {
        Write-Warning "'$Action' no reconocida. Usa: appjson, launch, settings, full"
    }
}
