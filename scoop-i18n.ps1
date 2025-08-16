New-Variable -Name 'scoop-i18n' -Value @{
    Languages        = Get-ChildItem "$PSScriptRoot\i18n" -File | ForEach-Object { $_.BaseName }
    ScoopConfigPaths = @(
        "$env:SCOOP\config.json",
        "$env:UserProfile\.config\scoop\config.json"
    )
} -Scope Script

if ($PSEdition -eq 'Core') {
    Add-Member -InputObject ${scoop-i18n} -MemberType ScriptMethod ConvertFrom_JsonAsHashtable {
        param([string]$json)
        ConvertFrom-Json $json -AsHashtable
    }
}
else {
    Add-Member -InputObject ${scoop-i18n} -MemberType ScriptMethod ConvertFrom_JsonAsHashtable {
        param([string]$json)
        $matches = [regex]::Matches($json, '\s*"\s*"\s*:')
        foreach ($match in $matches) {
            $json = $json -replace $match.Value, "`"empty_key_$([System.Guid]::NewGuid().Guid)`":"
        }
        $json = [regex]::Replace($json, ",`n?(\s*`n)?\}", "}")

        function ProcessArray {
            param($array)
            $nestedArr = @()
            foreach ($item in $array) {
                if ($item -is [System.Collections.IEnumerable] -and $item -isnot [string]) {
                    $nestedArr += , (ProcessArray $item)
                }
                elseif ($item -is [System.Management.Automation.PSCustomObject]) {
                    $nestedArr += ConvertToHashtable $item
                }
                else { $nestedArr += $item }
            }
            return , $nestedArr
        }

        function ConvertToHashtable {
            param($obj)
            $hash = @{}
            if ($obj -is [System.Management.Automation.PSCustomObject]) {
                foreach ($_ in $obj | Get-Member -MemberType Properties) {
                    $k = $_.Name # Key
                    $v = $obj.$k # Value
                    if ($v -is [System.Collections.IEnumerable] -and $v -isnot [string]) {
                        # Handle array (preserve nested structure)
                        $hash[$k] = ProcessArray $v
                    }
                    elseif ($v -is [System.Management.Automation.PSCustomObject]) {
                        # Handle object
                        $hash[$k] = ConvertToHashtable $v
                    }
                    else { $hash[$k] = $v }
                }
            }
            else { $hash = $obj }
            $hash
        }
        # Recurse
        ConvertToHashtable ($json | ConvertFrom-Json)
    }
}

foreach ($p in ${scoop-i18n}.ScoopConfigPaths) {
    if (Test-Path $p) {
        ${scoop-i18n}.ScoopConfig = ${scoop-i18n}.ConvertFrom_JsonAsHashtable((Get-Content $p -Raw -Encoding utf8 -WarningAction SilentlyContinue))
        break
    }
}

if (${scoop-i18n}.ScoopConfig.'abgox-scoop-i18n-language') {
    ${scoop-i18n}.Language = ${scoop-i18n}.ScoopConfig.'abgox-scoop-i18n-language'
}
else {
    ${scoop-i18n}.Language = $PSUICulture
}

if (${scoop-i18n}.Language -notin ${scoop-i18n}.Languages) {
    ${scoop-i18n}.Language = "en-US"
}

${scoop-i18n}.i18n = ${scoop-i18n}.ConvertFrom_JsonAsHashtable((Get-Content "$PSScriptRoot\i18n\$(${scoop-i18n}.Language).json" -Raw -Encoding utf8 -WarningAction SilentlyContinue))

function script:Get-LocalizedString {
    param(
        [string]$InputString,
        [System.Object]$TranslationMap = ${scoop-i18n}.i18n
    )

    if ($TranslationMap.$InputString) {
        return $TranslationMap.$InputString
    }

    foreach ($pattern in $TranslationMap.Keys) {
        if ($pattern -notmatch '\{\d+\}') { continue }

        $escapedPattern = [regex]::Escape($pattern)
        $regexPattern = $escapedPattern -replace '\\\{\d+\}', '((?s).*)'
        $regexPattern = "^" + $regexPattern + "$"
        $match = [regex]::Match($InputString, $regexPattern)
        if ($match.Success) {
            $translation = $TranslationMap.$pattern
            if ($translation -eq "") {
                return $InputString
            }
            $translation = [regex]::Replace($translation, '\{(\d+)\}', {
                    param($m)
                    $index = [int]$m.Groups[1].Value
                    return $match.Groups[$index + 1].Value.Trim()
                })
            return $translation
        }
    }
    return $InputString
}

function script:Write-Host {
    [CmdletBinding()]
    param(
        $Object,
        [switch]$NoNewline,
        [Alias('f')]
        [System.ConsoleColor]$ForegroundColor,
        [Alias('b')]
        [System.ConsoleColor]$BackgroundColor
    )

    if ($Object -is [string]) {
        # Update shims
        if ($Object) {
            $pathList = @(
                "$env:SCOOP\apps\abgox.scoop-i18n\current\shims",
                "$env:SCOOP_GLOBAL\apps\abgox.scoop-i18n\current\shims"
            )
            $shims = $null

            foreach ($path in $pathList) {
                if (Test-Path $path) {
                    $shims = $path
                    break
                }
            }

            if ($shims) {
                if ($Object -eq "Updating Buckets..." -or ($Object -eq "Scoop was updated successfully!" -and (Get-Content "$env:SCOOP\shims\scoop.ps1" -Raw) -notlike "*scoop-i18n.ps1*")) {
                    Get-ChildItem $shims | ForEach-Object { Copy-Item $_.FullName "$env:SCOOP\shims" -Force }
                }
            }
        }

        $pad = ""

        if ($Object -match "^ERROR ") {
            $Object = $Object -replace "^ERROR ", ""
            $pad = ${scoop-i18n}.i18n.ERROR
        }
        elseif ($Object -match "^WARN  ") {
            $Object = $Object -replace "^WARN  ", ""
            $pad = ${scoop-i18n}.i18n.WARN
        }
        elseif ($Object -match "^INFO  ") {
            $Object = $Object -replace "^INFO  ", ""
            $pad = ${scoop-i18n}.i18n.INFO
        }

        if ($Object -match ".*suggests installing.*' or '") {
            $Object = $Object -replace "' or '", ${scoop-i18n}.i18n["' or '"]
        }

        $Object = $pad + (Get-LocalizedString $Object)
    }

    $splatParams = @{}

    if ($PSBoundParameters.ContainsKey('Object')) {
        $splatParams['Object'] = $Object
    }
    if ($PSBoundParameters.ContainsKey('NoNewline')) {
        $splatParams['NoNewline'] = $NoNewline
    }
    if ($PSBoundParameters.ContainsKey('ForegroundColor')) {
        $splatParams['ForegroundColor'] = $ForegroundColor
    }
    if ($PSBoundParameters.ContainsKey('BackgroundColor')) {
        $splatParams['BackgroundColor'] = $BackgroundColor
    }

    Microsoft.PowerShell.Utility\Write-Host @splatParams
}

function script:Write-Output {
    [CmdletBinding()]
    param(
        $InputObject
    )

    if ($InputObject -is [string]) {
        $InputObject = Get-LocalizedString $InputObject
    }

    Microsoft.PowerShell.Utility\Write-Output $InputObject
}


function warn($msg) { write-host "WARN  $msg" -f darkyellow }
