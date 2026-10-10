param(
    [int]$Port = 3001,
    [string]$PublicOrigin = '',
    [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'
$workspaceRoot = Split-Path -Parent $PSScriptRoot
$backendRoot = Join-Path $workspaceRoot 'backend'
$runtimeRoot = Join-Path $workspaceRoot '.runtime'

if ($PublicOrigin) {
    $publicUri = [Uri]$PublicOrigin
    if (-not $publicUri.IsAbsoluteUri -or $publicUri.Scheme -ne 'https' -or
        $publicUri.AbsolutePath -ne '/' -or $publicUri.Query -or $publicUri.Fragment) {
        throw 'PublicOrigin must be the HTTPS Conveyor origin, for example https://example.conveyor.cloud'
    }
    $PublicOrigin = $publicUri.GetLeftPart([UriPartial]::Authority)
} else {
    $PublicOrigin = "http://localhost:$Port"
}

if (-not $SkipBuild) {
    Push-Location $workspaceRoot
    try {
        & flutter build web --dart-define=API_BASE_URL=/api/v1 --no-web-resources-cdn
        if ($LASTEXITCODE -ne 0) { throw 'Flutter web build failed.' }
        Push-Location $backendRoot
        try {
            & npm run build
            if ($LASTEXITCODE -ne 0) { throw 'Backend build failed.' }
        } finally { Pop-Location }
    } finally { Pop-Location }
}

$listener = Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue
if ($listener) { throw "Port $Port is already in use. Stop the previous public server or choose another port." }

New-Item -ItemType Directory -Path $runtimeRoot -Force | Out-Null
$env:PORT = "$Port"
$env:NODE_ENV = 'production'
$env:SERVE_WEB = 'true'
$env:PUBLIC_ORIGIN = $PublicOrigin
$env:LOG_LEVEL = 'info'
$serverProcess = Start-Process -FilePath (Get-Command node).Source -ArgumentList 'dist/server.js' `
    -WorkingDirectory $backendRoot -WindowStyle Hidden -PassThru `
    -RedirectStandardOutput (Join-Path $runtimeRoot 'public-server.log') `
    -RedirectStandardError (Join-Path $runtimeRoot 'public-server.error.log')

try {
    $ready = $false
    for ($attempt = 0; $attempt -lt 30; $attempt++) {
        if ($serverProcess.HasExited) { throw 'Server failed to start; check .runtime/public-server.error.log' }
        try {
            $health = Invoke-RestMethod -Uri "http://localhost:$Port/health/ready" -TimeoutSec 2
            if ($health.success) { $ready = $true; break }
        } catch { Start-Sleep -Milliseconds 500 }
    }
    if (-not $ready) { throw 'Server did not become ready; check .runtime/public-server.error.log' }
    @{ processId = $serverProcess.Id; port = $Port; publicOrigin = $PublicOrigin } |
        ConvertTo-Json | Set-Content -LiteralPath (Join-Path $runtimeRoot 'public-server.json') -Encoding UTF8
    Write-Host "SignVoice UI + API: http://localhost:$Port"
    Write-Host "Allowed public origin: $PublicOrigin"
    Write-Host "Conveyor command: .\.tools\conveyor\conveyorcli.exe -p ${Port}i"
} catch {
    if (-not $serverProcess.HasExited) { Stop-Process -Id $serverProcess.Id }
    throw
}
