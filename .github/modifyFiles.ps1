

$defaultUrl = 'https://www.tecon.es/'
$defaultLogo = './Logo/Tecon.png'
$fieldsToCheck = @('privacyStatement', 'EULA', 'help', 'url')


$list= Get-ChildItem -Directory
$orderList=($list| Sort-Object CreationTime -Descending)
$aux= $orderList | Select-Object CreationTime
$path= $orderList[0].FullName


$repoPath = $env:GITHUB_WORKSPACE
Write-Host "lista de carpetas: $orderList"
Write-Host "fecha de la carpeta: $aux"
Write-Host "Ruta actual: $repoPath"

# Buscar todos los archivos app.json recursivamente desde la carpeta actual
$file = Get-ChildItem -Path $repoPath -Filter "app.json" -Recurse -ErrorAction SilentlyContinue

if (-not $file) {
    Write-Host "No se encontraron archivos app.json"
    exit 1
}

    Write-Host "Procesando archivo: $($file.FullName)"
    try {
        # Leer y convertir JSON a objeto PowerShell
        $data = Get-Content -Path $file.FullName -Raw | ConvertFrom-Json
        # Asegurar campos necesarios
        foreach ($field in $fieldsToCheck) {
            if (-not $data.$field) {
                $data.$field = $defaultUrl
            }
        }

        if (-not $data.logo) {
            $data.logo = $defaultLogo
        }

        # Actualizar versión con formato "2.AAAAmmdd.0.0"
        $data.version = "2.$((Get-Date).ToString('yyyyMMdd')).0.0"

        # Convertir a JSON y sobrescribir el archivo
        $data | ConvertTo-Json -Depth 10 | Set-Content -Path $file.FullName -Encoding utf8

        Write-Host "Archivo actualizado: $($file.FullName)"
        Write-Host "Nueva versión: $($data.version)"
    }
    catch {
        Write-Warning "Error procesando $($file.FullName): $_"
    }
