# PSWalkThrough Module
PSWalkThrough is a module that will help convert the static PowerShell help into an interactive menu system.

Adding new helpstring tags will structure the help to

* Review the default parameters values 
* Update any parameter on the fly
* Choose from any of the examples based on the Description information
* Automatically build out the process string based on the parameters and values defined
* Clearly identify the Parameter or Example information

        
Parameter helpstring should look like the below in the Help Header
```
PARAMETER <parameter>
    Description:  Desciption of the Parameter
    Notes:        Any Notes
    Alias:        Alias if any
    ValidateSet:  ValidationSet Array Items
```
Example helpstring should look like the below in the Help Header
```        
EXAMPLE
    Command:     Your command string
    Description: Description of what the command above will do
    Notes:       Any Notes
```

Add the Walkthrough\Help Parameter to your Functions Parameter List
```
[Alias('Help')]
[Switch]$Walkthrough
```             

Add the below snippet of code to your Function.  The below region should be the first Call before running any other code in your script.
```
#region WalkThrough (Dynamic Help)
    If
    (
        $Walkthrough
    )
    {
        If
        (
            $($PSCmdlet.MyInvocation.InvocationName)
        )
        {
            $Function = $($PSCmdlet.MyInvocation.InvocationName)
        }
        Else
        {
            If
            (
                $Host.Name -match 'ISE'
            )
            {
                $Function = $(Split-Path -Path $psISE.CurrentFile.FullPath -Leaf) -replace '((?:.[^.\r\n]*){1})$'
            }
        }

        If
        (
            Test-Path -Path Function:\Invoke-WalkThrough
        )
        {
            If
            (
                $Function -eq 'Invoke-WalkThrough'
            )
            {
                #Disable Invoke-WalkThrough looping
                Invoke-Command -ScriptBlock { Invoke-WalkThrough -Name $Function -RemoveRun }
                Return
            }
            Else
            {
                Invoke-Command -ScriptBlock { Invoke-WalkThrough -Name $Function }
                Return
            }
        }
        Else
        {
            Get-Help -Name $Function -Full
            Return
        }
    }
#endregion WalkThrough (Dynamic Help)
```

* **EXAMPLE #1**
<br>
**Command:** <Verb-Function_Name> -Help<br>
**Description:** Call your Function with the Alias -Help to display the interactive help menu<br>
**Notes:**<br>

* **EXAMPLE #2**
<br>
**Command:** <Verb-Function_Name> -WalkThrough<br>
**Description:** Call your Function with the Parameter -WalkThrough to display the interactive help menu<br>
**Notes:**<br>

* **EXAMPLE #3**
<br>
**Command:** Invoke-WalkThrough -Name <Verb-Function_Name><br>
**Description:** This will start the Dynamic help menu system on the called function<br>
**Notes:**<br>

* **EXAMPLE #4**
<br>
**Command:** Invoke-WalkThrough -Name <Verb-Function_Name> -RemoveRun<br>
**Description:** This will start the Dynamic help menu system on the called function<br>
**Notes:** The menu system item ( Run ) will be disabled<br>
