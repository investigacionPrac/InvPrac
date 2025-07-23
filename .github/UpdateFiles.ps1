param(
    [string]$templatePath = "",
    [string]$update = "Y"
)

# Obtener el path base (donde se ejecuta el script)
$basePath = Get-Location

# Buscar app.json (asume que está en la raíz del proyecto AL)
$appJsonPath = Get-ChildItem -Path $basePath -Recurse -Filter 'app.json' -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $appJsonPath) {
    Write-Error "No se encontró app.json en el repositorio. No se puede determinar el destino."
    exit 1
}

$destinationRoot = Split-Path -Path $appJsonPath.FullName -Parent

# Usar templatePath proporcionado o asumir que está en ./template/
if ([string]::IsNullOrEmpty($templatePath)) {
    $templateRoot = Join-Path -Path $basePath -ChildPath "template"
} else {
    $templateRoot = $templatePath
}

Write-Output "app.json encontrado en: $destinationRoot"
Write-Output "Usando plantilla desde: $templateRoot"
Write-Output ""

# Archivos a copiar
$filesToBring = @('.alpackages/','settings.json','launch.json', 'helloworld.txt')

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