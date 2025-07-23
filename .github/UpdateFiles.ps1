$filesToBring = @('.alpackages/','settings.json','launch.json', 'helloworld.txt')

foreach ($file in $filesToBring) {
    $source = Join-Path -Path 'template' -ChildPath $file
    $destination = Join-Path -Path 'InvPrac' -ChildPath $file

    if (Test-Path -Path $source) {
        if (Test-Path -Path $source -PathType Container) {
            # Si es un directorio, comparar por existencia o cambios en archivos internos
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

Write-Output "Verificación y actualización completadas."