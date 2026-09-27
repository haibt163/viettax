# Universal Project Review ZIP
#
# Purpose:
#   Package the project containing this script into a review ZIP for an AI/code
#   engineer. It includes hidden folders such as .claude, .omp, .grok, .github,
#   .vercel, etc. It excludes common build/runtime bloat and obvious secrets.
#
# Usage:
#   1. Put this file in the project root.
#   2. Double-click it, or run it from PowerShell.
#
# The script does NOT assume Next.js, Vite, TanStack, Flutter, etc.
# It is intended to work with arbitrary project layouts.

$ErrorActionPreference = 'Stop'

# -----------------------------
# Execution policy note
# -----------------------------
# Windows blocks unsigned .ps1 scripts by default (this is a Windows security
# default, not a bug in this script). If running this script directly failed
# with an execution-policy error, you don't need to bypass it every time.
# One-time fix, run once in PowerShell as your normal user (no admin needed):
#   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
# This allows locally-created/downloaded scripts you've unblocked to run,
# while still blocking unsigned scripts from the internet by default. After
# that one-time change, double-clicking or running this script normally will
# work without -ExecutionPolicy Bypass each time.

# -----------------------------
# Configuration
# -----------------------------
# Git metadata (.git) is included by default. A chat-based Chief Engineer
# reviewer has no independent repository access, so the ZIP is the only way
# they see which changes are new vs. pre-existing and where in history they
# landed (see docs/ENGINEERING_GOVERNANCE.md handoff procedure). Set this to
# $false only for a quick source-only share where history genuinely isn't
# needed — do not use $false for a real Chief Engineer review handoff.
$IncludeGitMetadata = $true

# Screenshots can be useful for UI review but are not source code.
$IncludeScreenshots = $true

# Generated artifacts are normally not needed for code review.
$IncludeArtifacts = $false

# -----------------------------
# Resolve project root
# -----------------------------
$projectRoot = (Resolve-Path -LiteralPath (Split-Path -Parent $MyInvocation.MyCommand.Path)).Path
$projectName = Split-Path -Leaf $projectRoot
$outputZip = Join-Path (Split-Path -Parent $projectRoot) "${projectName}-review.zip"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Universal Project Review ZIP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Project root : $projectRoot"
Write-Host "Output ZIP   : $outputZip"
Write-Host ""

# -----------------------------
# Exclusion rules
# -----------------------------
# These are directory NAMES, so the rule works at any nesting depth.
$excludedDirectoryNames = @(
    'node_modules',
    '.git',                 # overridden below when $IncludeGitMetadata = $true
    '.cache',
    '.turbo',
    '.next',
    'dist',
    'build',
    'coverage',
    '.parcel-cache',
    '.vite',
    '.pytest_cache',
    '__pycache__',
    'target',
    'bin',
    'obj',
    'tmp',
    '.tmp'
)

if ($IncludeGitMetadata) {
    $excludedDirectoryNames = $excludedDirectoryNames | Where-Object { $_ -ne '.git' }
}

# .git can contain many thousands of small loose-object files on a repo with
# real history. This is normal and expected — the enumeration below (Get-
# ChildItem -Recurse -Force) will be slower on a large repo, not broken.

if (-not $IncludeScreenshots) {
    $excludedDirectoryNames += 'screenshots'
}

if ($IncludeArtifacts) {
    $excludedDirectoryNames = $excludedDirectoryNames | Where-Object { $_ -ne 'artifacts' }
} else {
    $excludedDirectoryNames += 'artifacts'
}

# These files can contain credentials or machine-local information.
$excludedExactFileNames = @(
    '.DS_Store',
    'Thumbs.db',
    '.npmrc'
)

# Exclude real environment files, but keep safe example/template files.
function Test-IsEnvironmentSecretFile {
    param([string]$Name)

    if ($Name -match '^\.env$') { return $true }

    if ($Name -match '^\.env\.' -and
        $Name -notmatch '^\.env\.(example|sample|template)$' -and
        $Name -notmatch '^\.env\.local\.example$') {
        return $true
    }

    return $false
}

function Test-IsSecretLikeFile {
    param([string]$Name)

    if ($Name -match '^(id_rsa|id_ed25519|id_ecdsa)(\..*)?$') { return $true }
    if ($Name -match '(?i)(^|[-_.])(credentials|service-account|secret|private-key)([-_.].*)?\.(json|ya?ml|pem|key)$') { return $true }
    if ($Name -match '(?i)\.(pem|key|p12|pfx)$') { return $true }

    return $false
}

function Test-ExcludedPath {
    param(
        [System.IO.FileSystemInfo]$Item
    )

    if ($Item.PSIsContainer) {
        if ($excludedDirectoryNames -contains $Item.Name) {
            return $true
        }
        return $false
    }

    if ($excludedExactFileNames -contains $Item.Name) {
        return $true
    }

    if (Test-IsEnvironmentSecretFile -Name $Item.Name) {
        return $true
    }

    if (Test-IsSecretLikeFile -Name $Item.Name) {
        return $true
    }

    return $false
}

