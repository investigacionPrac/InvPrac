param (
    [string]$TemplateRepoUrl,
    [string]$LocalRepoPath = $env:GITHUB_WORKSPACE
)

function Get-TemplateFiles {
    param([string]$repoUrl, [string]$clonePath)
    if (Test-Path $clonePath) {
        Remove-Item -Recurse -Force $clonePath
    }
    git clone $repoUrl $clonePath
}

function Compare-And-UpdateFiles {
    param([string]$templatePath, [string]$targetPath)

    $templateFiles = Get-ChildItem -Path $templatePath -Recurse -File

    foreach ($file in $templateFiles) {
        $relativePath = $file.FullName.Substring($templatePath.Length + 1)
        $targetFile = Join-Path $targetPath $relativePath

        if (Test-Path $targetFile) {
            # Comprobar si hay diferencias
            $templateContent = Get-Content $file.FullName -Raw
            $targetContent = Get-Content $targetFile -Raw
            if ($templateContent -ne $targetContent) {
                Write-Host "Actualizando archivo $relativePath"
                Copy-Item -Path $file.FullName -Destination $targetFile -Force
            }
            else {
                Write-Host "Archivo $relativePath sin cambios, salto"
            }
        }
        else {
            Write-Host "Añadiendo archivo nuevo $relativePath"
            $parentDir = Split-Path $targetFile -Parent
            if (-not (Test-Path $parentDir)) {
                New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            }
            Copy-Item -Path $file.FullName -Destination $targetFile
        }
    }
}
