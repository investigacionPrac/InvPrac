

$defaultUrl = 'https://www.tecon.es/'
$defaultLogo = './Logo/Tecon.png'
$fieldsToCheck = @('privacyStatement', 'EULA', 'help', 'url')



# Read JSON file
$jsonContent = Get-Content -Path 'app.json' -Raw -Encoding UTF8
$data = [Newtonsoft.Json.JsonConvert]::DeserializeObject($jsonContent)

# Initialize contextSensitiveHelp
$data['contextSensitiveHelp'] = $defaultUrl 

foreach ($field in $fieldsToCheck) {
    if (-not $data[$field]) {
        $data[$field] = $defaultUrl
    }
}

if (-not $data['logo']) {
    $data['logo'] = $defaultLogo
}

$data['version'] = "2.$((Get-Date).ToString('yyyyMMdd')).0.0"

# Write JSON file
$jsonOutput = [Newtonsoft.Json.JsonConvert]::SerializeObject($data, [Newtonsoft.Json.Formatting]::Indented)
Set-Content -Path 'app.json' -Value $jsonOutput -Encoding UTF8