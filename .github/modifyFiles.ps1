

$defaultUrl = 'https://www.tecon.es/'
$defaultLogo = './Logo/Tecon.png'
$fieldsToCheck = @('privacyStatement', 'EULA', 'help', 'url')



# Read JSON file
# Buscar app.json en subdirectorios
$file = Get-ChildItem -Path . -Filter "app.json" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

if ($null -eq $file) {
    Write-Error "No se encontró ningún archivo app.json"
    exit 1
}

# Leer contenido del archivo JSON
$jsonText = Get-Content -Path $file.FullName -Raw -Encoding UTF8

# Deserializar JSON
$data = [Newtonsoft.Json.JsonConvert]::DeserializeObject($jsonText)

# Inicializar campo contextSensitiveHelp
$data['contextSensitiveHelp'] = $defaultUrl 

# Validar campos y completarlos si están vacíos
foreach ($field in $fieldsToCheck) {
    if (-not $data[$field]) {
        $data[$field] = $defaultUrl
    }
}

# Establecer logo si no está presente
if (-not $data['logo']) {
    $data['logo'] = $defaultLogo
}

# Agregar versión
$data['version'] = "2.$((Get-Date).ToString('yyyyMMdd')).0.0"

# Serializar JSON actualizado
$jsonOutput = [Newtonsoft.Json.JsonConvert]::SerializeObject($data, [Newtonsoft.Json.Formatting]::Indented)

# Sobrescribir el archivo original
Set-Content -Path $file.FullName -Value $jsonOutput -Encoding UTF8
