$filesToBring = @('.alpackages/','settings.json','launch.json')

function Update-Files {
    foreach ($file in $filesToBring) {
        $source = Join-Path -Path 'template' -ChildPath $file
        $destination = Join-Path -Path 'InvPrac' -ChildPath $file

        if (Test-Path -Path $source) {
            if (Test-Path -Path $source -PathType Container) {
                if (Test-Path -Path $destination) {
                    Remove-Item -Path $destination -Recurse -Force
                }
                Copy-Item -Path $source -Destination $destination -Recurse
            } else {
                Copy-Item -Path $source -Destination $destination
            }
        } else {
            Write-Output "File $source does not exist."
        }
    }
}

# Call the function and print success message
Update-Files
Write-Output "Files updated successfully."