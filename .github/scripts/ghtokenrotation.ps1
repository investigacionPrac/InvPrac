param (
    [String] $action,
    [String] $keyvaultname,
    [String] $organization
)

$commonPath = './.github/metadata'

function getToken{   
    param (
            [String] $metadataPath,
            [String] $matchPattern
        )
        $tokenData = az keyvault secret list --vault-name $keyvaultname  | ConvertFrom-Json
        $now = Get-Date
        if (-not (Test-Path $commonPath)){
            mkdir -Path $commonPath 
        }
        if(-not (Test-Path $metadataPath)){
            Write-Host "no existe el path $metadataPath se procederá a crear"
            New-Item -Path $metadataPath
            $content = @{ 
               'token_name' = "nombre del token"
               'expires' = $now.ToString('yyyy-MM-ddTHH:mm:ssZ')
            }
            $content | ConvertTo-Json -Depth 2 | Set-Content $metadataPath -Encoding UTF8
        }          
        $data= Get-Content $metadataPath | ConvertFrom-Json
        $tokens = $tokenData.name -match $matchPattern

        $expiring = [datetime]::Parse($data.expires).ToUniversalTime()
        $diff = ($expiring - $now).Days
        if ($tokens.Count -ge 1){
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
                    az keyvault secret delete --vault-name $keyvaultname --name $tokenName
                    return $value
                }else {
                    Write-Host "La fecha a la que se va a cambiar es anterior o igual a la que hay actualmente por lo que se eliminará el token más antiguo"
                    az keyvault secret delete --vault-name $keyvaultname --name $tokenName
                }
            } else {
                Write-Host "Por el momento no hay que rotar (faltan $diff días)"
            }           
        } else{
            Write-Host "No quedan tokens en el pool tienes que crear mas con el patron $matchPattern"
        }
        return $null
}
switch ($action) {
    'Workflow' { 
        $metaPath = Join-Path $commonPath "workflow-secrets-metadata.json"
        $value=getToken -matchPattern "^gh-wkt-pool-\d{3}$" -metadataPath $metaPath
        Write-Host "---------------valor: $value"   #<<<<<<<<<<<< eliminar estas lineas simplemente estan para debug
        $value = 'esto es una contrasena de prueba' #<<<<<<<<<<<< eliminar estas lineas simplemente estan para debug
        Write-Host "---------------valor: $value"   #<<<<<<<<<<<< eliminar estas lineas simplemente estan para debug
        #gh secret set -o $organization GHTOKENWORKFLOW -b $value <<<<< está comentado para no modificar el valor token de workflow
        gh secret set -o $organization TESTWORKFLOW -b $value
     }
     'StorageAccountDelivery'{
        $metaPath = Join-Path $commonPath "SA-secrets-metadata.json"
        $value=getToken -matchPattern "^gh-SA-pool-\d{3}$" -metadataPath $metaPath
        #gh secret set STORAGECONTEXT -b $value <<<<<<<< está comentado para no modificar el valor del token del deliver a Azure Storage Account
     }
     'ghPackagesDeliver'{
        $metaPath = Join-Path $commonPath "GHP-secrets-metadata.json"
        $value=getToken -matchPattern "^gh-ghp-pool-\d{3}$" -metadataPath $metaPath
        #gh secret set -o $organization GITHUBPACKAGESCONTEXT -b $value <<<<<<< está comentado para no modificar el valor del token del deliver a GHPackages
     }
     'environment'{
        $environments = ConvertFrom-Json $env:ENVJSON
        foreach($env in $environments){
            foreach($key in $env.PSObject.Properties.Name){
                $obj = $env.$key
                $envName= $obj.EnvironmentName
                $metaPath = Join-Path $commonPath "${envName}-secrets-metadata.json"
                $value=getToken -matchPattern "^${envName}-AUTHCONTEXT-pool-\d{3}$" -metadataPath $metaPath # con este patron hacemos que solo obtenga el valor del token de cada entorno ya que si no estuviese 
                $secretName = (gh secret list -e $envName --json name | ConvertFrom-Json).name
                if ($envName -like 'test'){ #esta condición se eliminará posteriormente, está puesta solo para que no modifique los valores de los secretos para hacer deploy
                    gh secret set $secretName -e $envName -b $value
                }
            }
          }
    }
    Default {
        Write-Error "No es una opción válida"
    }
}