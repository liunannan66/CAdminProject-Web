# 项目立项生成 SOW API 自动化测试
$ErrorActionPreference = "Stop"
$baseUrl = "https://localhost:7154"
$docDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "== Login ==" -ForegroundColor Cyan
$loginRaw = curl.exe -sk -X POST "$baseUrl/api/SysLogin/Login" -H "Content-Type: application/json" --data-binary "@$docDir\test-login.json"
$login = $loginRaw | ConvertFrom-Json
$token = $login.body.token
if (-not $token) { throw "Login failed: $loginRaw" }
Write-Host "Login OK"

Write-Host "== Load project init list ==" -ForegroundColor Cyan
$pageRaw = curl.exe -sk "$baseUrl/api/ProjectInit/PageList?pageNo=1&pageSize=5" -H "Authorization: Bearer $token"
if ($pageRaw -notmatch '"id":(\d+)') { throw "No project init records found: $pageRaw" }
$id = [int]$Matches[1]
Write-Host "Using project init id: $id"

Write-Host "== Generate SOW ==" -ForegroundColor Cyan
$outDir = Join-Path $docDir "output"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null
$outFile = Join-Path $outDir ("SOW_test_{0}_{1}.docx" -f $id, (Get-Date -Format "yyyyMMddHHmmss"))

curl.exe -sk -X POST "$baseUrl/api/ProjectInit/GenerateSow/$id" -H "Authorization: Bearer $token" -o $outFile
if (-not (Test-Path $outFile)) { throw "Download file not created" }
$size = (Get-Item $outFile).Length
if ($size -lt 10000) {
  $preview = Get-Content $outFile -Raw -ErrorAction SilentlyContinue
  throw "Download too small ($size bytes). Response may be JSON error: $preview"
}
Write-Host "Saved: $outFile ($size bytes)" -ForegroundColor Green

$zipCopy = Join-Path $env:TEMP ("sow_test_{0}.zip" -f ([guid]::NewGuid().ToString("N")))
Copy-Item $outFile $zipCopy -Force
$extract = Join-Path $env:TEMP ("sow_test_{0}" -f ([guid]::NewGuid().ToString("N")))
Expand-Archive -Path $zipCopy -DestinationPath $extract -Force
$xml = Get-Content (Join-Path $extract "word\document.xml") -Raw -Encoding UTF8
if ($xml -match '\{\{ContractName\}\}|\{\{ContractNo\}\}') {
  throw "Template placeholders were not replaced"
}
Write-Host "Placeholder check passed" -ForegroundColor Green
Write-Host "ALL TESTS PASSED" -ForegroundColor Green
