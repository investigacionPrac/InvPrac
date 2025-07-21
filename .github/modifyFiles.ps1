

$defaultUrl = 'https://www.tecon.es/'
$defaultLogo = './Logo/Tecon.png'
$fieldsToCheck = @('privacyStatement', 'EULA', 'help', 'url')

# Obtener todos los archivos app.json en el directorio actual y subdirectorios
$files = Get-ChildItem -Path . -Filter "app.json" -Recurse -ErrorAction SilentlyContinue

if (-not $files) {
    Write-Host "No se encontraron archivos app.json"
    exit 0
}

foreach ($file in $files) {
    Write-Host "Procesando archivo: $($file.FullName)"

    try {
        $data = Get-Content -Path $file.FullName -Raw | ConvertFrom-Json

        foreach ($field in $fieldsToCheck) {
            if (-not $data.$field) {
                $data.$field = $defaultUrl
            }
        }

        if (-not $data.logo) {
            $data.logo = $defaultLogo
        }

        $data.version = "2.$((Get-Date).ToString('yyyyMMdd')).0.0"

        $data | ConvertTo-Json -Depth 10 | Set-Content -Path $file.FullName -Encoding utf8

        Write-Host "Actualizado correctamente: $($file.FullName)"
    }
    catch {
        Write-Warning "Error al procesar $($file.FullName): $_"
    }
}