param(
    [string]$templateUrl = "",
    [string]$branch = "main",
    [string]$token = "",
    [bool]$downloadLatest = $true,
    [string]$update = "Y"
)
try{
function Clone-RepoWithGH {
    param(
        [string]$repoUrl,
        [string]$branch,
        [string]$targetFolder
    )
    Write-Output "Clonando repo privado desde $repoUrl, rama $branch en $targetFolder"

    # Borra carpeta destino si existe
    if (Test-Path $targetFolder) {
        Remove-Item -Path $targetFolder -Recurse -Force
    }

    # Extraemos org/repo del URL
    if ($repoUrl -match "github.com[/:](.+)/(.+?)(\.git)?$") {
        $org = $Matches[1]
        $repo = $Matches[2]
    } else {
        Write-Error "URL inválida: $repoUrl"
        exit 1
    }

    # Ejecuta git clone con la rama indicada y solo profundidad 1
    $cloneUrl = "https://github.com/$org/$repo.git"
    $args = @("repo", "clone", $cloneUrl, $targetFolder, "--", "--branch", $branch, "--depth", "1")

    $process = Start-Process -FilePath "gh" -ArgumentList $args -NoNewWindow -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        Write-Error "Error clonando el repositorio con gh."
        exit 1
    }
}




# Busca carpeta con app.json para saber destino
$basePath = Get-Location
$appJsonPath = Get-ChildItem -Path $basePath -Recurse -Filter 'app.json' -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $appJsonPath) {
    Write-Error "No se encontró app.json. No se puede determinar destino."
    exit 1
}
$destinationRoot = Split-Path -Path $appJsonPath.FullName -Parent

if ($downloadLatest -and $templateUrl) {
    $tempTemplateFolder = Join-Path -Path $env:TEMP -ChildPath "template-clone"
    Clone-RepoWithGH -repoUrl $templateUrl -branch $branch -targetFolder $tempTemplateFolder
} else {
    Write-Error "No se especificó templateUrl o downloadLatest está en false."
    exit 1
}

$filesToBring = @('.alpackages/','settings.json','launch.json', 'helloworld.txt')

Write-Output "Origen plantilla: $tempTemplateFolder"
Write-Output "Destino proyecto: $destinationRoot"

foreach ($file in $filesToBring) {
    $source = Join-Path -Path (Join-Path $tempTemplateFolder "template") -ChildPath $file
    $destination = Join-Path -Path $destinationRoot -ChildPath $file

    if (Test-Path -Path $source) {
        if (Test-Path -Path $source -PathType Container) {
            if (Test-Path -Path $destination) {
                Remove-Item -Path $destination -Recurse -Force
            }
            Copy-Item -Path $source -Destination $destination -Recurse
            Write-Output "Directorio actualizado: $file"
        } else {
            Copy-Item -Path $source -Destination $destination -Force
            Write-Output "Archivo actualizado: $file"
        }
    } else {
        Write-Output "El archivo $source no existe."
    }
}
}catch {
    Write-Error "Error al actualizar archivos: $_"
    exit 1
}
Write-Output "Contenido del repositorio clonado:"
Get-ChildItem -Path $tempTemplateFolder -Recurse | ForEach-Object { $_.FullName }
Write-Output "Archivos actualizados correctamente."
