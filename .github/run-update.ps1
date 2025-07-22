param (
    [string]$TemplateRepoUrl,
    [string]$LocalRepoPath = $env:GITHUB_WORKSPACE
)

$clonePath = Join-Path $env:TEMP "template-repo"

Import-Module ./UpdateFiles.psm1

Write-Host "Clonando repositorio plantilla..."
Get-TemplateFiles -repoUrl $TemplateRepoUrl -clonePath $clonePath

Write-Host "Comparando y actualizando archivos..."
Compare-And-UpdateFiles -templatePath $clonePath -targetPath $LocalRepoPath