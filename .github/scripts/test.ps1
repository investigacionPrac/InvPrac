foreach ($envName in $names){
        gh workflow run "test.yaml" --ref main --field entorno=$envName
    }
