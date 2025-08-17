#Requires -Version 7.0

$baseTemplate = Get-Content "$PSScriptRoot\..\i18n-template.json" -Raw | ConvertFrom-Json -AsHashtable

$report = [System.Collections.Generic.List[object]]::new()

Get-ChildItem "$PSScriptRoot\..\i18n" | ForEach-Object {
    $targetLang = Get-Content $_.FullName -Raw | ConvertFrom-Json -AsHashtable

    $translated = 0
    $untranslated = 0

    foreach ($key in $baseTemplate.Keys) {
        if ($targetLang.ContainsKey($key)) {
            if ($targetLang[$key] -and $targetLang[$key] -ne $key) {
                $translated++
            }
            else {
                $untranslated++
            }
        }
    }

    $totalKeys = $baseTemplate.Count
    $progress = if ($totalKeys -gt 0) { [math]::Round(($translated / $totalKeys) * 100, 2) } else { 0 }

    $report.Add([PSCustomObject]@{
            Language     = $_.BaseName
            Translated   = $translated
            Untranslated = $untranslated
            Progress     = "$progress%"
            TotalKeys    = $totalKeys
        })
}

$report | Format-Table -Property Language, Translated, Untranslated, Missing, Extra, Progress, TotalKeys -AutoSize
