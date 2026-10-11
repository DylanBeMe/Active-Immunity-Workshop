<#
.SYNOPSIS
Upload an Active Immunity mod folder to the Steam Workshop with SteamCMD.

.DESCRIPTION
Run from PowerShell (Windows blocks scripts by default, so pass -ExecutionPolicy):

  powershell -ExecutionPolicy Bypass -File tools\upload_workshop_mod.ps1 -ModFolder mods\my-mod

Run it without -ModFolder and it asks for the folder.

The first upload creates the item and saves its ID beside the mod folder as
"<folder>.workshop-id". Later uploads update that item. On updates, title,
description, visibility and preview are only changed when you pass them, so
edits made on the item's Steam page are kept.

.PARAMETER ModFolder
The mod folder; it must contain manifest.json at the top level.
.PARAMETER SteamUser
Steam account to upload with (asked for if omitted).
.PARAMETER Visibility
private (default for a new item), friends, unlisted or public.
.PARAMETER Title
Item title (new item default: "name" from manifest.json).
.PARAMETER Description
Item description (new item default: "description" from manifest.json).
.PARAMETER Preview
Preview image, PNG/JPG/GIF under 1 MB.
.PARAMETER ChangeNote
What changed in this upload (default: "Update").
.PARAMETER SteamCmd
Path to steamcmd.exe (default: steamcmd.exe on PATH, then C:\steamcmd\steamcmd.exe).
.PARAMETER AppId
Steam App ID (default: 5023510, Active Immunity).
#>
param(
    [string]$ModFolder = "",
    [string]$SteamUser = "",
    [string]$Visibility = "",
    [string]$Title = "",
    [string]$Description = "",
    [string]$Preview = "",
    [string]$ChangeNote = "",
    [string]$SteamCmd = "",
    [string]$AppId = "5023510"
)

$ErrorActionPreference = "Stop"
$MaxPreviewBytes = 1MB

function Fail([string]$Message) {
    Write-Host "Error: $Message" -ForegroundColor Red
    exit 1
}

