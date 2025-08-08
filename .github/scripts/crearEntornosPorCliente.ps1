    param (
        [String] $repoPath
    )

    $data = Get-Content '.\.github\metadata\clientes-de-testing.json' | ConvertFrom-Json

    $appRepo = Split-Path $repoPath -Leaf

    $environments = (gh api repos/$env:OWNER/$appRepo/environments) | ConvertFrom-Json
    $names = $environments.environments.Name
    Write-Host "Entornos en el repo: $names"
    foreach ($client in $data.PSObject.Properties.Name){
        Write-Host "Evaluando al cliente $client"
        if ($data.$client.Contains($appRepo)){
            $clientes += $client + " "
            if ($names.Contains($client)){
                Write-Warning "El entorno $client ya existe por lo que no se creará ningún entorno con ese nombre"
            } else{
                gh api --method PUT -H "Accept: application/vnd.github+json" repos/$env:OWNER/$appRepo/environments/$client
                Write-Host "Entorno $client creado correctamente"
            }
            
        }
    }

    Write-Host "Los clientes que tienen la app buscada son: $clientes"
