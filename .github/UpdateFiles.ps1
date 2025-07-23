# Obtener ruta absoluta del script
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Definir origen (siempre es template dentro del repo)
$templateRoot = Join-Path $scriptPath 'template'

# Obtener nombre del repo (último folder del path del script)
$repoName = Split-Path -Leaf $scriptPath

# Usar el nombre del repo como destino
$destinationRoot = Join-Path $scriptPath $repoName

# Lista de archivos o carpetas a copiar
$filesToBring = @('.alpackages/','settings.json','launch.json', 'helloworld.txt')

Write-Output "Actualizando archivos para el repo: $repoName"
Write-Output "Origen: $templateRoot"
Write-Output "Destino: $destinationRoot"
Write-Output ""

foreach ($file in $filesToBring) {
    $source = Join-Path -Path $templateRoot -ChildPath $file
    $destination = Join-Path -Path $destinationRoot -ChildPath $file

    if (Test-Path -Path $source) {
        if (Test-Path -Path $source -PathType Container) {
            $copyNeeded = $true
            if (Test-Path -Path $destination) {
                $sourceHash = Get-FileHash -Path (Get-ChildItem -Path $source -Recurse -File).FullName -Algorithm SHA256 | ForEach-Object Hash
                $destHash = Get-FileHash -Path (Get-ChildItem -Path $destination -Recurse -File).FullName -Algorithm SHA256 | ForEach-Object Hash
                $copyNeeded = ($sourceHash -ne $destHash)
            }
            if ($copyNeeded) {
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
            if ($copyNeeded) {
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
Write-Output "Los archivos han sido actualizados en el repo: $repoName"
