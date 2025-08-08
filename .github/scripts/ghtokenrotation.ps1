param (
    [String] $action,
    [String] $keyvaultname
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
                    $tokenJson = (az keyvault secret show --name $tokenName --vault $keyvaultname | ConvertFrom-Json)
                    
                    #Write-Host "---------------valor: $value"   #<<<<<<<<<<<< eliminar estas lineas simplemente estan para debug
                    #az keyvault secret set --name 'testing' --value $value --expires $data.expires --vault-name $keyvaultname #<<<<<<<<<<<<<<<<<<<<< eliminar esto, ya que no queremos un nuevo token simplemente está para pruebas
                    #Write-Host "---------------valor despues de crear un nuevo token : $value"   #<<<<<<<<<<<< eliminar estas lineas simplemente estan para debug
                    az keyvault secret delete --vault-name $keyvaultname --name $tokenName
                    #Write-Host "---------------valor despues de eliminar el token en el pool: $value"   #<<<<<<<<<<<< eliminar estas lineas simplemente estan para debug
                    return $tokenJson
                }else {
                    Write-Warning "La fecha a la que se va a cambiar es anterior o igual a la que hay actualmente por lo que se eliminará el token más antiguo"
                    az keyvault secret delete --vault-name $keyvaultname --name $tokenName
                }
            } else {
                Write-Host "Por el momento no hay que rotar (faltan $diff días)"
            }           
        } else{
            Write-Warning "No quedan tokens en el pool tienes que crear mas con el patron $matchPattern"
        }
        return $null
}
switch ($action) {
    'Workflow' { 
        $metaPath = Join-Path $commonPath "workflow-secrets-metadata.json"
        $token= getToken -matchPattern "^gh-wkt-pool-\d{3}$" -metadataPath $metaPath
        $value = $token.value
        Write-Host "---------------valor: $value"   #<<<<<<<<<<<< eliminar estas lineas simplemente estan para debug
        $value = 'esto es una contrasena de prueba' #<<<<<<<<<<<< eliminar estas lineas simplemente estan para debug
        Write-Host "---------------valor: $value"   #<<<<<<<<<<<< eliminar estas lineas simplemenpoerte estan para debug
        if ($null -ne $value){
            #gh secret set -o $organization GHTOKENWORKFLOW -b $value <<<<< está comentado para no modificar el valor token de workflow
            gh secret set TESTWORKFLOW  -o $env:ORG --body "$value"
        }
     }
     'StorageAccountDelivery'{
        $metaPath = Join-Path $commonPath "SA-secrets-metadata.json"
        
        $token= getToken -matchPattern "^gh-SA-pool-\d{3}$" -metadataPath $metaPath
        $value= $token.value

        if ($null -ne $value){
            #gh secret set STORAGECONTEXT -b $value <<<<<<<< está comentado para no modificar el valor del token del deliver a Azure Storage Account
        }
        
        $value = 'esto es una contrasena de prueba'
        gh secret set TESTWORKFLOW --body "$value"

     }
     'ghPackagesDeliver'{
        $metaPath = Join-Path $commonPath "GHP-secrets-metadata.json"
        $token = getToken -matchPattern "^gh-ghp-pool-\d{3}$" -metadataPath $metaPath
        $value= $token.value
        if ($null -ne $value){
            #gh secret set -o $env:ORG GITHUBPACKAGESCONTEXT -b $value <<<<<<< está comentado para no modificar el valor del token del deliver a GHPackages
        }
     }
     'environment'{
        $environments = (gh api repos/investigacionPrac/InvPrac/environments) | ConvertFrom-Json
        $names = $environments.environments.Name
        foreach($envName in $names){
                $metaPath = Join-Path $commonPath "${envName}-secrets-metadata.json"
                $token= getToken -matchPattern "^${envName}-AUTHCONTEXT-pool-\d{3}$" -metadataPath $metaPath # <<<<<<<<<<<<< con este patron hacemos que solo obtenga el valor del token de cada entorno ya que si no estuviese 
                $value=$token.value
                Write-Host "---------------- token: $token"     #<<<<<<<<<<<< eliminar estas lineas simplemente estan para debug
                $secretName = (gh secret list -e $envName --json name | ConvertFrom-Json).name
                if ($null -eq $secretName){
                    $secretName = $envName +"_AUTHCONTEXT"
                }
                if (($envName -match '^test$')-or ($envName -match '^cliente\d{1}$') -and ($null -ne $value) ){                     #<<<<<<<<<<<< esta condición se eliminará posteriormente, está puesta solo para que no modifique los valores de los secretos para hacer deploy
                    Write-Host "---------------valor: $value"   #<<<<<<<<<<<< eliminar estas lineas simplemente estan para debug
                    gh secret set $secretName -e $envName -b $value
                }
            }
          }
    Default {
        Write-Error "No es una opción válida"
    }
}