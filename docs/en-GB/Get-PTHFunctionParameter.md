---
external help file: pspestertesthelpers-help.xml
Module Name: pspestertesthelpers
online version:
schema: 2.0.0
---

# Get-PTHFunctionParameter

## SYNOPSIS
Gets the parameters and their properties for a specified function.

## SYNTAX

```
Get-PTHFunctionParameter [-Name] <String> [[-Exclude] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Gets the parameters and their properties for a specified function.
The
function must exist within the 'Function:' provider so will not work on
cmdlets.

## EXAMPLES

### EXAMPLE 1
```
Get-PTHFunctionParameter -Name 'Get-FunctionParameters'
```

Returns the properties of each function parameter for the 'Import-Module'
function excluding the common parameters for Advanced Functions.

### EXAMPLE 2
```
Get-PTHFunctionParameter -Name 'Get-FunctionParameters' -Exclude ''
```

Returns the properties of each function parameter for the 'Import-Module'
function excluding no parameter names.

## PARAMETERS

### -Name
Name of the function.
The function must exist within the 'Function:'
provider or an exception will be thrown.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Exclude
Array of parameter names to exclude.
By default the Advanced Functions
common parameters are excluded.
Pass an empty array to have all
parameters returned.
= @('Verbose', 'Debug', 'ErrorAction', 'WarningAction',
'InformationAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable',
'OutVariable', 'OutBuffer', 'PipelineVariable' )

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author  : Paul Broadwith (https://github.com/pauby)
History : 2018-03-17 - pauby - Initial release

## RELATED LINKS
