#Requires -Version 5.1

Set-StrictMode -Off

New-Variable -Name 'scoop-i18n' -Value @{
    Id        = "abgox.scoop-i18n"
    Languages = Get-ChildItem "$PSScriptRoot\i18n" -File | ForEach-Object { $_.BaseName }
    DataFile  = "$PSScriptRoot\data.json"
} -Scope Script -Option Constant -Force

if (-not (Test-Path ${scoop-i18n}.DataFile)) {
    return
}

# https://github.com/abgox/ConvertFrom-JsonAsHashtable
function ConvertFrom-JsonAsHashtable {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        $InputObject
    )

    begin {
        $buffer = [System.Text.StringBuilder]::new()
    }

    process {
        if ($InputObject -is [array]) {
            [void]$buffer.AppendLine(($InputObject -join "`n"))
        }
        else {
            [void]$buffer.AppendLine($InputObject)
        }
    }

    end {
        $jsonString = $buffer.ToString().Trim()
        if (-not $jsonString) { return $null }

        if ($PSVersionTable.PSVersion.Major -ge 7) {
            return ConvertFrom-Json $jsonString -AsHashtable
        }

        $jsonString = [regex]::Replace($jsonString, '(?<!\\)""\s*:', { '"emptyKey_' + [Guid]::NewGuid() + '":' })

        $jsonString = [regex]::Replace($jsonString, ',\s*(?=[}\]]\s*$)', '')

        $parsed = ConvertFrom-Json $jsonString

        function ConvertRecursively {
            param($obj)

            if ($null -eq $obj) { return $null }

            # IDictionary (Hashtable, Dictionary<,>) -> @{ }
            if ($obj -is [System.Collections.IDictionary]) {
                $ht = @{}
                $keys = $obj.Keys
                foreach ($k in $keys) {
                    $ht[$k] = ConvertRecursively $obj[$k]
                }
                return $ht
            }

            # PSCustomObject -> @{ }
            if ($obj -is [System.Management.Automation.PSCustomObject]) {
                $ht = @{}
                $props = $obj.PSObject.Properties
                foreach ($p in $props) {
                    $ht[$p.Name] = ConvertRecursively $p.Value
                }
                return $ht
            }

            # IEnumerable (array、ArrayList), exclude string and byte[]
            if ($obj -is [System.Collections.IEnumerable] -and -not ($obj -is [string]) -and -not ($obj -is [byte[]])) {
                $list = [System.Collections.Generic.List[object]]::new()
                foreach ($item in $obj) {
                    $list.Add((ConvertRecursively $item))
                }
                return , $list.ToArray()
            }

            # ohter types (string, int, bool, datetime...)
            return $obj
        }

        return ConvertRecursively $parsed
    }
}

${scoop-i18n}.ScoopConfigFile = Get-Content ${scoop-i18n}.DataFile -Raw -Encoding utf8 | ConvertFrom-Json | Select-Object -ExpandProperty 'configFile'

try {
    ${scoop-i18n}.ScoopConfig = Get-Content ${scoop-i18n}.ScoopConfigFile -Raw -Encoding utf8 | ConvertFrom-JsonAsHashtable
}
catch {
    Microsoft.PowerShell.Utility\Write-Host "Failed to get the scoop configuration.`nPlease reinstall 'abgox.scoop-i18n'." -ForegroundColor Red
    return
}

if (-not ${scoop-i18n}.ScoopConfig.root_path) {
    Microsoft.PowerShell.Utility\Write-Host "Scoop does not have a root_path configuration.`nPlease reinstall 'abgox.scoop-i18n'." -ForegroundColor Red
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
    ${scoop-i18n}.i18n = Get-Content "$PSScriptRoot\i18n\$(${scoop-i18n}.Language).json" -Raw -Encoding utf8 | ConvertFrom-JsonAsHashtable
}
catch {
    Microsoft.PowerShell.Utility\Write-Host "The i18n file for $(${scoop-i18n}.Language) not found.`nPlease reinstall 'abgox.scoop-i18n'." -ForegroundColor Red
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
        [Parameter(
            Position = 0,
            ValueFromPipeline = $true
        )]
        [Alias('Msg', 'Message')]
        $Object,

        [switch]$NoNewline,

        $Separator,

        [System.ConsoleColor]$ForegroundColor,

        [System.ConsoleColor]$BackgroundColor
    )

    process {
        if (${scoop-i18n}.Id -eq "abgox.scoop-i18n" -and $Object -is [string]) {
            # Update shims
            if ($Object) {
                $pathList = @("$(${scoop-i18n}.ScoopConfig.root_path)\apps\abgox.scoop-i18n\current\app\shims")
                if (${scoop-i18n}.ScoopConfig.global_path) {
                    $pathList += "$(${scoop-i18n}.ScoopConfig.global_path)\apps\abgox.scoop-i18n\current\app\shims"
                }
                $pathList += "C:\ProgramData\scoop\apps\abgox.scoop-i18n\current\app\shims"

                $shims = $null

                foreach ($path in $pathList) {
                    if (Test-Path $path) {
                        $shims = $path
                        break
                    }
                }

                if ($shims) {
                    if ($Object -eq "Updating Buckets..." -or ($Object -eq "Scoop was updated successfully!" -and (Get-Content "$($(${scoop-i18n}.ScoopConfig.root_path))\shims\scoop.ps1" -Raw -Encoding utf8) -notlike "*scoop-i18n.ps1*")) {
                        Get-ChildItem $shims | ForEach-Object { Copy-Item $_.FullName "$($(${scoop-i18n}.ScoopConfig.root_path))\shims" -Force }
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

        $PSBoundParameters['Object'] = $Object
        Microsoft.PowerShell.Utility\Write-Host @PSBoundParameters
    }
}

function script:Write-Output {
    [CmdletBinding()]
    param(
        [Parameter(
            Position = 0,
            ValueFromPipeline = $true
        )]
        [Alias('Input', 'Object')]
        $InputObject,

        [switch]$NoEnumerate
    )

    process {
        if (${scoop-i18n}.Id -eq "abgox.scoop-i18n" -and $InputObject -is [string]) {
            $PSBoundParameters['InputObject'] = ${scoop-i18n}.Get_LocalizedString($InputObject)
        }
        Microsoft.PowerShell.Utility\Write-Output @PSBoundParameters
    }
}
