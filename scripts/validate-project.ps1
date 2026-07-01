# Windows에서 실행 가능한 프로젝트 구조 검증 스크립트
# Mac/Xcode 없이 파일 누락·pbxproj 불일치를 확인합니다.

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$pbxproj = Join-Path $root "BeanDiary.xcodeproj\project.pbxproj"

Write-Host "BeanDiary 프로젝트 검증" -ForegroundColor Cyan
Write-Host "Root: $root`n"

if (-not (Test-Path $pbxproj)) {
    Write-Error "project.pbxproj not found"
}

$pbxContent = Get-Content $pbxproj -Raw
$swiftInPbx = [regex]::Matches($pbxContent, 'path = ([A-Za-z0-9_]+\.swift)') |
    ForEach-Object { $_.Groups[1].Value } |
    Sort-Object -Unique

$swiftOnDisk = Get-ChildItem -Path (Join-Path $root "BeanDiary") -Recurse -Filter "*.swift" |
    ForEach-Object { $_.Name } |
    Sort-Object -Unique

Write-Host "=== Swift 파일 (디스크: $($swiftOnDisk.Count), pbxproj: $($swiftInPbx.Count)) ==="

$missingInPbx = $swiftOnDisk | Where-Object { $_ -notin $swiftInPbx }
$missingOnDisk = $swiftInPbx | Where-Object { $_ -notin $swiftOnDisk }

if ($missingInPbx.Count -gt 0) {
    Write-Host "pbxproj에 없는 파일:" -ForegroundColor Red
    $missingInPbx | ForEach-Object { Write-Host "  - $_" }
}

if ($missingOnDisk.Count -gt 0) {
    Write-Host "디스크에 없는 pbxproj 참조:" -ForegroundColor Red
    $missingOnDisk | ForEach-Object { Write-Host "  - $_" }
}

$requiredFiles = @(
    "BeanDiary\BeanDiaryApp.swift",
    "BeanDiary\Info.plist",
    "BeanDiary\Assets.xcassets\Contents.json",
    "BeanDiary.xcodeproj\xcshareddata\xcschemes\BeanDiary.xcscheme"
) | ForEach-Object { Join-Path $root $_ }

Write-Host "`n=== 필수 파일 ==="
foreach ($file in $requiredFiles) {
    $rel = $file.Replace($root + "\", "")
    if (Test-Path $file) {
        Write-Host "[OK] $rel" -ForegroundColor Green
    } else {
        Write-Host "[MISSING] $rel" -ForegroundColor Red
    }
}

# 간단한 Swift 문법 힌트 검사
Write-Host "`n=== Swift 기본 검사 ==="
$issues = @()
Get-ChildItem -Path (Join-Path $root "BeanDiary") -Recurse -Filter "*.swift" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $rel = $_.FullName.Replace($root + "\", "")

    if ($content -notmatch "import ") {
        $issues += "$rel : import 문 없음"
    }
    $open = ([regex]::Matches($content, '\{')).Count
    $close = ([regex]::Matches($content, '\}')).Count
    if ($open -ne $close) {
        $issues += "$rel : 중괄호 불일치 ({=$open, }=$close)"
    }
}

if ($issues.Count -eq 0) {
    Write-Host "기본 검사 통과" -ForegroundColor Green
} else {
    Write-Host "잠재 이슈:" -ForegroundColor Yellow
    $issues | ForEach-Object { Write-Host "  $_" }
}

$failed = ($missingInPbx.Count -gt 0) -or ($missingOnDisk.Count -gt 0)
if ($failed) {
    Write-Host "`n검증 실패" -ForegroundColor Red
    exit 1
}

Write-Host "`n검증 성공 (Mac 빌드는 GitHub Actions 또는 Xcode 필요)" -ForegroundColor Green
exit 0
