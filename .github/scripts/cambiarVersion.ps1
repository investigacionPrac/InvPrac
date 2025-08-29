param(
    [int]$versionBC,
    [string]$versionTCN,
    [Boolean]$OnPrem,
    [Boolean]$ESP
)

if (-not ($versionBC.GetType().Name -eq 'Int32')) {
    Write-Error "La version de BC no es un entero"
    exit 1
}
if (-not ($versionTCN -match '^v\d{1}$')) {
    Write-Error "La version de Tecon está incorrecta, por favor, el formato es v[1|2]"
    exit 1
}


$directorios = Get-ChildItem -Directory

$application = "$versionBC.0.0.0"
$runtimeInt = $versionBC - 11

$runtime = "$runtimeInt.0"

$versionTCNInt = ($versionTCN -split 'v')[1]

foreach ($dir in $directorios) {
    $appJsonPath = Join-Path $dir 'app.json'
    
    if (Test-Path $appJsonPath) {
        $appJsonData = Get-Content $appJsonPath -Raw | ConvertFrom-Json

        foreach ($dependencie in $appJsonData.dependencies) {
            $versionDepInt = ($dependencie.version -split '\.')[1]
            if (($versionTCN -like 'v1') -and ($dependencie.version -match '^2\.\d{6}\.\d+\.\d+$') ) {
                #convertimos la version de la dependencia de v2 a v1
                Write-Host "queremos estar en v1 y la version de la dependencia es v2 $($dependencie.version)"
                $versionDate = ([DateTime]::ParseExact($versionDepInt, 'yyMMdd', $null)).ToString('yyyyMMdd')
                Write-Host "nueva fecha $versionDate"
            }
            elseif (($versionTCN -like 'v2') -and ($dependencie.version -match '^1\.\d{8}\.\d+\.\d+$')) {
                #convertimos la version de la dependencia de v1 a v2
                Write-Host "queremos estar en v2 y la version de la dependencia es v1 $($dependencie.version)"
                $versionDate = ([DateTime]::ParseExact($versionDepInt, 'yyyyMMdd', $null)).ToString('yyMMdd')
                Write-Host "nueva fecha $versionDate"
            }
            else {
                Write-Host "La version a la que se quiere hacer y la de la dependencia es la misma $($dependencie.version) o el segundo dígito es un número distinto a lo esperado"
                $versionDate = $versionDepInt
            }
            
            $dependencie.version = "$versionTCNInt.$versionDate.0.0"
            Write-Host "Nueva version $($dependencie.version)"

        }
        $appJsonData.application = $application
        $appJsonData.runtime = $runtime
        $versionAppInt = ($appJsonData.version -split '\.')[1]
        if (($versionTCN -like 'v1') -and ($appJsonData.version -match '^2\.\d{6}\.\d+\.\d+$') ) {
            #convertimos la version de la dependencia de v2 a v1
            Write-Host "queremos estar en v1 y la version de la dependencia es v2 $($appJsonData.version)"
            $versionDate = ([DateTime]::ParseExact($versionAppInt, 'yyMMdd', $null)).ToString('yyyyMMdd')
            Write-Host "nueva fecha $versionDate"
        }
        elseif (($versionTCN -like 'v2') -and ($appJsonData.version -match '^1\.\d{8}\.\d+\.\d+$')) {
            #convertimos la version de la dependencia de v1 a v2
            Write-Host "queremos estar en v2 y la version de la dependencia es v1 $($appJsonData.version)"
            $versionDate = ([DateTime]::ParseExact($versionAppInt, 'yyyyMMdd', $null)).ToString('yyMMdd')
            Write-Host "nueva fecha $versionDate"
        }
        else {
            Write-Host "La version a la que se quiere hacer y la de la app es la misma $($appJsonData.version) o el segundo dígito es un número distinto a lo esperado"
            $versionDate = $versionAppInt
        }
            
        $appJsonData.version = "$versionTCNInt.$versionDate.0.0"

        if (-not ($appJsonData.preprocessorSymbols)) {
            Write-Host "No existe la propiedad preprocessorSymbols"
            $appJsonData | Add-Member -NotePropertyName preprocessorSymbols -NotePropertyValue @()
        }
        $appJsonData.preprocessorSymbols = @($appJsonData.preprocessorSymbols)

        $mayorIgualStr = "MayorIgual$($versionBC)0"
        $pattern = "^MayorIgual\d{3}$"

        if (-not($appJsonData.preprocessorSymbols.Contains($mayorIgualStr))) {
            $appJsonData.preprocessorSymbols = @($appJsonData.preprocessorSymbols | Where-Object { $_ -notmatch $pattern })
            $appJsonData.preprocessorSymbols += $mayorIgualStr
        }
        if (-not($appJsonData.preprocessorSymbols.Contains($versionTCN))) {
            $appJsonData.preprocessorSymbols = @($appJsonData.preprocessorSymbols | Where-Object { $_ -notmatch '^v\d{1}$' })
            $appJsonData.preprocessorSymbols += $versionTCN
        }
        
    
        if ($OnPrem -and (-not($appJsonData.preprocessorSymbols.Contains("OnPrem")))) {
            $appJsonData.preprocessorSymbols += "OnPrem"
        }
        elseif (-not ($OnPrem) -and ($appJsonData.preprocessorSymbols.Contains("OnPrem"))) {
            $appJsonData.preprocessorSymbols = @($appJsonData.preprocessorSymbols | Where-Object { $_ -notlike "OnPrem" })
        }
        if ($ESP -and (-not($appJsonData.preprocessorSymbols.Contains("ESP")))) {
            $appJsonData.preprocessorSymbols += "ESP"
        }
        elseif (-not ($ESP) -and ($appJsonData.preprocessorSymbols.Contains("ESP"))) {
            $appJsonData.preprocessorSymbols = @($appJsonData.preprocessorSymbols | Where-Object { $_ -notlike "ESP" })
        }

        $resourceExposurePolicy = @{
            "allowDebugging"            = $false
            "allowDownloadingSource"    = $false
            "includeSourceInSymbolFile" = $false
        }
        if (-not ($appJsonData.resourceExposurePolicy)) {
            Write-Host "No existe la propiedad resourceExposurePolicy"
            $appJsonData | Add-Member -NotePropertyName resourceExposurePolicy -NotePropertyValue $resourceExposurePolicy
        }
        if (($versionBC -ge 21) -and (-not ($appJsonData.resourceExposurePolicy.PSObject.Properties.Name.Contains('applyToDevExtension')))) {
            $appJsonData.resourceExposurePolicy | Add-Member -NotePropertyName "applyToDevExtension" -NotePropertyValue $false
        }
    
        if ($versionBC -eq 19) {
            $appJsonData.resourceExposurePolicy = $appJsonData.resourceExposurePolicy | Select-Object -Property * -ExcludeProperty applyToDevExtension
        }
        $appJsonData | ConvertTo-Json -Depth 10 | Set-Content $appJsonPath

        $vscodePath = Join-Path $dir '.vscode'
        $settingsPath = Join-Path $vscodePath 'settings.json'
        if (Test-Path $settingsPath) {
            $vscodeData = Get-Content $settingsPath -Raw | ConvertFrom-Json

            $properties = $vscodeData.PSObject.Properties.Name

            $primeroPuntoStr = '.alpackageCachePath'
            $primeroALStr = 'al.packageCachePath'
            if (-not ($properties.Contains($primeroPuntoStr)) -and ($properties.Contains($primeroALStr))) {
                $vscodeData.$primeroALStr = @("$versionTCN/bc$($versionBC)0/.alpackages")
            }
            elseif ( ($properties.Contains($primeroPuntoStr)) -and (-not($properties.Contains($primeroALStr)))) {
                $vscodeData.$primeroPuntoStr = @("$versionTCN/bc$($versionBC)0/.alpackages")
            }
            elseif (-not($properties.Contains($primeroPuntoStr)) -and (-not($properties.Contains($primeroALStr)))) {
                $vscodeData | Add-Member -NotePropertyName $primeroALStr -NotePropertyValue @("$versionTCN/bc$($versionBC)0/.alpackages")
            }
        }
        $vscodeData | ConvertTo-Json -Depth 10 | Set-Content $settingsPath 
    }
}