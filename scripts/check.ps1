$ErrorActionPreference = 'Stop'
$workspace = Split-Path -Parent $PSScriptRoot
Push-Location $workspace
try {
    flutter analyze
    if ($LASTEXITCODE -ne 0) { throw 'Flutter analysis failed' }
    flutter test
    if ($LASTEXITCODE -ne 0) { throw 'Flutter tests failed' }
    # Flutter generates this machine-local file; Java properties need escaped drive colons.
    $propertiesFile = Join-Path $workspace 'android/local.properties'
    if (Test-Path -LiteralPath $propertiesFile) {
        $propertiesText = [IO.File]::ReadAllText($propertiesFile)
        $propertiesText = $propertiesText -replace '(?m)^((?:sdk\.dir|flutter\.sdk)=[A-Za-z]):', '$1\:'
        [IO.File]::WriteAllText($propertiesFile, $propertiesText, [Text.UTF8Encoding]::new($false))
    }
    Push-Location android
    try {
        & .\gradlew.bat :app:lintDebug --console=plain --init-script ..\scripts\android-lint.init.gradle
        if ($LASTEXITCODE -ne 0) { throw 'Android lint failed' }
    } finally { Pop-Location }
} finally { Pop-Location }
