#Requires -Version 7.0

$baseJson = Get-Content "$PSScriptRoot\..\i18n\en-US.json" -Raw | ConvertFrom-Json -AsHashtable

Get-ChildItem "$PSScriptRoot\..\i18n" -Exclude "en-US.json" | ForEach-Object {
    try {
        $targetJson = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json -AsHashtable -ErrorAction Stop
    }
    catch {
        $targetJson = @{}
    }

    $orderedJson = [ordered]@{}

    foreach ($key in $baseJson.Keys) {
        if ($targetJson.ContainsKey($key)) {
            $orderedJson.$key = $targetJson.$key
        }
        else {
            $orderedJson.$key = ""
        }
    }

    $orderedJson | ConvertTo-Json -Depth 100 | Set-Content $_.FullName -Encoding UTF8
}
