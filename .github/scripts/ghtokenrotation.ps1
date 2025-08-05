param (
        [String] $keyvaultname,
        [String] $matchPattern,
        [String] $action,
        [String] $metadataPath,
        [String] $organization
    )
    $tokenData = az keyvault secret list --vault-name $keyvaultname  | ConvertFrom-Json
    $data= Get-Content $metadataPath | ConvertFrom-Json
    $tokens = $tokenData.name -match $matchPattern

    $expiring = [datetime]::Parse($data.expires).ToUniversalTime()
    $today = Get-Date
    $diff = ($expiring - $today).Days

    if ($tokens.Count -le 1){
        if ($diff -le 7) {
            Write-Host "Hay que rotar (faltan $diff días)"
            $nextToken = $tokenData | Where-Object {$_.name -match $matchPattern}| Sort-Object { [datetime]::Parse($_.attributes.expires)} | Select-Object -First 1
            $newexpiring = [datetime]::Parse($nextToken.attributes.expires).ToUniversalTime()
            $tokenName = $nextToken.Name
            if ($newexpiring -gt $expiring){
                Write-Host $newexpiring
                $data.expires = $newexpiring.ToString("yyyy-MM-ddTHH:mm:ssZ")
                $data.token_name = $tokenName
                $data | ConvertTo-Json -Depth 2 | Set-Content $metadataPath -Encoding UTF8
                Write-Host "actualizado el token a $tokenName (expira el $($newexpiring.ToString("dd/MM/yyyy HH:mm:ss")))"
                $value = (az keyvault secret show --name $nextToken.name --vault $keyvaultname | ConvertFrom-Json).value
                  az keyvault secret set --name 'testing' --value $value --expires $data.expires --vault-name $keyvaultname
            }else {
                Write-Host "La fecha a la que se va a cambiar es anterior o igual a la que hay actualmente por lo que se eliminará el token más antiguo"
            }
            az keyvault secret delete --vault-name $keyvaultname --name $tokenName
        } else {
            Write-Host "Por el momento no hay que rotar (faltan $diff días)"
        }           
    } else{
        Write-Host "No quedan tokens en el pool tienes que crear mas"
    }

# $value='testing'
switch ($action) {
    'Workflow' { 
        #$value
        $matchPattern
        #gh secret set -o $organization ghTokenWorkflow -b $value
     }
     'StorageAccountDelivery'{
        $matchPattern
        #gh secret set StorageContext -b $value
     }
     'ghPackagesDeliver'{
        $matchPattern
        #gh secret set -o $organization GitHubPackageContext -b $value
     }
     'environment'{
          $environments = ConvertFrom-Json $env:ENVJSON
          foreach($env in $environments){
            foreach($key in $env.PSObject.Properties.Name){
                $obj = $env.$key
                $envName= $obj.EnvironmentName
                $secretName = (gh secret list -e $envName --json name | ConvertFrom-Json).name
                if ($envName -like 'test'){
                  gh secret set $secretName -e $envName -b $value
                }
              }
            }
          }
    Default {
        Write-Error "No es una opción válida"
    }
}