$environments = (gh api repos/$env:OWNER/$appRepo/environments) | ConvertFrom-Json
$names = $environments.environments.Name

foreach ($envName in $names){
        gh workflow run "test2.yaml" --ref main --field entorno=$envName
    }
