function Assert-PTHMandatoryParameter {
    <#
    .SYNOPSIS
    Asserts that a function has only the mandatory parameters we pass.
    .DESCRIPTION
    Asserts that a function has only the mandatory parameters we pass. Returns true if it does and false otherwise.
    .EXAMPLE
    Assert-MandatoryParameter -FunctionName 'Get-MyFunction' -ParameterName 'Name'

    Asserts that the function 'Get-MyFunction' has only one mandatory parameter called 'Name'.
    .NOTES
    Author : Paul Broadwith https://github.com/pauby
    History: 2019-01-09 - pauby - Initial release
    .LINK
    https://github.com/pauby/pspestertesthelpers/blob/master/docs/Get-PTHMandatoryParameter.md
#>
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]
        $FunctionName,

        [Parameter(Mandatory)]
        [string[]]
        $ParameterName
    )

    # this will find a functions mandatory parameters that are not in the $ParameterName array.
    # if anything is found then it means the mandatory parameters we're testing for are different.
    $unknownParameters = Get-PTHFunctionParameter -Name $FunctionName | Where-Object {
        $_.Value.Attributes.Mandatory -eq $true -and $ParameterName -notcontains $_.Key
    }

    # if $unknownParameters is 0 then that is $false so we must negate it to mean $true as not finding any parameters different is a pass
    -not [bool]$unknownParameters
}