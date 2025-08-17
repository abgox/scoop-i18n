#Requires -Version 7.0

param(
    [array]$OldKeys,
    [array]$NewKeys
)

if ($OldKeys.Length -ne $NewKeys.Length) {
    Write-Error "OldKeys and NewKeys must have the same length."
    exit 1
}

Get-ChildItem "$PSScriptRoot\..\i18n" | ForEach-Object {
    try {
        $targetJson = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json -AsHashtable -ErrorAction Stop
    }
    catch {
        return
    }

    $orderedJson = [ordered]@{}

    foreach ($key in $targetJson.Keys) {
        if ($key -in $OldKeys) {
            $index = [array]::IndexOf($OldKeys, $key)
            $orderedJson[$NewKeys[$index]] = $targetJson.$key
        }
        else {
            $orderedJson.$key = $targetJson.$key
        }
    }

    $orderedJson | ConvertTo-Json -Depth 100 | Set-Content $_.FullName -Encoding UTF8
}
