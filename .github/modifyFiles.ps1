

$defaultUrl = 'https://www.tecon.es/'
$defaultLogo = './Logo/Tecon.png'
$fieldsToCheck = @('privacyStatement', 'EULA', 'help', 'url')

# Buscar todos los archivos app.json
$files = Get-ChildItem -Path . -Filter "app.json" -Recurse -ErrorAction SilentlyContinue

if (-not $files) {
    Write-Host "No se encontraron archivos app.json"
    exit 0
}

foreach ($file in $files) {
    Write-Host "Procesando archivo: $($file.FullName)"

    try {
        # Leer JSON y convertir a objeto
        $data = Get-Content -Path $file.FullName -Raw | ConvertFrom-Json

        # Verificar campos y agregar si no existen
        foreach ($field in $fieldsToCheck) {
            if (-not $data.$field) {
                # Add-Member falla si la propiedad ya existe, pero aquí aseguramos que no exista
                $data | Add-Member -MemberType NoteProperty -Name $field -Value $defaultUrl
            }
        }

        # Verificar logo
        if (-not $data.logo) {
            $data | Add-Member -MemberType NoteProperty -Name logo -Value $defaultLogo
        }

        # Actualizar versión
        $data.version = "2.$((Get-Date).ToString('yyyyMMdd')).0.0"

        # Guardar cambios en el mismo archivo
        $data | ConvertTo-Json -Depth 10 | Set-Content -Path $file.FullName -Encoding utf8

        Write-Host "✅ Actualizado correctamente: $($file.FullName)"
    }
    catch {
        Write-Warning "❌ Error al procesar $($file.FullName): $_"
    }
}