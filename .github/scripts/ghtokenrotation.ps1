param (
        [String] $keyvaultname,
        [String] $matchPattern,
        [String] $action,
        [String] $metadataPath
    )
#     $tokenData = az keyvault secret list --vault-name $keyvaultname  | ConvertFrom-Json
#     $data= Get-Content $metadataPath | ConvertFrom-Json
#     $tokens = $tokenData.name -match $matchPattern

#     $expiring = [datetime]::Parse($data.expires).ToUniversalTime()
#     $today = Get-Date
#     $diff = ($expiring - $today).Days

#     if ($tokens -cnotmatch 'False'){
#         if ($diff -le 7) {
#             Write-Host "Hay que rotar (faltan $diff días)"
#             $nextToken = $tokenData | Where-Object {$_.name -match $matchPattern}| Sort-Object { [datetime]::Parse($_.attributes.expires)} | Select-Object -First 1
#             $newexpiring = [datetime]::Parse($nextToken.attributes.expires).ToUniversalTime()
#             $tokenName = $nextToken.Name
#             if ($newexpiring -gt $expiring){
#                 Write-Host $newexpiring
#                 $data.expires = $newexpiring.ToString("yyyy-MM-ddTHH:mm:ssZ")
#                 $data.token_name = $tokenName
#                 $data | ConvertTo-Json -Depth 2 | Set-Content $metadataPath -Encoding UTF8
#                 Write-Host "actualizado el token a $tokenName (expira el $($newexpiring.ToString("dd/MM/yyyy HH:mm:ss")))"
#                 $value = (az keyvault secret show --name $nextToken.name --vault $keyvaultname | ConvertFrom-Json).value
#             }else {
#                 Write-Host "La fecha a la que se va a cambiar es anterior o igual a la que hay actualmente por lo que se eliminará el token más antiguo"
#             }
#             az keyvault secret delete --vault-name $keyvaultname --name $tokenName
#         } else {
#             Write-Host "Por el momento no hay que rotar (faltan $diff días)"
#         }           
#     } else{
#         Write-Host "No quedan tokens en el pool tienes que crear mas"
#     }

function GetHeaders {
    param (
        [string] $token,
        [string] $accept = "application/vnd.github+json",
        [string] $apiVersion = "2022-11-28",
        [string] $api_url = $ENV:GITHUB_API_URL,
        [string] $repository = $ENV:GITHUB_REPOSITORY
    )
    $headers = @{
        "Accept" = $accept
        "X-GitHub-Api-Version" = $apiVersion
    }
    if (![string]::IsNullOrEmpty($token)) {
        $accessToken = GetAccessToken -token $token -api_url $api_url -repository $repository -permissions @{"contents"="read";"metadata"="read";"actions"="read"}
        $headers["Authorization"] = "token $accessToken"
    }
    return $headers
}

function GetGitHubEnvironments() {
    $headers = GetHeaders -token $env:GITHUB_TOKEN
    $url = "$($ENV:GITHUB_API_URL)/repos/$($ENV:GITHUB_REPOSITORY)/environments"
    try {
        Write-Host "Requesting environments from GitHub"
        $ghEnvironments = @(((InvokeWebRequest -Headers $headers -Uri $url).Content | ConvertFrom-Json).environments)
    }
    catch {
        $ghEnvironments = @()
        Write-Host "Failed to get environments from GitHub API - Environments are not supported in this repository"
    }
    $ghEnvironments
}

$ghEnvironments = @(GetGitHubEnvironments)

$environments = @($ghEnvironments | ForEach-Object { $_.name }) + @($settings.environments) | Select-Object -unique | Where-Object { $settings.excludeEnvironments -notcontains $_.Split(' ')[0] -and $_.Split(' ')[0] -like $getEnvironments.Split(' ')[0] }


switch ($action) {
    'Workflow' { 
        #$value
        $matchPattern
     }
     'StorageAccountDelivery'{
        $matchPattern
     }
     'ghPackagesDeliver'{
        $matchPattern
     }
     'environment'{
        foreach($env in $environments){
            Write-Host $env.EnvironmentName
        }
     }
    Default {
        Write-Error "No es una opción válida"
    }
}