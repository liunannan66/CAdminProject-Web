# 合同保存 API 自动化测试
$ErrorActionPreference = "Continue"
$baseUrl = "https://localhost:7154"
$docDir = "D:\Net后端管理系统\soybean-admin-element-plus-main\doc"
$passed = 0
$failed = 0

function Test-Case {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Url,
        [string]$BodyFile,
        [int[]]$ExpectCodes,
        [string]$ExpectMessageContains = ""
    )
    $args = @("-sk", "-X", $Method, "$baseUrl$Url", "-H", "Authorization: Bearer $script:token", "-H", "Content-Type: application/json")
    if ($BodyFile) { $args += @("--data-binary", "@$BodyFile") }
    $raw = & curl.exe @args
    try {
        $json = $raw | ConvertFrom-Json
        $ok = ($ExpectCodes -contains $json.code)
        if ($ExpectMessageContains -and $json.message -notlike "*$ExpectMessageContains*") { $ok = $false }
        if ($ok) {
            Write-Host "[PASS] $Name -> code=$($json.code) message=$($json.message)"
            $script:passed++
        } else {
            Write-Host "[FAIL] $Name -> code=$($json.code) message=$($json.message) body=$($json.body)"
            $script:failed++
        }
    } catch {
        Write-Host "[FAIL] $Name -> invalid json: $raw"
        $script:failed++
    }
}

$loginRaw = curl.exe -sk -X POST "$baseUrl/api/SysLogin/Login" -H "Content-Type: application/json" --data-binary "@$docDir\test-login.json"
$token = ($loginRaw | ConvertFrom-Json).body.token
if (-not $token) { Write-Host "Login failed: $loginRaw"; exit 1 }

Write-Host "=== Contract Save API Tests ==="

Test-Case "Add success" "POST" "/api/Contract/Add" "$docDir\test-contract-add-unique.json" @(200)
Test-Case "Add duplicate no" "POST" "/api/Contract/Add" "$docDir\test-contract-add-unique.json" @(207) "合同编号已存在"
Test-Case "Add null paymentLines" "POST" "/api/Contract/Add" "$docDir\test-contract-null-payment.json" @(207) "收款条件"
Test-Case "Add quoteAmount null" "POST" "/api/Contract/Add" "$docDir\test-contract-quote-null.json" @(207) "产品报价"
Test-Case "Add paymentRatio null" "POST" "/api/Contract/Add" "$docDir\test-contract-ratio-null.json" @(207) "支付比例"
Test-Case "Add null line item" "POST" "/api/Contract/Add" "$docDir\test-contract-null-line-item.json" @(207) "收款条件"
Test-Case "Add bad attachment" "POST" "/api/Contract/Add" "$docDir\test-contract-add-bad-att.json" @(207) "附件"
Test-Case "Update success" "POST" "/api/Contract/Update" "$docDir\test-contract-update-id7.json" @(200)
Test-Case "Update no id" "POST" "/api/Contract/Update" "$docDir\test-contract-update-no-id.json" @(207) "Id"
Test-Case "Update null id" "POST" "/api/Contract/Update" "$docDir\test-contract-update-null-id.json" @(207) "Id"

Write-Host "=== Result: $passed passed, $failed failed ==="
if ($failed -gt 0) { exit 1 }
