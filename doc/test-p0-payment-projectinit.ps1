# P0: 付款条件库 + 项目立项 联调测试
$ErrorActionPreference = "Continue"
$base = "https://localhost:7154"
$doc = "D:\Net后端管理系统\soybean-admin-element-plus-main\doc"
$pass = 0
$fail = 0

function Test-Api {
    param([string]$Name, [scriptblock]$Block, [scriptblock]$Assert)
    try {
        $r = & $Block
        if (& $Assert $r) {
            Write-Host "[PASS] $Name"
            $script:pass++
        } else {
            Write-Host "[FAIL] $Name -> $r"
            $script:fail++
        }
    } catch {
        Write-Host "[FAIL] $Name -> $($_.Exception.Message)"
        $script:fail++
    }
}

$login = curl.exe -sk -X POST "$base/api/SysLogin/Login" -H "Content-Type: application/json" --data-binary "@$doc\test-login.json"
$token = ($login | ConvertFrom-Json).body.token
if (-not $token) { Write-Host "Login failed"; exit 1 }

Write-Host "=== P0 API Tests ==="

Test-Api "PaymentTerm ListEnabled" {
    curl.exe -sk "$base/api/PaymentTerm/ListEnabled" -H "Authorization: Bearer $token"
} { param($raw) ($raw | ConvertFrom-Json).code -eq 200 }

# find a contract id
$listRaw = curl.exe -sk "$base/api/Contract/PageList?PageNo=1&PageSize=5" -H "Authorization: Bearer $token"
$contractId = (($listRaw | ConvertFrom-Json).body.records | Select-Object -First 1).id

if ($contractId) {
    Test-Api "Contract ProjectInit" {
        curl.exe -sk -X POST "$base/api/Contract/ProjectInit/$contractId" -H "Authorization: Bearer $token"
    } { param($raw)
        $j = $raw | ConvertFrom-Json
        $j.code -eq 200 -and $null -ne $j.body.id -and $j.body.contractId -eq $contractId
    }

    $piRaw = curl.exe -sk -X POST "$base/api/Contract/ProjectInit/$contractId" -H "Authorization: Bearer $token"
    $projectId = (($piRaw | ConvertFrom-Json).body.id)

    if ($projectId) {
        Test-Api "ProjectInit Detail" {
            curl.exe -sk "$base/api/ProjectInit/Detail/$projectId" -H "Authorization: Bearer $token"
        } { param($raw) ($raw | ConvertFrom-Json).code -eq 200 }

        Test-Api "ProjectInit PageList" {
            curl.exe -sk "$base/api/ProjectInit/PageList?PageNo=1&PageSize=5" -H "Authorization: Bearer $token"
        } { param($raw) ($raw | ConvertFrom-Json).code -eq 200 }
    }
} else {
    Write-Host "[SKIP] No contract for ProjectInit test"
}

Write-Host "=== Result: pass=$pass fail=$fail ==="
if ($fail -gt 0) { exit 1 }
