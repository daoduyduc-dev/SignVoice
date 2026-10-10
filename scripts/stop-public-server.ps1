$ErrorActionPreference = 'Stop'
$workspaceRoot = Split-Path -Parent $PSScriptRoot
$stateFile = Join-Path $workspaceRoot '.runtime/public-server.json'
if (-not (Test-Path -LiteralPath $stateFile)) { Write-Host 'No public server state found.'; return }
$serverState = Get-Content -LiteralPath $stateFile -Raw | ConvertFrom-Json
$serverProcess = Get-CimInstance Win32_Process -Filter "ProcessId = $($serverState.processId)" -ErrorAction SilentlyContinue
if ($serverProcess) {
    $listener = Get-NetTCPConnection -State Listen -LocalPort $serverState.port -ErrorAction SilentlyContinue
    if ($serverProcess.Name -ne 'node.exe' -or $serverProcess.CommandLine -notmatch 'dist/server\.js' -or
        -not ($listener | Where-Object { $_.OwningProcess -eq $serverState.processId })) {
        throw 'Saved process does not match the SignVoice public server; it was not stopped.'
    }
    Stop-Process -Id $serverState.processId
}
Remove-Item -LiteralPath $stateFile
Write-Host 'SignVoice public server stopped.'
