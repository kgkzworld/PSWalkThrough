Param (
    [String]$Path
)

#region Check and Set Path
    If
    (
        -Not $Path    
    )
    {
        Switch
        (
            $null
        )
        {
            {$MyInvocation.MyCommand.Source}
            {
                $Path =  = $($MyInvocation.MyCommand.Path | Split-Path -Parent)
                Break
            }

            {$Host.Name -match 'ISE'}
            {
                $Path = Split-Path -Path $psISE.CurrentFile.FullPath -Parent
            }

            Default
            {
                $Path = Get-Location | Select-Object -ExpandProperty Path
            }
        }
    }
#endregion Check and Set Path

#region Set .psm1 name based on current script name
    #Note:  This is a check to make sure this script doesn't update any other .psm1 file
    $ManifestPath = $('{0}\{1}.psd1' -f $Path, $($Path | Split-Path -Parent).Split('\')[-1])
#endregion Set .psm1 name based on current script name

#region Update Manifest
    If
    (
        $ManifestPath -and $(Test-Path -Path $ManifestPath)
    )
    {
        $PrivateFunctionList = @(Get-ChildItem -Path $('{0}\Public' -f $Path) -Include '*.ps1' -Recurse -Force | Select-Object -ExpandProperty BaseName)

        If
        (
            $PrivateFunctionList
        )
        {
            Update-ModuleManifest -Path $ManifestPath -FunctionsToExport $PrivateFunctionList
            Write-Host "`nUpdated Manifest: $ManifestPath" -ForegroundColor Green
            Write-Host "`n* Function List`n" -ForegroundColor Yellow
            $PrivateFunctionList
        }
        Else
        {
            Write-Host "Could not update the Manifest" -ForegroundColor Red
        }
    }
    Else
    {
        Write-Host "Could not find the requested Manifest" -ForegroundColor Red
    }   
#endregion Update Manifest