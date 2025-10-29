# ==========================================================
# Azure Cloud Migration Project – Language Folder Generator
# ==========================================================

$root = "$PSScriptRoot\scripts"
$folders = @("powershell", "bash", "azcli", "bicep", "python", "docker")

# Create folder structure
foreach ($f in $folders) {
    $path = Join-Path $root $f
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
        Write-Host "Created folder: $path"
    }
}

# Create sample files for language detection
Set-Content "$root\powershell\setup.ps1" 'Write-Output "PowerShell sample"'
Set-Content "$root\bash\init.sh" '#!/bin/bash
echo "Bash sample"'
Set-Content "$root\azcli\commands.azcli" 'az group list'
Set-Content "$root\bicep\main.bicep" 'resource rg "Microsoft.Resources/resourceGroups@2023-07-01" = {
  name: "demo-rg"
  location: "eastus"
}'
Set-Content "$root\python\app.py" 'print("Python sample")'
Set-Content "$root\docker\Dockerfile" 'FROM alpine:latest
CMD ["echo", "Docker sample"]'

Write-Host "`n All language sample files created under /scripts."
