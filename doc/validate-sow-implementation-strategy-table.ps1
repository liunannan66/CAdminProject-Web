# 校验 SOW 模板中 4.1 实施策略表结构
$ErrorActionPreference = "Stop"

$templateCandidates = @(
  "D:\Net后端管理系统\MalusAdmin-master\MalusApi\MalusAdmin.WebApi\Templates\SOW\实施工作说明书(SOW)_Template_V1.2.docx",
  (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "..\MalusAdmin-master\MalusApi\MalusAdmin.WebApi\Templates\SOW\实施工作说明书(SOW)_Template_V1.2.docx")
)

$templatePath = $templateCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $templatePath) {
  throw "未找到 SOW 模板，请放置于 MalusAdmin.WebApi/Templates/SOW/实施工作说明书(SOW)_Template_V1.2.docx"
}

Write-Host "Template: $templatePath" -ForegroundColor Cyan

$zipCopy = Join-Path $env:TEMP ("sow_tpl_{0}.zip" -f ([guid]::NewGuid().ToString("N")))
$extract = Join-Path $env:TEMP ("sow_tpl_{0}" -f ([guid]::NewGuid().ToString("N")))
Copy-Item $templatePath $zipCopy -Force
Expand-Archive -Path $zipCopy -DestinationPath $extract -Force

$xmlPath = Join-Path $extract "word\document.xml"
$xml = Get-Content $xmlPath -Raw -Encoding UTF8

$requiredKeywords = @(
  "业务板块", "推广策略", "实施地点", "序号",
  "下属分支机构", "分期策略", "试点", "推广责任方", "集中", "异地分散"
)
$forbiddenKeywords = @("功能组", "功能说明", "上线支持内容")

foreach ($kw in $requiredKeywords) {
  if ($xml -notmatch [regex]::Escape($kw)) {
    throw "模板缺少关键字: $kw"
  }
}
Write-Host "Required keywords: OK" -ForegroundColor Green

# 粗检：实施策略表附近应出现 12 列相关文案（无法替代 OpenXML 精确数格，生成时后端会再校验）
if ($xml -match "tbl") {
  Write-Host "Table elements found: OK" -ForegroundColor Green
}

Write-Host ""
Write-Host "模板关键字检查通过。" -ForegroundColor Green
Write-Host "注意: 数据模板行须有 12 个独立单元格，保存模板后请执行 test-project-init-sow.ps1 做生成验证。" -ForegroundColor Yellow
