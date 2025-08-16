$baseLangFile = "$PSScriptRoot\..\i18n\en-US.json"
$baseTranslations = Get-Content $baseLangFile -Raw | ConvertFrom-Json -AsHashtable

$report = [System.Collections.Generic.List[object]]::new()

Get-ChildItem "$PSScriptRoot\..\i18n" -Exclude "en-US.json" | ForEach-Object {
    $targetLang = $_.BaseName
    $targetTranslations = Get-Content $_.FullName -Raw | ConvertFrom-Json -AsHashtable

    $translated = 0
    $missing = 0
    $extra = 0
    $untranslated = 0

    foreach ($key in $baseTranslations.Keys) {
        if ($targetTranslations.ContainsKey($key)) {
            if ($targetTranslations[$key] -and $targetTranslations[$key] -ne $key) {
                $translated++
            }
            else {
                $untranslated++
            }
        }
        else {
            $missing++
        }
    }

    $extraKeys = $targetTranslations.Keys | Where-Object { -not $baseTranslations.ContainsKey($_) } | ForEach-Object { $extra++ }

    $totalKeys = $baseTranslations.Count
    $progress = if ($totalKeys -gt 0) { [math]::Round(($translated / $totalKeys) * 100, 2) } else { 0 }

    $report.Add([PSCustomObject]@{
            Language     = $targetLang
            Translated   = $translated
            Untranslated = $untranslated
            Missing      = $missing
            Extra        = $extra
            Progress     = "$progress%"
            TotalKeys    = $totalKeys
        })
}

$report | Format-Table -Property Language, Translated, Untranslated, Missing, Extra, Progress, TotalKeys -AutoSize
