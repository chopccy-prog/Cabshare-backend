# update-schema.ps1
# Minimal snapshot-only workflow using `supabase db dump`.
# Usage: powershell -ExecutionPolicy Bypass -File .\update-schema.ps1

$ErrorActionPreference = "Stop"

# 1) Ensure supabase folder exists
if (-not (Test-Path "supabase")) {
    New-Item -ItemType Directory -Path "supabase" | Out-Null
}

# 2) Dump live schema to supabase\schema.sql (UTF-8, overwrite)
Write-Host "Dumping live schema (public)…"
$schemaPath = "supabase\schema.sql"
# Use Out-File to avoid redirection quirks & ensure UTF-8
supabase db dump --schema public | Out-File -FilePath $schemaPath -Encoding utf8 -Force

# 3) Stage & commit only if there are changes
git add $schemaPath | Out-Null
$status = git status --porcelain
if ($status) {
    $msg = "chore: update schema.sql from Supabase (dump)"
    git commit -m $msg | Out-Null
    git push
    Write-Host "Committed & pushed: $schemaPath"
} else {
    Write-Host "No changes detected in $schemaPath"
}

Write-Host "Done ✅"