# VDF strings: escape backslashes and quotes, keep line breaks as \n.
function ConvertTo-VdfString([string]$Value) {
    return $Value.Replace('\', '\\').Replace('"', '\"').Replace("`r", "").Replace("`n", '\n')
}

# --- Check the mod folder ----------------------------------------------------
if (-not $ModFolder) { $ModFolder = Read-Host "Mod folder (the one containing manifest.json)" }
$ModFolder = $ModFolder.Trim('"')
if (-not (Test-Path -LiteralPath $ModFolder -PathType Container)) { Fail "Mod folder not found: $ModFolder" }
$ModFolder = (Resolve-Path -LiteralPath $ModFolder).ProviderPath.TrimEnd('\')
$Manifest = Join-Path $ModFolder "manifest.json"
if (-not (Test-Path -LiteralPath $Manifest -PathType Leaf)) {
    Fail "No manifest.json in $ModFolder. The folder you upload must contain it at the top level."
}
if ($AppId -notmatch '^\d+$') { Fail "-AppId must be a number." }
$IdFile = Join-Path (Split-Path -Parent $ModFolder) ((Split-Path -Leaf $ModFolder) + ".workshop-id")

$VisibilityCodes = @{ "public" = "0"; "friends" = "1"; "private" = "2"; "unlisted" = "3" }
$VisibilityCode = ""
if ($Visibility) {
    if (-not $VisibilityCodes.ContainsKey($Visibility.ToLower())) { Fail "-Visibility must be private, friends, unlisted or public." }
    $VisibilityCode = $VisibilityCodes[$Visibility.ToLower()]
}

if ($Preview) {
    if (-not (Test-Path -LiteralPath $Preview -PathType Leaf)) { Fail "Preview image not found: $Preview" }
    $Preview = (Resolve-Path -LiteralPath $Preview).ProviderPath
    if ((Get-Item -LiteralPath $Preview).Length -gt $MaxPreviewBytes) { Fail "The preview image must be under 1 MB." }
}

$PublishedId = "0"
if (Test-Path -LiteralPath $IdFile) {
    $PublishedId = ((Get-Content -LiteralPath $IdFile -Raw) -replace '\D', '')
    if (-not $PublishedId) { Fail "$IdFile does not contain an item ID. Fix or delete it." }
}
$IsNew = $PublishedId -eq "0"

if ($IsNew) {
    try {
        $ManifestData = Get-Content -LiteralPath $Manifest -Raw -Encoding UTF8 | ConvertFrom-Json
    } catch {
        Fail "manifest.json is not valid JSON: $($_.Exception.Message)"
    }
    if (-not $Title -and $ManifestData.name -is [string]) { $Title = $ManifestData.name }
    if (-not $Description -and $ManifestData.description -is [string]) { $Description = $ManifestData.description }
    if (-not $Title) { Fail "No title: pass -Title, or set ""name"" in manifest.json." }
    if (-not $VisibilityCode) { $VisibilityCode = "2" }
}
if (-not $ChangeNote) { $ChangeNote = if ($IsNew) { "First release." } else { "Update" } }

# --- Validate, when Godot is available ---------------------------------------
$RepoRoot = Split-Path -Parent $PSScriptRoot
$Godot = Get-Command godot, godot.exe -ErrorAction SilentlyContinue | Select-Object -First 1
if ($Godot) {
    Write-Host "Validating $Manifest ..."
    & $Godot.Source --headless --path $RepoRoot --script tools/validate_workshop_mod.gd -- $Manifest
    if ($LASTEXITCODE -ne 0) { Fail "The validator found problems. Fix them before uploading." }
} else {
    Write-Host "Godot not found on PATH; skipping the offline validator (see README, Part 5)."
}

# --- SteamCMD -----------------------------------------------------------------
if (-not $SteamCmd) {
    $Found = Get-Command steamcmd.exe -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($Found) { $SteamCmd = $Found.Source }
    elseif (Test-Path -LiteralPath "C:\steamcmd\steamcmd.exe") { $SteamCmd = "C:\steamcmd\steamcmd.exe" }
}
if (-not $SteamCmd -or -not (Test-Path -LiteralPath $SteamCmd -PathType Leaf)) {
    Fail "SteamCMD not found. Install it to C:\steamcmd (README, Part 5) or pass -SteamCmd path\to\steamcmd.exe."
}
if (-not $SteamUser) { $SteamUser = Read-Host "Steam account name" }
if (-not $SteamUser) { Fail "A Steam account name is needed." }

$Lines = @(
    '"workshopitem"',
    '{',
    "`t""appid""`t`t""$AppId""",
    "`t""publishedfileid""`t""$PublishedId""",
    "`t""contentfolder""`t""$(ConvertTo-VdfString $ModFolder)""",
    "`t""changenote""`t""$(ConvertTo-VdfString $ChangeNote)"""
)
if ($Title) { $Lines += "`t""title""`t`t""$(ConvertTo-VdfString $Title)""" }
if ($Description) { $Lines += "`t""description""`t""$(ConvertTo-VdfString $Description)""" }
if ($VisibilityCode) { $Lines += "`t""visibility""`t""$VisibilityCode""" }
if ($Preview) { $Lines += "`t""previewfile""`t""$(ConvertTo-VdfString $Preview)""" }
$Lines += '}'

# Some SteamCMD launchers split arguments at spaces, so the item file goes
# next to steamcmd.exe when that folder has none (C:\steamcmd), else to Temp.
$WorkDir = Split-Path -Parent $SteamCmd
if ($WorkDir -match ' ') { $WorkDir = [System.IO.Path]::GetTempPath() }
$Vdf = Join-Path $WorkDir ("workshop_item_{0}.vdf" -f [guid]::NewGuid().ToString("N").Substring(0, 8))
# UTF-8 without a byte-order mark, which Windows PowerShell adds by default.
[System.IO.File]::WriteAllText($Vdf, ($Lines -join "`r`n") + "`r`n", (New-Object System.Text.UTF8Encoding $false))

try {
    # Sign in on its own first, so password and Steam Guard prompts are shown
    # normally. SteamCMD remembers the login, so the upload does not ask again.
    Write-Host "Signing in to Steam as $SteamUser ..."
    & $SteamCmd +login $SteamUser +quit
    if ($IsNew) { Write-Host "Creating a new Workshop item ..." } else { Write-Host "Updating Workshop item $PublishedId ..." }

    # SteamCMD's error stream must not turn into PowerShell errors here.
    $ErrorActionPreference = "Continue"
    & $SteamCmd +login $SteamUser +workshop_build_item $Vdf +quit 2>&1 | ForEach-Object { "$_" } | Tee-Object -Variable Captured | Out-Host
    $Status = $LASTEXITCODE
    $ErrorActionPreference = "Stop"
    $Log = $Captured -join "`n"
    if ($Log -match '(?i)ERROR|FAILED') { Fail "SteamCMD reported a problem (see the output above)." }
    if ($Status -ne 0) { Fail "SteamCMD exited with status $Status." }

    if ($IsNew) {
        # SteamCMD writes the new ID back into the item file; its output also names it.
        $NewId = ""
        $Written = Select-String -LiteralPath $Vdf -Pattern '^\s*"publishedfileid"\s*"(\d+)"' | Select-Object -First 1
        if ($Written) { $NewId = $Written.Matches[0].Groups[1].Value }
        if (-not $NewId -or $NewId -eq "0") {
            $Found = [regex]::Matches($Log, '(?i)(publishedfileid|published file id|publishfileid)\D{0,4}(\d{6,})')
            if ($Found.Count -gt 0) { $NewId = $Found[$Found.Count - 1].Groups[2].Value }
        }
        if ($NewId -and $NewId -ne "0") {
            Set-Content -LiteralPath $IdFile -Value $NewId -Encoding ASCII
            $PublishedId = $NewId
            Write-Host "Saved the item ID to $IdFile; the next upload updates this item."
        } else {
            Write-Host "Uploaded, but the new item ID could not be read from SteamCMD's output."
            Write-Host "Open the item on Steam, copy the number after 'id=' in its address, and save it in:"
            Write-Host "  $IdFile"
            exit 0
        }
    }
} finally {
    Remove-Item -LiteralPath $Vdf -ErrorAction SilentlyContinue
}

Write-Host "Done: https://steamcommunity.com/sharedfiles/filedetails/?id=$PublishedId"
if ($IsNew) { Write-Host "New items stay hidden until you accept the Workshop legal agreement on that page." }
