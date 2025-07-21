# Import the necessary module
Import-Module -Name 'PSScriptRoot'

$defaultUrl = 'https://www.tecon.es/'
$defaultLogo = './Logo/Tecon.png'
$fieldsToCheck = @('privacyStatement', 'EULA', 'help', 'url')

# Read the JSON file
$jsonContent = Get-Content -Path 'app.json' -Raw -Encoding utf8 | ConvertFrom-Json

foreach ($field in $fieldsToCheck) {
    if (-not $jsonContent.$field) {
        $jsonContent | Add-Member -MemberType NoteProperty -Name $field -Value $defaultUrl
    }
}

if (-not $jsonContent.logo) {
    $jsonContent | Add-Member -MemberType NoteProperty -Name logo -Value $defaultLogo
}

$jsonContent.version = "2.$((Get-Date).ToString('yyyyMMdd')).0.0"

# Write the updated JSON back to the file
$jsonContent | ConvertTo-Json -Depth 4 | Set-Content -Path 'app.json' -Encoding utf8