. "$PSScriptRoot\compare-json.ps1"

function get_static_content($path) {
    $content = Get-Content -Path $path -Encoding UTF8

    $match = $content | Select-String -Pattern "<!-- prettier-ignore-start -->"

    if ($match) {
        $matchLineNumber = ([array]$match.LineNumber)[0]
        $result = $content | Select-Object -First $matchLineNumber
        $result
    }
}

$content = @("`n|Language|Progress|", "|:-:|:-:|")
$content += "|[en-US](./i18n/en-US.json)|100%|"

foreach ($item in $report) {
    $lang = $item.Language
    $progress = $item.Progress
    $content += "|[$($lang)](./i18n/$($lang).json)|$progress|"
}


Get-ChildItem "$PSScriptRoot\..\" -Filter *.md | ForEach-Object {
    $path = $_.FullName
    (get_static_content $path) + $content + "`n<!-- prettier-ignore-end -->" | Out-File $path -Encoding UTF8 -Force
}
