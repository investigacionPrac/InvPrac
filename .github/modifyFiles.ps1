param (
    [string]$RepoPath = $env:GITHUB_WORKSPACE,
    [int]$CommitsToCheck = 50,
    [string]$Action = ""
)

# --- Configuración global ---
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

# --- Función: buscar el app.json más reciente en commits "New PTE (...)"
function Get-LastAppJsonPath {
    param (
        [string]$RepoPath,
        [int]$CommitsToCheck = 50
    )

    $commitsRaw = git -C $RepoPath log -n $CommitsToCheck --format="%H|%s|%ct"
    if (-not $commitsRaw) {
        return $null
    }

    foreach ($line in $commitsRaw) {
        $parts = $line -split '\|', 3
        $commitHash = $parts[0]
        $commitMessage = $parts[1]

        if ($commitMessage -match '^New PTE\s+\(.+\)$') {
            $filesChangedRaw = git -C $RepoPath diff-tree --no-commit-id --name-only -r $commitHash
            foreach ($fileChanged in $filesChangedRaw) {
                if ($fileChanged -like '*app.json') {
                    return (Join-Path $RepoPath $fileChanged)
                }
            }
        }
    }

    return $null
}

# --- Función: actualizar app.json ---
function Update-AppJson {
    param (
        [string]$FilePath
    )

    Write-Host "🔧 Actualizando: $FilePath"
    $data = Get-Content -Path $FilePath -Raw | ConvertFrom-Json

    foreach ($field in $fieldsToCheck) {
        if (-not $data.$field) {
            $data.$field = $defaultUrl
        }
    }

    if (-not $data.contextSensitiveHelpUrl) {
        $data.contextSensitiveHelpUrl = $defaultUrl
    }

    if (-not $data.logo) {
        $data.logo = $defaultLogo
    }

    $data.version = "2.$((Get-Date).ToString('yyyyMMdd')).0.0"

    $data | ConvertTo-Json -Depth 10 | Set-Content -Path $FilePath -Encoding utf8
    Write-Host "app.json actualizado con nueva versión: $($data.version)"
}

# --- Función: crear/modificar launch.json ---
function Update-LaunchJson {
    param (
        [string]$RepoPath
    )

    $vscodePath = Join-Path $RepoPath '.vscode'
    if (-not (Test-Path $vscodePath)) {
        New-Item -Path $vscodePath -ItemType Directory -Force | Out-Null
    }

    $launchPath = Join-Path $vscodePath 'launch.json'
    $launch | ConvertTo-Json -Depth 10 | Set-Content -Path $launchPath -Encoding utf8
    Write-Host "launch.json actualizado en $launchPath"
}

# --- Función: crear/modificar settings.json ---
function Update-SettingsJson {
    param (
        [string]$RepoPath
    )

    $vscodePath = Join-Path $RepoPath '.vscode'
    if (-not (Test-Path $vscodePath)) {
        New-Item -Path $vscodePath -ItemType Directory -Force | Out-Null
    }

    $settingsPath = Join-Path $vscodePath 'settings.json'
    $settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath -Encoding utf8
    Write-Host "settings.json actualizado en $settingsPath"
}

# --- Controlador principal según la acción ---
switch ($Action.ToLower()) {
    'appjson' {
        $targetAppJson = Get-LastAppJsonPath -RepoPath $RepoPath -CommitsToCheck $CommitsToCheck
        if ($null -ne $targetAppJson) {
            Update-AppJson -FilePath $targetAppJson
        } else {
            Write-Warning "No se encontró app.json válido para modificar."
        }
    }

    'launch' {
        $targetAppJson = Get-LastAppJsonPath -RepoPath $RepoPath -CommitsToCheck $CommitsToCheck
        if ($null -ne $targetAppJson) {
            $appFolder = Split-Path -Path $targetAppJson -Parent
            Update-LaunchJson -RepoPath $appFolder
        } else {
            Write-Warning "No se encontró app.json para generar launch.json."
        }
    }

    'settings' {
        $targetAppJson = Get-LastAppJsonPath -RepoPath $RepoPath -CommitsToCheck $CommitsToCheck
        if ($null -ne $targetAppJson) {
            $appFolder = Split-Path -Path $targetAppJson -Parent
            Update-SettingsJson -RepoPath $appFolder
        } else {
            Write-Warning "No se encontró app.json para generar settings.json."
        }
    }
    
    default {
        Write-Warning "'$Action' no reconocida. Usa: appjson, launch, settings, full"
    }
}
