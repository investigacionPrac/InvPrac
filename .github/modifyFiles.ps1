# Import the necessary modules
Import-Module -Name Json

$defaultUrl = 'https://www.tecon.es/'
$defaultLogo = './Logo/Tecon.png'
$fieldsToCheck = @('privacyStatement', 'EULA', 'help', 'url')

# Read the JSON file
$data = Get-Content -Path './app.json' -Raw | ConvertFrom-Json

foreach ($field in $fieldsToCheck) {
    if (-not $data.$field) {
        $data | Add-Member -MemberType NoteProperty -Name $field -Value $defaultUrl
    }
}

if (-not $data.logo) {
    $data | Add-Member -MemberType NoteProperty -Name logo -Value $defaultLogo
}

$data.version = "2.$((Get-Date).ToString('yyyyMMdd')).0.0"

# Write the updated data back to the JSON file
$data | ConvertTo-Json -Depth 10 | Set-Content -Path 'app.json' -Encoding utf8