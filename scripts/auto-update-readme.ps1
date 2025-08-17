. "$PSScriptRoot\compare-json.ps1"

$newContent = @("`n|Language|Progress|", "|:-:|:-:|")

foreach ($item in $report) {
    $lang = $item.Language
    $progress = $item.Progress
    $newContent += "|[$($lang)](./i18n/$($lang).json)|$progress|"
}

Get-ChildItem "$PSScriptRoot\..\" -Filter readme*.md | ForEach-Object {
    $path = $_.FullName
    $content = Get-Content -Path $path -Encoding UTF8
    $match = $content | Select-String -Pattern "<!-- prettier-ignore-start -->"
    if ($match) {
        $matchLineNumber = ([array]$match.LineNumber)[0]
        $result = $content | Select-Object -First $matchLineNumber
        $result + $newContent + "`n<!-- prettier-ignore-end -->" | Out-File $path -Encoding UTF8 -Force
    }
}
