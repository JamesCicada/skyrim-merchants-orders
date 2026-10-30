[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$SkyrimData,
    [string]$Compiler = (Join-Path $PSScriptRoot '.tools\caprica\Caprica.exe'),
    [string]$VanillaSources,
    [string]$FlagsFile
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
$master = Join-Path $SkyrimData 'Skyrim.esm'
if (!(Test-Path -LiteralPath $master)) { throw "Skyrim.esm not found: $master" }
if (!(Test-Path -LiteralPath $Compiler)) { throw "Compiler not found. See docs/BUILD.md." }
$sourceRoot = Join-Path $projectRoot 'Source\Scripts'
$apiRoot = Join-Path $projectRoot 'tools\api'
if ($VanillaSources) {
    if (!(Test-Path -LiteralPath $VanillaSources)) { throw 'Vanilla source directory not found.' }
    $apiRoot = $VanillaSources
    if (!$FlagsFile) { $FlagsFile = Join-Path $VanillaSources 'TESV_Papyrus_Flags.flg' }
}
if (!$FlagsFile) { $FlagsFile = Join-Path $apiRoot 'TESV_Papyrus_Flags.flg' }
if (!(Test-Path -LiteralPath $FlagsFile)) { throw "Flags file not found: $FlagsFile" }

$dataRoot = Join-Path $projectRoot 'build\Data'
$scriptsRoot = Join-Path $dataRoot 'Scripts'
New-Item -ItemType Directory -Force -Path $scriptsRoot | Out-Null
& dotnet run --project (Join-Path $projectRoot 'tools\PluginBuilder') -- $master $dataRoot $sourceRoot (Join-Path $projectRoot 'catalogs\materials.json')
if ($LASTEXITCODE -ne 0) { throw 'Plugin generation or binary validation failed.' }
$scriptNames = @('MO_OrderManager', 'MO_OrderDialogue', 'MO_Catalog', 'MO_UIBridge', 'MO_ShipmentReceipt')
foreach ($scriptName in $scriptNames) {
    # Remove only this build's known outputs so stale PEX files cannot pass.
    $compiled = Join-Path $scriptsRoot "$scriptName.pex"
    if (Test-Path -LiteralPath $compiled) { Remove-Item -LiteralPath $compiled }
}
foreach ($scriptName in $scriptNames) {
    & $Compiler --game skyrim --import $apiRoot --import $sourceRoot --flags $FlagsFile --output $scriptsRoot (Join-Path $sourceRoot "$scriptName.psc")
    if ($LASTEXITCODE -ne 0) { throw "Papyrus compilation failed: $scriptName" }
    $compiled = Join-Path $scriptsRoot "$scriptName.pex"
    if (!(Test-Path -LiteralPath $compiled)) { throw "Compiler produced no PEX: $scriptName" }
    $bytes = [IO.File]::ReadAllBytes($compiled)
    if ($bytes.Length -lt 8 -or $bytes[0] -ne 0xFA -or $bytes[1] -ne 0x57 -or $bytes[2] -ne 0xC0 -or $bytes[3] -ne 0xDE -or $bytes[6] -ne 0 -or $bytes[7] -ne 1) {
        throw "Output is not a Skyrim PEX: $scriptName"
    }
}


$uiSource = Join-Path $projectRoot 'Source\UI'
$uiApi = Join-Path $projectRoot 'tools\ui-api'
$uiOutput = Join-Path $projectRoot 'build\UI\Scripts'
New-Item -ItemType Directory -Force -Path $uiOutput | Out-Null
foreach ($scriptName in @('MO_UiExtensionsBridge', 'MO_Config')) {
    $compiled = Join-Path $uiOutput "$scriptName.pex"
    if (Test-Path -LiteralPath $compiled) { Remove-Item -LiteralPath $compiled }
    & $Compiler --game skyrim --import $apiRoot --import $uiApi --import $sourceRoot --import $uiSource --flags $FlagsFile --output $uiOutput (Join-Path $uiSource "$scriptName.psc")
    if ($LASTEXITCODE -ne 0 -or !(Test-Path -LiteralPath $compiled)) { throw "UI addon compile failed: $scriptName" }
}
$dist = Join-Path $projectRoot 'dist'
New-Item -ItemType Directory -Force -Path $dist | Out-Null
$zipPath = Join-Path $dist 'MerchantOrders-0.3.0-prototype.zip'
Add-Type -AssemblyName System.IO.Compression.FileSystem
# Package an explicit allowlist; never include tools, API declarations, or game assets.
$entries = [ordered]@{
    'MerchantOrders.esp' = (Join-Path $dataRoot 'MerchantOrders.esp')
    'Seq/MerchantOrders.seq' = (Join-Path $dataRoot 'Seq\MerchantOrders.seq')
    'Scripts/MO_OrderManager.pex' = (Join-Path $scriptsRoot 'MO_OrderManager.pex')
    'Scripts/MO_OrderDialogue.pex' = (Join-Path $scriptsRoot 'MO_OrderDialogue.pex')
    'Source/Scripts/MO_OrderManager.psc' = (Join-Path $sourceRoot 'MO_OrderManager.psc')
    'Source/Scripts/MO_OrderDialogue.psc' = (Join-Path $sourceRoot 'MO_OrderDialogue.psc')
    'Scripts/MO_Catalog.pex' = (Join-Path $scriptsRoot 'MO_Catalog.pex')
    'Source/Scripts/MO_Catalog.psc' = (Join-Path $sourceRoot 'MO_Catalog.psc')
    'Scripts/MO_UIBridge.pex' = (Join-Path $scriptsRoot 'MO_UIBridge.pex')
    'Scripts/MO_ShipmentReceipt.pex' = (Join-Path $scriptsRoot 'MO_ShipmentReceipt.pex')
    'Source/Scripts/MO_UIBridge.psc' = (Join-Path $sourceRoot 'MO_UIBridge.psc')
    'Source/Scripts/MO_ShipmentReceipt.psc' = (Join-Path $sourceRoot 'MO_ShipmentReceipt.psc')
    'MerchantOrders-README.md' = (Join-Path $projectRoot 'docs\INSTALL.md')
}
$tempZipPath = "$zipPath.tmp"
$archive = [IO.Compression.ZipFile]::Open($tempZipPath, [IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($entry in $entries.GetEnumerator()) {
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $entry.Value, $entry.Key) | Out-Null
    }
} finally { $archive.Dispose() }
Move-Item -LiteralPath $tempZipPath -Destination $zipPath -Force
$check = [IO.Compression.ZipFile]::OpenRead($zipPath)
try {
    if ($check.Entries.Count -ne $entries.Count) { throw 'Unexpected package entry count.' }
    foreach ($entry in $check.Entries) {
        if ($entry.Length -eq 0) { throw "Empty packaged file: $($entry.FullName)" }
    }
} finally { $check.Dispose() }
$uiZip = Join-Path $dist 'MerchantOrders-UI-0.3.0.zip'
$uiEntries = [ordered]@{
    'MerchantOrders-UI.esp' = (Join-Path $dataRoot 'MerchantOrders-UI.esp')
    'Seq/MerchantOrders-UI.seq' = (Join-Path $dataRoot 'Seq\MerchantOrders-UI.seq')
    'Scripts/MO_UiExtensionsBridge.pex' = (Join-Path $uiOutput 'MO_UiExtensionsBridge.pex')
    'Scripts/MO_Config.pex' = (Join-Path $uiOutput 'MO_Config.pex')
    'Source/Scripts/MO_UiExtensionsBridge.psc' = (Join-Path $uiSource 'MO_UiExtensionsBridge.psc')
    'Source/Scripts/MO_Config.psc' = (Join-Path $uiSource 'MO_Config.psc')
    'MerchantOrders-UI-README.md' = (Join-Path $projectRoot 'docs\UI.md')
}
$uiTemp = "$uiZip.tmp"
$archive = [IO.Compression.ZipFile]::Open($uiTemp, [IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($entry in $uiEntries.GetEnumerator()) {
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $entry.Value, $entry.Key) | Out-Null
    }
} finally { $archive.Dispose() }
Move-Item -LiteralPath $uiTemp -Destination $uiZip -Force
$archive = [IO.Compression.ZipFile]::OpenRead($uiZip)
try {
    if ($archive.Entries.Count -ne $uiEntries.Count -or @($archive.Entries | Where-Object { $_.Length -eq 0 }).Count -gt 0) {
        throw 'Invalid UI addon package.'
    }
} finally { $archive.Dispose() }
Write-Host "Optional UI addon: $uiZip"
Write-Host "Package ready: $zipPath"
Write-Host 'Compilation, plugin readback, and package checks passed. See docs/STATUS.md for author testing reports.'
