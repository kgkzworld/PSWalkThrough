#region Build Notes
<#
    o 21.3.301: • [Michael Arroyo] Posted
#>
#endregion Build Notes

#region Main
    #region Create Hash
        $PSWalkThroughInfo = @{}
    #endregion Create Hash

    #region Script File and Path Values
        $PSWalkThroughInfo['PSScriptRoot'] = $PSScriptRoot

        If
        (
            $PSWalkThroughInfo['PSScriptRoot'] -eq ''
        )
        {
            If
            (
                $Host.Name -match 'ISE'
            )
            {
                $PSWalkThroughInfo['PSScriptRoot'] = Split-Path -Path $psISE.CurrentFile.FullPath -Parent
            }
        }
    #endregion Script File and Path Values

    #region Script Settings Values
        $PSWalkThroughInfo['ScriptSettings'] = @{}
        $PSWalkThroughInfo['ScriptSettings']['TimeStamp'] = $('D{0}' -f $(Get-Date -Format dd.MM.yyyy-hh.mm.ss.ff.tt)) -replace '-','_T'
        $PSWalkThroughInfo['ScriptSettings']['CurrentUser'] = $($env:USERNAME)
        $PSWalkThroughInfo['ScriptSettings']['CurrentComputer'] = $env:COMPUTERNAME.ToUpper()
        $PSWalkThroughInfo['ScriptSettings']['WorkingPath'] = $PSWalkThroughInfo.PSScriptRoot
        $PSWalkThroughInfo['ScriptSettings']['LoadedFunctionsPrv'] = @()
        $PSWalkThroughInfo['ScriptSettings']['LoadedFunctionsPub'] = @()
        $PSWalkThroughInfo['ScriptSettings']['LoadedVariablesPub'] = @()
        $PSWalkThroughInfo['ScriptSettings']['LoadedAliasesPub'] = @()
        $PSWalkThroughInfo['ScriptSettings']['Log'] = @()
    #endregion Script Settings Values

    #region Query Private Functions
        $PSWalkThroughPrivate = Get-ChildItem -Path $(Join-Path -Path $($PSWalkThroughInfo.ScriptSettings.Workingpath) -ChildPath 'Private') -Filter '*.ps1' -Force -Recurse -ErrorAction SilentlyContinue | Select-Object -Property BaseName,FullName
    #endregion Query Core Path

    #region Query Public Functions
        $PSWalkThroughPublic = Get-ChildItem -Path $(Join-Path -Path $($PSWalkThroughInfo.ScriptSettings.Workingpath) -ChildPath 'Public') -Filter '*.ps1' -Force -Recurse -ErrorAction SilentlyContinue | Select-Object -Property BaseName,FullName
    #endregion Query Core Path

    #region Dynamically Build Functions from .PS1 files
        If
        (
            $PSWalkThroughPrivate
        )
        {
            $PSWalkThroughPrivate | ForEach-Object `
            -Process `
            {
                Try
                {
                    . $($_ | Select-Object -ExpandProperty FullName)
                    $PSWalkThroughInfo['ScriptSettings']['LoadedFunctionsPrv'] += $($_ | Select-Object -ExpandProperty BaseName)
                }
                Catch
                {
                    #Nothing
                }
            }
        }

        If
        (
            $PSWalkThroughPublic
        )
        {
            $PSWalkThroughPublic | ForEach-Object `
            -Process `
            {
                Try
                {
                    . $($_ | Select-Object -ExpandProperty FullName)
                    $PSWalkThroughInfo['ScriptSettings']['LoadedFunctionsPub'] += $($_ | Select-Object -ExpandProperty BaseName)
                }
                Catch
                {
                    #Nothing
                }
            }
        }
    #endregion Dynamically Build Functions from .PS1 files

    #region Dynamically Build Export Variable list
        $PSWalkThroughInfo['ScriptSettings']['LoadedVariablesPub'] += 'PSWalkThroughInfo'
    #endregion Dynamically Build Export Variable list

    #region Export Module Members
        Export-ModuleMember `
        -Function $($PSWalkThroughInfo['ScriptSettings']['LoadedFunctionsPub']) `
        -Variable $($PSWalkThroughInfo['ScriptSettings']['LoadedVariablesPub']) `
        #-Alias $($BluGenieInfo['ScriptSettings']['LoadedAliases'] | Select-Object -ExpandProperty Name)
    #endregion Export Module Members
#endregion Main