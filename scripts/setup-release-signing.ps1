$ErrorActionPreference = 'Stop'
$workspace = Split-Path -Parent $PSScriptRoot
$androidDirectory = Join-Path $workspace 'android'
$propertiesFile = Join-Path $androidDirectory 'key.properties'
$keystoreFile = Join-Path $androidDirectory 'release-keystore.jks'

# Never replace an existing signing identity or its credentials.
if ((Test-Path -LiteralPath $propertiesFile) -or (Test-Path -LiteralPath $keystoreFile)) {
    throw 'Signing files already exist. Keep the existing key and configure android/key.properties manually.'
}
$keytool = (Get-Command keytool -ErrorAction Stop).Source
$passwordBytes = New-Object byte[] 32
$random = [Security.Cryptography.RandomNumberGenerator]::Create()
try { $random.GetBytes($passwordBytes) } finally { $random.Dispose() }
$password = [BitConverter]::ToString($passwordBytes).Replace('-', '')

# Pass the password through an environment variable, not command-line arguments.
$previousPassword = $env:BREAST_MILK_SIGNING_PASSWORD
try {
    $env:BREAST_MILK_SIGNING_PASSWORD = $password
    & $keytool -genkeypair -noprompt -storetype JKS -keystore $keystoreFile `
        -alias release -keyalg RSA -keysize 2048 -validity 10000 `
        -dname 'CN=Breast Milk Release' `
        -storepass:env BREAST_MILK_SIGNING_PASSWORD -keypass:env BREAST_MILK_SIGNING_PASSWORD
    if ($LASTEXITCODE -ne 0) { throw 'Release keystore generation failed.' }
    $properties = "storeFile=release-keystore.jks`nstorePassword=$password`nkeyAlias=release`nkeyPassword=$password`n"
    [IO.File]::WriteAllText($propertiesFile, $properties, [Text.UTF8Encoding]::new($false))
} finally {
    $env:BREAST_MILK_SIGNING_PASSWORD = $previousPassword
}
Write-Host 'Release signing configured. Back up android/release-keystore.jks and android/key.properties securely; use the same key for future updates.'
