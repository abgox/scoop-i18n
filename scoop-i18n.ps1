Set-StrictMode -Off

New-Variable -Name 'scoop-i18n' -Value @{
    Id        = "abgox.scoop-i18n"
    Languages = Get-ChildItem "$PSScriptRoot\i18n" -File | ForEach-Object { $_.BaseName }
} -Scope Script -Option ReadOnly

${scoop-i18n}.scoopTempConfig = Get-Content "$PSScriptRoot\config.json" -Raw -Encoding utf8 -ErrorAction SilentlyContinue | ConvertFrom-Json

if (!${scoop-i18n}.scoopTempConfig.root_path) {
    Microsoft.PowerShell.Utility\Write-Host "Scoop does not have a root_path configuration. Please run the following command." -ForegroundColor Red
    Microsoft.PowerShell.Utility\Write-Host "scoop config root_path (scoop prefix scoop).Replace('\apps\scoop\current','')" -ForegroundColor Magenta
    return
}

${scoop-i18n}.ScoopConfigPaths = @(
    "$(${scoop-i18n}.scoopTempConfig.root_path)\config.json",
    "$env:UserProfile\.config\scoop\config.json"
)

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
    try {
        ${scoop-i18n}.ScoopConfig = ${scoop-i18n}.ConvertFrom_JsonAsHashtable((Get-Content $p -Raw))
        break
    }
    catch {}
}

if (!${scoop-i18n}.ScoopConfig) {
    Microsoft.PowerShell.Utility\Write-Host "Scoop does not have a root_path configuration. Please run the following command." -ForegroundColor Red
    Microsoft.PowerShell.Utility\Write-Host "scoop config root_path (scoop prefix scoop).Replace('\apps\scoop\current','')" -ForegroundColor Magenta
    return
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

try {
    ${scoop-i18n}.i18n = ${scoop-i18n}.ConvertFrom_JsonAsHashtable((Get-Content "$PSScriptRoot\i18n\$(${scoop-i18n}.Language).json" -Raw))
}
catch {
    Microsoft.PowerShell.Utility\Write-Host "The i18n file for $(${scoop-i18n}.Language) not found.`nPlease reinstall abgox.scoop-i18n." -ForegroundColor Red
    return
}

Add-Member -InputObject ${scoop-i18n} -MemberType ScriptMethod Get_LocalizedString {
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
        [Alias('o')]
        $Object,
        [Alias('n')]
        [switch]$NoNewline,
        [Alias('s')]
        $Separator,
        [Alias('f')]
        [System.ConsoleColor]$ForegroundColor,
        [Alias('b')]
        [System.ConsoleColor]$BackgroundColor
    )

    if (${scoop-i18n}.Id -eq "abgox.scoop-i18n" -and $Object -is [string]) {
        # Update shims
        if ($Object) {
            $pathList = @("$(${scoop-i18n}.scoopTempConfig.root_path)\apps\abgox.scoop-i18n\current\shims")
            if (${scoop-i18n}.scoopTempConfig.global_path) {
                $pathList += "$(${scoop-i18n}.scoopTempConfig.global_path)\apps\abgox.scoop-i18n\current\shims"
            }

            $shims = $null

            foreach ($path in $pathList) {
                if (Test-Path $path) {
                    $shims = $path
                    break
                }
            }

            if ($shims) {
                if ($Object -eq "Updating Buckets..." -or ($Object -eq "Scoop was updated successfully!" -and (Get-Content "$($(${scoop-i18n}.scoopTempConfig.root_path))\shims\scoop.ps1" -Raw) -notlike "*scoop-i18n.ps1*")) {
                    Get-ChildItem $shims | ForEach-Object { Copy-Item $_.FullName "$($(${scoop-i18n}.scoopTempConfig.root_path))\shims" -Force }
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

        $Object = $pad + ${scoop-i18n}.Get_LocalizedString($Object)
    }

    $params = @{}

    if ($PSBoundParameters.ContainsKey('Object')) {
        $params['Object'] = $Object
    }
    if ($PSBoundParameters.ContainsKey('NoNewline')) {
        $params['NoNewline'] = $NoNewline
    }
    if ($PSBoundParameters.ContainsKey('Separator')) {
        $params['Separator'] = $Separator
    }
    if ($PSBoundParameters.ContainsKey('ForegroundColor')) {
        $params['ForegroundColor'] = $ForegroundColor
    }
    if ($PSBoundParameters.ContainsKey('BackgroundColor')) {
        $params['BackgroundColor'] = $BackgroundColor
    }

    Microsoft.PowerShell.Utility\Write-Host @params
}

function script:Write-Output {
    [CmdletBinding()]
    param(
        $InputObject,
        [switch]$NoEnumerate
    )

    if (${scoop-i18n}.Id -eq "abgox.scoop-i18n" -and $InputObject -is [string]) {
        $InputObject = ${scoop-i18n}.Get_LocalizedString($InputObject)
    }

    Microsoft.PowerShell.Utility\Write-Output $InputObject -NoEnumerate:$NoEnumerate
}
