# Version suffix - use preview suffix for CI builds that are not tagged (i.e. unofficial)
$VersionSuffix = ""
if ($env:APPVEYOR -eq "True" -and $env:APPVEYOR_REPO_TAG -eq "false") {
    $VersionSuffix = "preview-" + $env:APPVEYOR_BUILD_NUMBER.PadLeft(4, '0')
} Pause

# Target folder for build artifacts (e.g. nugets)
$ArtifactsPath = "$(pwd)" + "\artifacts"

function install-swagger-ui {
    Push-Location "C:\Users\jshakely\source\repos\Swashbuckle.AspNetCore\src\Swashbuckle.AspNetCore.SwaggerUI"
    npm install
    Pop-Location
    Pause
}

function install-redoc {
    Push-Location "C:\Users\jshakely\source\repos\Swashbuckle.AspNetCore\src\Swashbuckle.AspNetCore.ReDoc"
    npm install
    Pop-Location
    Pause
}

function dotnet-build {
    if ($VersionSuffix.Length -gt 0) {
        dotnet build -c Release --version-suffix $VersionSuffix Pause
    }
    else {
        dotnet build -c Release Pause
    }
}

function dotnet-pack {
    Get-ChildItem -Path src/** -Directory | ForEach-Object {
        if ($VersionSuffix.Length -gt 0) {
            dotnet pack $_ -c Release --no-build -o $ArtifactsPath --version-suffix $VersionSuffix Pause
        }
        else {
            dotnet pack $_ -c Release --no-build -o $ArtifactsPath Pause
        }
    }
}

@( "install-swagger-ui", "install-redoc", "dotnet-build", "dotnet-pack" ) | ForEach-Object {
    echo ""
    echo "***** $_ *****"
    echo ""

    # Invoke function and exit on error
    &$_
    if ($LastExitCode -ne 0) { Pause } # Pause was -> Exit $LastExitCode
}