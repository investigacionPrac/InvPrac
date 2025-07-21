

$defaultUrl = 'https://www.tecon.es/'
$defaultLogo = './Logo/Tecon.png'
$fieldsToCheck = @('privacyStatement', 'EULA', 'help', 'url')

# Read JSON file
# Buscar app.json en subdirectorios
# Buscar el primer app.json
$file = Get-ChildItem -Path . -Filter "app.json" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $file) {
    Write-Error "No se encontró ningún archivo app.json"
    exit 1
}

# Leer contenido JSON y convertirlo en objeto PowerShell
$jsonText = Get-Content -Path $file.FullName -Raw -Encoding UTF8
$data = $jsonText | ConvertFrom-Json

# Inicializar campo contextSensitiveHelp
$data.contextSensitiveHelp = $defaultUrl

# Completar campos si están vacíos
foreach ($field in $fieldsToCheck) {
    if (-not $data.$field) {
        $data.$field = $defaultUrl
    }
}

# Agregar logo si no existe
if (-not $data.logo) {
    $data.logo = $defaultLogo
}

# Agregar versión
$data.version = "2.$((Get-Date).ToString('yyyyMMdd')).0.0"

# Convertir a JSON de nuevo
$jsonOutput = $data | ConvertTo-Json -Depth 10

# Escribir archivo
Set-Content -Path $file.FullName -Value $jsonOutput -Encoding UTF8