# -----------------------------
# Safety / output cleanup
# -----------------------------
if (Test-Path -LiteralPath $outputZip) {
    Write-Host "Removing existing review ZIP..." -ForegroundColor Yellow
    Remove-Item -LiteralPath $outputZip -Force
}

# Never create the ZIP inside the project, so it cannot recursively include itself.
$zipFullPath = [System.IO.Path]::GetFullPath($outputZip)

# -----------------------------
# Discover files
# -----------------------------
Write-Host "Scanning project (including hidden files/folders)..." -ForegroundColor Yellow

$allItems = Get-ChildItem -LiteralPath $projectRoot -Recurse -Force -ErrorAction Stop

$includedFiles = New-Object System.Collections.Generic.List[System.IO.FileInfo]
$excludedCount = 0

foreach ($item in $allItems) {
    # Skip any existing review ZIP if the project happens to contain one.
    if (-not $item.PSIsContainer) {
        $itemFullPath = [System.IO.Path]::GetFullPath($item.FullName)
        if ($itemFullPath -ieq $zipFullPath) {
            $excludedCount++
            continue
        }
    }

    # Exclude a directory and its entire subtree.
    $pathParts = $item.FullName.Substring($projectRoot.Length).TrimStart('\').Split('\')
    $hasExcludedAncestor = $false

    if ($pathParts.Count -gt 1) {
        foreach ($part in $pathParts[0..($pathParts.Count - 2)]) {
            if ($excludedDirectoryNames -contains $part) {
                $hasExcludedAncestor = $true
                break
            }
        }
    }

    if ($hasExcludedAncestor) {
        if (-not $item.PSIsContainer) { $excludedCount++ }
        continue
    }

    if (Test-ExcludedPath -Item $item) {
        if (-not $item.PSIsContainer) { $excludedCount++ }
        continue
    }

    if (-not $item.PSIsContainer) {
        $includedFiles.Add([System.IO.FileInfo]$item)
    }
}

# -----------------------------
# Create ZIP using .NET
# -----------------------------
# This avoids Compress-Archive's hidden-file quirks and does not depend on
# tar/Git for Windows.
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

Write-Host "Creating ZIP..." -ForegroundColor Yellow

$zip = [System.IO.Compression.ZipFile]::Open(
    $outputZip,
    [System.IO.Compression.ZipArchiveMode]::Create
)

try {
    foreach ($file in $includedFiles) {
        $relative = $file.FullName.Substring($projectRoot.Length).TrimStart('\')
        $entryName = ($projectName + '/' + $relative.Replace('\', '/'))

        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $zip,
            $file.FullName,
            $entryName,
            [System.IO.Compression.CompressionLevel]::Optimal
        ) | Out-Null
    }
}
finally {
    $zip.Dispose()
}

# -----------------------------
# Verification
# -----------------------------
if (-not (Test-Path -LiteralPath $outputZip)) {
    throw "ZIP creation failed: $outputZip"
}

$zipSizeMB = [math]::Round((Get-Item -LiteralPath $outputZip).Length / 1MB, 2)

# Check for important hidden folders if they exist in the project.
$importantFolders = @('.claude', '.omp', '.grok', '.github', '.vercel', '.tanstack')
$foundImportant = @()

foreach ($folder in $importantFolders) {
    if (Test-Path -LiteralPath (Join-Path $projectRoot $folder) -PathType Container) {
        $foundImportant += $folder
    }
}

Write-Host ""
Write-Host "DONE" -ForegroundColor Green
Write-Host "ZIP          : $outputZip" -ForegroundColor Green
Write-Host "SIZE         : $zipSizeMB MB" -ForegroundColor Cyan
Write-Host "FILES        : $($includedFiles.Count)" -ForegroundColor Cyan
Write-Host "EXCLUDED     : $excludedCount files" -ForegroundColor Yellow
Write-Host ""

Write-Host "Important hidden/project folders found:" -ForegroundColor Green
if ($foundImportant.Count -gt 0) {
    $foundImportant | ForEach-Object { Write-Host "  + $_" -ForegroundColor Green }
} else {
    Write-Host "  (none found)" -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "Review package rules:" -ForegroundColor Gray
Write-Host "  + Includes hidden folders such as .claude, .omp, .grok, .github, .vercel and .tanstack when present."
Write-Host "  + Includes source, config, migrations, public assets, scripts, tests, docs, etc."
Write-Host "  + Keeps .env.example / .env.sample / .env.template."
Write-Host "  - Excludes real .env secrets, credentials/keys, node_modules and common build caches."
if ($IncludeGitMetadata) {
    Write-Host "  + Git metadata (.git) included — required for a real Chief Engineer review handoff."
} else {
    Write-Host "  - Git metadata (.git) EXCLUDED — reviewer will not see commit history. Do not use this ZIP for a Chief Engineer approval handoff." -ForegroundColor Red
}
Write-Host "  - Screenshots: $IncludeScreenshots"
Write-Host "  - Artifacts: $IncludeArtifacts"
Write-Host ""
Write-Host "You can now upload the ZIP for codebase/curriculum review." -ForegroundColor Green
