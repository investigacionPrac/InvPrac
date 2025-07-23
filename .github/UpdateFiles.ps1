param(
    [string]$templateUrl = "",
    [string]$branch = "main",
    [string]$token = "",
    [bool]$downloadLatest = $true,
    [string]$update = "Y"
)

function Download-TemplateFromBranch {
    param (
        [string]$repoUrl,
        [string]$branch,
        [string]$token,
        [string]$targetFolder
    )

    Write-Output "Descargando plantilla desde rama '$branch' en: $repoUrl"
    
    if ($repoUrl -match "github.com[/:](.+)/(.+?)(\.git)?$") {
        $org = $Matches[1]
        $repo = $Matches[2]
    } else {
        Write-Error "URL inválida: $repoUrl"
        exit 1
    }

    $zipUrl = "https://github.com/$org/$repo/archive/refs/heads/$branch.zip"
    $zipPath = "$env:TEMP\$repo-$branch.zip"
    $extractPath = $targetFolder

    try {
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
    } catch {
        Write-Error "No se pudo descargar el ZIP desde la rama '$branch'. Verifica que exista."
        exit 1
    }

    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

    $templateFolder = Get-ChildItem -Path $extractPath -Directory | Select-Object -First 1
    return $templateFolder.FullName
}

# Buscar carpeta que contiene app.json
$basePath = Get-Location
$appJsonPath = Get-ChildItem -Path $basePath -Recurse -Filter 'app.json' -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $appJsonPath) {
    Write-Error "No se encontró app.json en el repositorio. No se puede determinar el destino."
    exit 1
}
$destinationRoot = Split-Path -Path $appJsonPath.FullName -Parent

# Descargar plantilla si se especifica
if ($downloadLatest -and $templateUrl) {
    $tempTemplateFolder = Join-Path -Path $env:TEMP -ChildPath "template-download"
    if (Test-Path $tempTemplateFolder) {
        Remove-Item -Path $tempTemplateFolder -Recurse -Force
    }
    New-Item -ItemType Directory -Path $tempTemplateFolder | Out-Null

    $templateRoot = Download-TemplateFromBranch -repoUrl $templateUrl -branch $branch -token $token -targetFolder $tempTemplateFolder
} else {
    Write-Error "No se especificó templateUrl o -downloadLatest está en false. No hay plantilla que aplicar."
    exit 1
}

$filesToBring = @('.alpackages/','settings.json','launch.json', 'helloworld.txt')

Write-Output ""
Write-Output "Origen de plantilla: $templateRoot\template"
Write-Output "Destino del proyecto: $destinationRoot"
Write-Output ""

foreach ($file in $filesToBring) {
    $source = Join-Path -Path "$templateRoot\template" -ChildPath $file
    $destination = Join-Path -Path $destinationRoot -ChildPath $file

    if (Test-Path -Path $source) {
        if (Test-Path -Path $source -PathType Container) {
            $copyNeeded = $true
            if (Test-Path -Path $destination) {
                $sourceHash = Get-FileHash -Path (Get-ChildItem -Path $source -Recurse -File).FullName -Algorithm SHA256 | ForEach-Object Hash
                $destHash = Get-FileHash -Path (Get-ChildItem -Path $destination -Recurse -File).FullName -Algorithm SHA256 | ForEach-Object Hash
                $copyNeeded = ($sourceHash -ne $destHash)
            }
            if ($copyNeeded -and $update -eq "Y") {
                if (Test-Path -Path $destination) {
                    Remove-Item -Path $destination -Recurse -Force
                }
                Copy-Item -Path $source -Destination $destination -Recurse
                Write-Output "Directorio actualizado: $file"
            } else {
                Write-Output "Sin cambios en: $file"
            }
        } else {
            $copyNeeded = $true
            if (Test-Path -Path $destination) {
                $srcHash = (Get-FileHash -Path $source -Algorithm SHA256).Hash
                $dstHash = (Get-FileHash -Path $destination -Algorithm SHA256).Hash
                $copyNeeded = ($srcHash -ne $dstHash)
            }
            if ($copyNeeded -and $update -eq "Y") {
                Copy-Item -Path $source -Destination $destination -Force
                Write-Output "Archivo actualizado: $file"
            } else {
                Write-Output "Sin cambios en: $file"
            }
        }
    } else {
        Write-Output "El archivo $source no existe."
    }
}

Write-Output ""
Write-Output "Archivos actualizados correctamente en: $destinationRoot"